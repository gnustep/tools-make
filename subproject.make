#
#   subproject.make
#
#   Makefile rules to build subprojects in GNUstep projects.
#
#   Copyright (C) 1998 Free Software Foundation, Inc.
#
#   Author:  Jonathan Gapen <jagapen@whitewater.chem.wisc.edu>
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
ifeq ($(SUBPROJECT_MAKE_LOADED),)
SUBPROJECT_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
include $(GNUSTEP_MAKEFILES)/rules.make

#
# The names of the subproject is in the SUBPROJECT_NAME variable.
#

SUBPROJECT_NAME:=$(strip $(SUBPROJECT_NAME))

ifeq ($(INTERNAL_subproj_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(SUBPROJECT_NAME:=.all.subproj.variables)

internal-install:: all

internal-clean:: $(SUBPROJECT_NAME:=.clean.subproj.variables)

internal-distclean:: $(SUBPROJECT_NAME:=.distclean.subproj.variables)

$(SUBPROJECT_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.subproj.variables

else
# This part gets included the second time make is invoked.

FRAMEWORK_HEADER_FILES := $(patsubst %.h,$(FRAMEWORK_VERSION_DIR_NAME)/Headers/%.h,$(HEADER_FILES))

#
# Internal targets
#

#
# Compilation targets
#
internal-subproj-all:: before-all before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
                  $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) \
                  framework-components \
                  framework-resource-files localized-framework-resource-files \
                  framework-webresource-files \
                  framework-localized-webresource-files \
                  after-$(TARGET)-all after-all

$(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT): $(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(OBJ_FILES)
	$(OBJ_MERGE_CMD)

before-$(TARGET)-all:: $(FRAMEWORK_HEADER_FILES)

after-$(TARGET)-all::

after-all::

build-framework-headers:: $(FRAMEWORK_HEADER_FILES)

$(FRAMEWORK_HEADER_FILES):: $(HEADER_FILES)
	if [ "$(FRAMEWORK_NAME)" != "" ]; then \
	  if [ "$(HEADER_FILES)" != "" ]; then \
	    $(MKDIRS) $(FRAMEWORK_VERSION_DIR_NAME)/Headers; \
	    if test ! -L "$(DERIVED_SOURCES)/$(INTERNAL_framework_NAME)"; then \
	      $(LN_S) ../$(FRAMEWORK_DIR_NAME)/Headers \
	      $(DERIVED_SOURCES)/$(INTERNAL_framework_NAME); \
	    fi; \
	    for file in $(HEADER_FILES) __done; do \
	      if [ $$file != __done ]; then \
		$(INSTALL_DATA) ./$$file \
		$(FRAMEWORK_VERSION_DIR_NAME)/Headers/$$file ; \
	      fi; \
	    done; \
	  fi; \
	fi;

framework-components::
	@(if [ "$(FRAMEWORK_NAME)" != "" ]; then \
	  if [ "$(COMPONENTS)" != "" ]; then \
	    echo "Copying components into the framework wrapper..."; \
	    cd $(FRAMEWORK_VERSION_DIR_NAME)/Resources; \
	    for component in $(COMPONENTS); do \
	      if [ -d ../../../../$(SUBPROJECT_ROOT_DIR)/$$component ]; then \
		cp -r ../../../../$(SUBPROJECT_ROOT_DIR)/$$component ./; \
	      fi; \
	    done; \
	    echo "Copying localized components into the framework wrapper..."; \
	    for l in $(LANGUAGES); do \
	      if [ ! -f $$l.lproj ]; then \
		$(MKDIRS) $$l.lproj; \
	      fi; \
	      cd $$l.lproj; \
	      for f in $(COMPONENTS); do \
		if [ -d ../../../../../$(SUBPROJECT_ROOT_DIR)/$$l.lproj/$$f ]; then \
		  cp -r ../../../../../$(SUBPROJECT_ROOT_DIR)/$$l.lproj/$$f .;\
		fi; \
	      done; \
	      cd ..; \
	    done;\
	  fi; \
	fi;)

framework-resource-files::
	@(if [ "$(FRAMEWORK_NAME)" != "" ]; then \
	  if [ "$(RESOURCE_FILES)" != "" ]; then \
	    $(MKDIRS) $(FRAMEWORK_VERSION_DIR_NAME)/Resources; \
	    echo "Copying resources into the framework wrapper..."; \
	    for f in "$(RESOURCE_FILES)"; do \
	      cp -r $$f $(FRAMEWORK_VERSION_DIR_NAME)/Resources; \
	    done; \
	  fi; \
	fi;)

localized-framework-resource-files::
	@(if [ "$(FRAMEWORK_NAME)" != "" ]; then \
	  if [ "$(LOCALIZED_RESOURCE_FILES)" != "" ]; then \
	    echo "Copying localized resources into the framework wrapper..."; \
	    for l in $(LANGUAGES); do \
	      if [ ! -f $$l.lproj ]; then \
	        $(MKDIRS) $(FRAMEWORK_VERSION_DIR_NAME)/Resources/$$l.lproj; \
	      fi; \
	      for f in $(LOCALIZED_RESOURCE_FILES); do \
		if [ -f $$l.lproj/$$f ]; then \
		  cp -r $$l.lproj/$$f $(FRAMEWORK_VERSION_DIR_NAME)/Resources/$$l.lproj; \
		fi; \
	      done; \
	    done; \
	  fi; \
	fi;)

framework-webresource-dir::
	@(if [ "$(WEBSERVER_RESOURCE_FILES)" != "" ] || [ "$(FRAMEWORK_WEBSERVER_RESOURCE_DIRS)" != "" ]; then \
	  $(MKDIRS) $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources; \
	  $(MKDIRS) $(FRAMEWORK_WEBSERVER_RESOURCE_DIRS); \
	  if test ! -L "$(FRAMEWORK_DIR_NAME)/WebServerResources"; then \
	    $(LN_S) Versions/Current/WebServerResources $(FRAMEWORK_DIR_NAME);\
	  fi; \
	fi;)

framework-webresource-files:: framework-webresource-dir
	@(if [ "$(WEBSERVER_RESOURCE_FILES)" != "" ]; then \
	  echo "Copying webserver resources into the framework wrapper..."; \
	  cd $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources; \
	  for ff in $(WEBSERVER_RESOURCE_FILES); do \
	    if [ -f ../../../../$(SUBPROJECT_ROOT_DIR)/WebServerResources/$$ff ]; then \
	      cp -r ../../../../$(SUBPROJECT_ROOT_DIR)/WebServerResources/$$ff .; \
	    fi; \
	  done; \
	fi;)

framework-localized-webresource-files:: framework-webresource-dir
	@(if [ "$(LOCALIZED_WEBSERVER_RESOURCE_FILES)" != "" ]; then \
	  echo "Copying localized webserver resources into the framework wrapper..."; \
	  cd $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources; \
	  for l in $(LANGUAGES); do \
	    if [ ! -f $$l.lproj ]; then \
	      $(MKDIRS) $$l.lproj; \
	    fi; \
	    cd $$l.lproj; \
	    for f in $(LOCALIZED_WEBSERVER_RESOURCE_FILES); do \
	      if [ -f ../../../../../$(SUBPROJECT_ROOT_DIR)/WebServerResources/$$l.lproj/$$f ]; then \
		if [ ! -r $$f ]; then \
		  cp -r ../../../../../$(SUBPROJECT_ROOT_DIR)/WebServerResources/$$l.lproj/$$f $$f; \
		fi; \
	      fi;\
	    done;\
	    cd ..; \
	  done;\
	fi;)

#
# Installation targets
#

internal-subproj-install:: internal-install-subproj-dirs \
	internal-install-subproj-headers

internal-install-subproj-dirs::
	$(MKDIRS) \
		$(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR) \
		$(ADDITIONAL_INSTALL_DIRS)

internal-install-subproj-headers::
	if [ "$(HEADER_FILES)" != "" ]; then \
	  for file in $(HEADER_FILES) __done; do \
	    if [ $$file != __done ]; then \
	      if [ "$(FRAMEWORK_NAME)" == "" ]; then \
		$(INSTALL_DATA) $(HEADER_FILES_DIR)/$$file \
		$(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	      else; \
		$(INSTALL_DATA) $(HEADER_FILES_DIR)/$$file \
		$(FRAMEWORK_VERSION_DIR_NAME)/$$file ; \
	      fi; \
	    fi; \
	  done; \
	fi

internal-library-uninstall:: before-uninstall internal-uninstall-headers after-uninstall

before-uninstall after-uninstall::

internal-uninstall-headers::
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    if [ "$(FRAMEWORK_NAME)" == "" ]; then \
	      rm -f $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	    fi; \
	  fi; \
	done

#
# Cleaning targets
#
internal-subproj-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-subproj-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

#
# Testing targets
#

endif

endif
# subproject.make loaded

## Local variables:
## mode: makefile
## End:
