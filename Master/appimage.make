#   -*-makefile-*-
#   Master/appimage.make
#
#   Makefile rules to build an AppImage package.
#
#   Copyright (C) 2026 Free Software Foundation, Inc.

ifeq ($(APPIMAGE_MAKE_LOADED),)
APPIMAGE_MAKE_LOADED = yes

# Path to the main executable within the AppDir (relative path, e.g., /usr/bin/myapp).
# If not specified, GNUstep-make automatically attempts to find it.
APPIMAGE_MAIN_EXECUTABLE = 

# Layout of the AppDir
APPIMAGE_BUILD_DIR = $(GNUSTEP_BUILD_DIR)/appimage-build
APPIMAGE_APPDIR    = $(APPIMAGE_BUILD_DIR)/AppDir
APPIMAGE_LIB_DIR   = /usr/lib
APPIMAGE_BIN_DIR   = /usr/bin

# Path to the appimagetool binary.
APPIMAGE_TOOL = appimagetool

# Final AppImage filename
# We use PACKAGE_NAME and VERSION if available, otherwise fallback to defaults
APPIMAGE_BASENAME = $(if $(PACKAGE_NAME),$(PACKAGE_NAME),gnustep-app)-$(if $(VERSION),$(VERSION),1.0)
APPIMAGE_NAME     = $(APPIMAGE_BASENAME)-$(GNUSTEP_TARGET_CPU)-$(GNUSTEP_TARGET_OS).AppImage

# Product name used for .desktop file and other identifiers.
APPIMAGE_PRODUCT_NAME = $(if $(PACKAGE_NAME),$(PACKAGE_NAME),$(if $(GNUSTEP_INSTANCE),$(GNUSTEP_INSTANCE),gnustep-app))

APPIMAGE_ICON = $($(APPIMAGE_PRODUCT_NAME)_APPLICATION_ICON)
APPIMAGE_COMMENT = $($(APPIMAGE_PRODUCT_NAME)_APPIMAGE_COMMENT)
APPIMAGE_CATEGORIES = $($(APPIMAGE_PRODUCT_NAME)_APPIMAGE_CATEGORIES)

.PHONY: appimage
appimage: before-appimage internal-appimage after-appimage

before-appimage::

internal-appimage:: check-tools prepare-appdir install-to-appdir create-gnustep-config bundle-dependencies create-apprun create-desktop-file package-appimage

check-tools:
	@command -v ldd >/dev/null 2>&1 || { echo "Error: ldd not found. Please install binutils."; exit 1; }
	@command -v $(APPIMAGE_TOOL) >/dev/null 2>&1 || { echo "Error: $(APPIMAGE_TOOL) not found. Please see https://appimage.org/"; exit 1; }

prepare-appdir:
	-rm -rf $(APPIMAGE_APPDIR)
	mkdir -p $(APPIMAGE_APPDIR)$(APPIMAGE_BIN_DIR)
	mkdir -p $(APPIMAGE_APPDIR)$(APPIMAGE_LIB_DIR)

install-to-appdir:
	$(MAKE) install DESTDIR=$(APPIMAGE_APPDIR)
	@# Copy GNUstep system tools (gdnc, gpbs, make_services) to keep the AppImage self-contained
	mkdir -p $(APPIMAGE_APPDIR)/usr/local/bin
	-cp -p $$(gnustep-config --variable=GNUSTEP_SYSTEM_TOOLS)/gdnc $(APPIMAGE_APPDIR)/usr/local/bin/
	-cp -p $$(gnustep-config --variable=GNUSTEP_SYSTEM_TOOLS)/gpbs $(APPIMAGE_APPDIR)/usr/local/bin/
	-cp -p $$(gnustep-config --variable=GNUSTEP_SYSTEM_TOOLS)/make_services $(APPIMAGE_APPDIR)/usr/local/bin/

create-gnustep-config:
	mkdir -p $(APPIMAGE_APPDIR)/usr/etc/GNUstep
	@echo "GNUSTEP_USER_CONFIG_FILE=.GNUstep.conf" > $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf
	@echo "GNUSTEP_USER_DEFAULTS_DIR=GNUstep/Defaults" >> $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf
	@echo "GNUSTEP_SYSTEM_USERS_DIR=/home" >> $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf
	@echo "GNUSTEP_NETWORK_USERS_DIR=/home" >> $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf
	@echo "GNUSTEP_LOCAL_USERS_DIR=/home" >> $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf
	@echo "GNUSTEP_SYSTEM_LIBRARY=../../lib/GNUstep" >> $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf
	@echo "GNUSTEP_LOCAL_LIBRARY=../../lib/GNUstep" >> $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf
	@echo "GNUSTEP_NETWORK_LIBRARY=../../lib/GNUstep" >> $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf
	@echo "GNUSTEP_SYSTEM_TOOLS=../../local/bin" >> $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf
	@echo "GNUSTEP_LOCAL_TOOLS=../../local/bin" >> $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf
	chmod 600 $(APPIMAGE_APPDIR)/usr/etc/GNUstep/GNUstep.conf

bundle-dependencies:
	@# We define a list of prefixes that we WANT to bundle.
	@# This includes the GNUSTEP_LIBRARIES_DIRS from common.make.
	@PREFIXES="$(GNUSTEP_LIBRARIES_DIRS) $(GNUSTEP_FRAMEWORKS_DIRS)"; \
	LDPATH=$$(echo "$(GNUSTEP_LIBRARIES_DIRS)" | tr ' ' ':'); \
	for bin in $$(find $(APPIMAGE_APPDIR) -type f -executable); do \
		LD_LIBRARY_PATH="$$LDPATH:$$LD_LIBRARY_PATH" ldd $$bin | grep "=>" | while read -r line; do \
			lib=$$(echo $$line | awk '{print $$3}'); \
			if [ -n "$$lib" ]; then \
				should_bundle=yes; \
				case $$lib in \
					*libc.so*|*libpthread.so*|*libdl.so*|*libm.so*|*librt.so*|*libX11.so*|*libXext.so*|*libxcb.so*) should_bundle=no;; \
				esac; \
				if [ "$$should_bundle" = "yes" ]; then \
					dest=$(APPIMAGE_APPDIR)$(APPIMAGE_LIB_DIR); \
					mkdir -p $$dest; \
					cp -L $$lib $$dest/$${lib##*/}; \
				fi; \
			fi; \
		done; \
	done

	@# Also bundle GNUstep bundles (backends, etc.)
	@for pref in $(GNUSTEP_LIBRARIES_DIRS) $(GNUSTEP_FRAMEWORKS_DIRS); do \
		if [ -d "$$pref/GNUstep/Bundles" ]; then \
			echo "Copying bundles from $$pref/GNUstep/Bundles"; \
			dest=$(APPIMAGE_APPDIR)/usr/lib/GNUstep/Bundles; \
			mkdir -p $$dest; \
			cp -Rp $$pref/GNUstep/Bundles/. $$dest/; \
		fi; \
	done

	@BACKEND_BUNDLE=$$(find $(APPIMAGE_APPDIR)/usr/lib/GNUstep/Bundles -name "libgnustep-back-*.bundle" | head -n 1); \
	if [ -n "$$BACKEND_BUNDLE" ]; then \
		ln -sf $${BACKEND_BUNDLE##*/} $(APPIMAGE_APPDIR)/usr/lib/GNUstep/Bundles/libgnustep-back.bundle; \
	fi

	LDPATH=$$(echo "$(GNUSTEP_LIBRARIES_DIRS)" | tr ' ' ':'); \
	for lib in $$(find $(APPIMAGE_APPDIR)/usr/lib/GNUstep/Bundles -type f -executable); do \
		LD_LIBRARY_PATH="$$LDPATH:$$LD_LIBRARY_PATH" ldd $$lib | grep "=>" | while read -r line; do \
			libpath=$$(echo $$line | awk '{print $$3}'); \
			if [ -n "$$libpath" ]; then \
				should_bundle=yes; \
				case $$libpath in \
					*libc.so*|*libpthread.so*|*libdl.so*|*libm.so*|*librt.so*|*libX11.so*|*libXext.so*|*libxcb.so*) should_bundle=no;; \
				esac; \
				if [ "$$should_bundle" = "yes" ]; then \
					dest=$(APPIMAGE_APPDIR)$(APPIMAGE_LIB_DIR); \
					mkdir -p $$dest; \
					cp -L $$libpath $$dest/$${libpath##*/}; \
				fi; \
			fi; \
		done; \
	done

create-apprun:
	@if [ -n "$(APPIMAGE_MAIN_EXECUTABLE)" ]; then \
		RELATIVE_BIN="$(APPIMAGE_MAIN_EXECUTABLE)"; \
	else \
		BIN_PATH=""; \
		if [ -n "$(PACKAGE_NAME)" ]; then \
			BIN_PATH=$$(find $(APPIMAGE_APPDIR) -type f -executable -name "$(PACKAGE_NAME)" | head -n 1); \
		fi; \
		if [ -z "$$BIN_PATH" ]; then \
			BIN_PATH=$$(find $(APPIMAGE_APPDIR) -path "*/lib*" -prune -o -type f -executable -print | head -n 1); \
		fi; \
		if [ -z "$$BIN_PATH" ]; then \
			echo "Error: No executable found in $(APPIMAGE_APPDIR)"; exit 1; \
		fi; \
		RELATIVE_BIN=$${BIN_PATH#$(APPIMAGE_APPDIR)}; \
	fi; \
	sed "s|%S|$$RELATIVE_BIN|" ../tools-make/apprun.template > $(APPIMAGE_APPDIR)/AppRun
	chmod +x $(APPIMAGE_APPDIR)/AppRun

create-desktop-file:
	@EXEC=""; \
	if [ -n "$(APPIMAGE_MAIN_EXECUTABLE)" ]; then \
		EXEC="$(APPIMAGE_MAIN_EXECUTABLE)"; \
	else \
		BIN_PATH=""; \
		if [ -n "$(PACKAGE_NAME)" ]; then \
			BIN_PATH=$$(find $(APPIMAGE_APPDIR) -type f -executable -name "$(PACKAGE_NAME)" | head -n 1); \
		fi; \
		if [ -z "$$BIN_PATH" ]; then \
			BIN_PATH=$$(find $(APPIMAGE_APPDIR) -path "*/lib*" -prune -o -type f -executable -print | head -n 1); \
		fi; \
		if [ -z "$$BIN_PATH" ]; then \
			echo "Error: No executable found for .desktop file"; exit 1; \
		fi; \
		EXEC=$${BIN_PATH#$(APPIMAGE_APPDIR)}; \
	fi; \
	ICON=""; \
	if [ -n "$(APPIMAGE_ICON)" ]; then \
		ICON_FILE="$(APPIMAGE_ICON)"; \
		FOUND_ICON=$$(find $(APPIMAGE_APPDIR) -name "$$ICON_FILE" | head -n 1); \
		if [ -n "$$FOUND_ICON" ]; then \
			cp "$$FOUND_ICON" $(APPIMAGE_APPDIR)/; \
			ICON=$$(basename $$FOUND_ICON); \
			ICON=$${ICON%.*}; \
		fi; \
	fi; \
	echo "[Desktop Entry]" > $(APPIMAGE_APPDIR)/$(APPIMAGE_PRODUCT_NAME).desktop; \
	echo "Type=Application" >> $(APPIMAGE_APPDIR)/$(APPIMAGE_PRODUCT_NAME).desktop; \
	echo "Name=$(APPIMAGE_PRODUCT_NAME)" >> $(APPIMAGE_APPDIR)/$(APPIMAGE_PRODUCT_NAME).desktop; \
	echo "Comment=$(APPIMAGE_COMMENT)" >> $(APPIMAGE_APPDIR)/$(APPIMAGE_PRODUCT_NAME).desktop; \
	echo "Exec=$$EXEC" >> $(APPIMAGE_APPDIR)/$(APPIMAGE_PRODUCT_NAME).desktop; \
	echo "Icon=$$ICON" >> $(APPIMAGE_APPDIR)/$(APPIMAGE_PRODUCT_NAME).desktop; \
	echo "Categories=$(APPIMAGE_CATEGORIES)" >> $(APPIMAGE_APPDIR)/$(APPIMAGE_PRODUCT_NAME).desktop

package-appimage:
	$(APPIMAGE_TOOL) $(APPIMAGE_APPDIR) $(APPIMAGE_NAME)

after-appimage::


# Clean target for appimage build artifacts
appimage-clean:
	-rm -rf $(APPIMAGE_BUILD_DIR)
	-rm -f $(APPIMAGE_NAME)

endif
