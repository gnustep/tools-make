#
#   bundle.make
#
#   Makefile rules to build GNUstep-based bundles.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# prevent multiple inclusions
ifeq ($(BUNDLE_MAKE_LOADED),)
BUNDLE_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

# The name of the bundle is in the BUNDLE_NAME variable.
# The list of bundle resource file are in xxx_RESOURCE_FILES
# The list of localized bundle resource files is in xxx_LOCALIZED_RESOURCE_FILES
# The list of languages the bundle supports is in xxx_LANGUAGES
# The list of bundle resource directories are in xxx_RESOURCE_DIRS
# The name of the principal class is xxx_PRINCIPAL_CLASS
# The header files are in xxx_HEADER_FILES
# The directory where the header files are located is xxx_HEADER_FILES_DIR
# The directory where to install the header files inside the library
# installation directory is xxx_HEADER_FILES_INSTALL_DIR
# where xxx is the bundle name
#

BUNDLE_NAME:=$(strip $(BUNDLE_NAME))

ifeq ($(INTERNAL_bundle_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(BUNDLE_NAME:=.all.bundle.variables)

internal-install:: $(BUNDLE_NAME:=.install.bundle.variables)

internal-uninstall:: $(BUNDLE_NAME:=.uninstall.bundle.variables)

internal-clean:: $(BUNDLE_NAME:=.clean.bundle.variables)

internal-distclean:: $(BUNDLE_NAME:=.distclean.bundle.variables)

$(BUNDLE_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.bundle.variables

else
# This part gets included the second time make is invoked.

.PHONY: internal-bundle-all \
        internal-bundle-clean \
        internal-bundle-distclean \
        internal-bundle-install \
        internal-bundle-uninstall \
        before-$(TARGET)-all \
        after-$(TARGET)-all \
        build-bundle-dir \
        build-bundle \
        build-macosx-bundle \
        bundle-resource-files \
        bundle-localized-resource-files 


# On Solaris we don't need to specifies the libraries the bundle needs.
# How about the rest of the systems? ALL_BUNDLE_LIBS is temporary empty.
#ALL_BUNDLE_LIBS = $(ADDITIONAL_GUI_LIBS) $(AUXILIARY_GUI_LIBS) $(BACKEND_LIBS) \
   $(GUI_LIBS) $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) \
   $(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS) \
   $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)

ALL_BUNDLE_LIBS = $(BUNDLE_LIBS)

ALL_BUNDLE_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_BUNDLE_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

ifeq ($(WITH_DLL),yes)
TTMP_LIBS := $(ALL_BUNDLE_LIBS)
TTMP_LIBS := $(filter -l%, $(TTMP_LIBS))
# filter all non-static libs (static libs are those ending in _ds, _s, _ps..)
TTMP_LIBS := $(filter-out -l%_ds, $(TTMP_LIBS))
TTMP_LIBS := $(filter-out -l%_s,  $(TTMP_LIBS))
TTMP_LIBS := $(filter-out -l%_dps,$(TTMP_LIBS))
TTMP_LIBS := $(filter-out -l%_ps, $(TTMP_LIBS))
# strip away -l, _p and _d ..
TTMP_LIBS := $(TTMP_LIBS:-l%=%)
TTMP_LIBS := $(TTMP_LIBS:%_d=%)
TTMP_LIBS := $(TTMP_LIBS:%_p=%)
TTMP_LIBS := $(TTMP_LIBS:%_dp=%)
TTMP_LIBS := $(shell echo $(TTMP_LIBS)|tr '-' '_')
TTMP_LIBS := $(TTMP_LIBS:%=-Dlib%_ISDLL=1)
ALL_CPPFLAGS += $(TTMP_LIBS)
BUNDLE_OBJ_EXT = $(DLL_LIBEXT)
endif # WITH_DLL

internal-bundle-all:: before-$(TARGET)-all \
                      $(GNUSTEP_OBJ_DIR) \
                      build-bundle-dir \
                      build-bundle \
                      build-macosx-bundle \
                      after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

BUNDLE_DIR_NAME := $(INTERNAL_bundle_NAME:=$(BUNDLE_EXTENSION))
BUNDLE_FILE := \
    $(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/$(INTERNAL_bundle_NAME)$(BUNDLE_OBJ_EXT)
BUNDLE_RESOURCE_DIRS = $(foreach d, $(RESOURCE_DIRS), $(BUNDLE_DIR_NAME)/Resources/$(d))
ifeq ($(strip $(LANGUAGES)),)
  override LANGUAGES="English"
endif
ifeq ($(BUNDLE_INSTALL_DIR),)
  BUNDLE_INSTALL_DIR := $(GNUSTEP_BUNDLES)
endif

build-bundle-dir:: $(BUNDLE_DIR_NAME)/Resources \
                   $(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR) \
                   $(BUNDLE_RESOURCE_DIRS)

$(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR):
	$(MKDIRS) $(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)

$(BUNDLE_RESOURCE_DIRS):
	$(MKDIRS) $(BUNDLE_RESOURCE_DIRS)

build-bundle:: $(BUNDLE_FILE) \
               bundle-resource-files \
               bundle-localized-resource-files

ifeq ($(WITH_DLL),yes)

$(BUNDLE_FILE) : $(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
                 $(SUBPROJECT_OBJ_FILES) $(OBJ_FILES)
	$(DLLWRAP) --driver-name $(CC) \
		-o $(LDOUT)$(BUNDLE_FILE) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
                $(SUBPROJECT_OBJ_FILES) $(OBJ_FILES) \
		$(ALL_FRAMEWORKS_DIRS) $(ALL_LIB_DIRS) $(ALL_BUNDLE_LIBS)

else # WITH_DLL

$(BUNDLE_FILE) : $(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
                 $(SUBPROJECT_OBJ_FILES) $(OBJ_FILES)
	$(BUNDLE_LD) $(BUNDLE_LDFLAGS) $(ALL_LDFLAGS) \
		-o $(LDOUT)$(BUNDLE_FILE) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(SUBPROJECT_OBJ_FILES) \
		$(ALL_FRAMEWORK_DIRS) $(ALL_LIB_DIRS) $(ALL_BUNDLE_LIBS)

endif # WITH_DLL

bundle-resource-files:: $(BUNDLE_DIR_NAME)/Resources/Info.plist \
                        $(BUNDLE_DIR_NAME)/Resources/Info-gnustep.plist
ifneq ($(strip $(RESOURCE_FILES)),)
	@(echo "Copying resources into the bundle wrapper..."; \
	for f in "$(RESOURCE_FILES)"; do \
	  cp -r $$f $(BUNDLE_DIR_NAME)/Resources; \
	done)
endif

bundle-localized-resource-files:: $(BUNDLE_DIR_NAME)/Resources/Info-gnustep.plist
ifneq ($(strip $(LOCALIZED_RESOURCE_FILES)),)
	@(echo "Copying localized resources into the bundle wrapper..."; \
	for l in $(LANGUAGES); do \
	  if [ ! -f $$l.lproj ]; then \
	    $(MKDIRS) $(BUNDLE_DIR_NAME)/Resources/$$l.lproj; \
	  fi; \
	  for f in $(LOCALIZED_RESOURCE_FILES); do \
	    if [ -f $$l.lproj/$$f ]; then \
	      cp -r $$l.lproj/$$f $(BUNDLE_DIR_NAME)/Resources/$$l.lproj; \
	    fi; \
	  done; \
	done;
endif

ifeq ($(PRINCIPAL_CLASS),)
override PRINCIPAL_CLASS = $(INTERNAL_bundle_NAME)
endif

# MacOSX bundles

$(BUNDLE_DIR_NAME)/Contents :
	$(MKDIRS) $@

$(BUNDLE_DIR_NAME)/Contents/Resources : $(BUNDLE_DIR_NAME)/Contents \
                                        $(BUNDLE_DIR_NAME)/Resources
	@(cd $(BUNDLE_DIR_NAME)/Contents; rm -f Resources; \
	  $(LN_S) -f ../Resources .)

$(BUNDLE_DIR_NAME)/Contents/Info.plist: $(BUNDLE_DIR_NAME)/Contents
	@(echo "<?xml version='1.0' encoding='utf-8'?>";\
	  echo "<!DOCTYPE plist SYSTEM 'file://localhost/System/Library/DTDs/PropertyList.dtd'>";\
	  echo "<!-- Automatically generated, do not edit! -->";\
	  echo "<plist version='0.9'>";\
	  echo "  <dict>";\
	  echo "    <key>CFBundleExecutable</key>";\
	  echo "    <string>$(GNUSTEP_TARGET_LDIR)/$(INTERNAL_bundle_NAME)${BUNDLE_OBJ_EXT}</string>";\
	  echo "    <key>CFBundleInfoDictionaryVersion</key>";\
	  echo "    <string>6.0</string>";\
	  echo "    <key>CFBundlePackageType</key>";\
	  echo "    <string>BNDL</string>";\
	  echo "    <key>NSPrincipalClass</key>";\
	  echo "    <string>$(PRINCIPAL_CLASS)</string>";\
	  echo "  </dict>";\
	  echo "</plist>";\
	) >$@

build-macosx-bundle :: $(BUNDLE_DIR_NAME)/Contents \
                       $(BUNDLE_DIR_NAME)/Contents/Resources \
                       $(BUNDLE_DIR_NAME)/Contents/Info.plist

# NeXTstep bundles
$(BUNDLE_DIR_NAME)/Resources/Info.plist: $(BUNDLE_DIR_NAME)/Resources
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_TARGET_LDIR)/$(INTERNAL_bundle_NAME)${BUNDLE_OBJ_EXT}\";"; \
	  if [ "$(MAIN_MODEL_FILE)" = "" ]; then \
	    echo "  NSMainNibFile = \"\";"; \
	  else \
	    echo "  NSMainNibFile = \"$(subst .gmodel,,$(subst .gorm,,$(subst .nib,,$(MAIN_MODEL_FILE))))\";"; \
	  fi; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "}") >$@

# GNUstep bundles
$(BUNDLE_DIR_NAME)/Resources/Info-gnustep.plist: $(BUNDLE_DIR_NAME)/Resources
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(INTERNAL_bundle_NAME)${BUNDLE_OBJ_EXT}\";"; \
	  if [ "$(MAIN_MODEL_FILE)" = "" ]; then \
	    echo "  NSMainNibFile = \"\";"; \
	  else \
	    echo "  NSMainNibFile = \"$(subst .gmodel,,$(subst .gorm,,$(subst .nib,,$(MAIN_MODEL_FILE))))\";"; \
	  fi; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "}") >$@

internal-bundle-install:: $(BUNDLE_INSTALL_DIR)
ifneq ($(HEADER_FILES_INSTALL_DIR),)
	$(MKDIRS) $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR);
ifneq ($(HEADER_FILES),)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $(HEADER_FILES_DIR)/$$file \
	      $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done;
endif
endif
	rm -rf $(BUNDLE_INSTALL_DIR)/$(BUNDLE_DIR_NAME); \
	$(TAR) cf - $(BUNDLE_DIR_NAME) | (cd $(BUNDLE_INSTALL_DIR); $(TAR) xf -)

$(BUNDLE_DIR_NAME)/Resources:
	$(MKDIRS) $@

$(BUNDLE_INSTALL_DIR):
	$(MKDIRS) $@

internal-bundle-uninstall::
ifneq ($(HEADER_FILES),)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    rm -rf $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done;
endif
	rm -rf $(BUNDLE_INSTALL_DIR)/$(BUNDLE_DIR_NAME)

#
# Cleaning targets
#
internal-bundle-clean::
	rm -rf $(GNUSTEP_OBJ_DIR) $(BUNDLE_DIR_NAME)

internal-bundle-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

endif

endif
# bundle.make loaded

## Local variables:
## mode: makefile
## End:
