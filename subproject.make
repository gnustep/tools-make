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
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

#
# The names of the subproject is in the SUBPROJECT_NAME variable.
#

SUBPROJECT_NAME:=$(strip $(SUBPROJECT_NAME))

ifeq ($(INTERNAL_subproject_NAME),)
# This part is included the first time make is invoked.

ifneq ($(FRAMEWORK_NAME),)
build-headers:: $(SUBPROJECT_NAME:=.build-headers.subproject.variables)
endif

internal-all:: $(SUBPROJECT_NAME:=.all.subproject.variables)

# for frameworks, headers are copied by build-headers into the
# framework directory, and are automatically installed when you
# install the framework; for other projects, we need to install each
# subproject's headers separately
ifeq ($(FRAMEWORK_NAME),)
# WARNING - if you type `make install' in a framework's subproject dir
# you are going to install the headers in the wrong place - can't fix
# that - but you can prevent it by adding `FRAMEWORK_NAME = xxx' to
# your subprojects' GNUmakefiles.
internal-install:: $(SUBPROJECT_NAME:=.install.subproject.variables)

internal-uninstall:: $(SUBPROJECT_NAME:=.uninstall.subproject.variables)

endif

internal-clean:: $(SUBPROJECT_NAME:=.clean.subproject.variables)

internal-distclean:: $(SUBPROJECT_NAME:=.distclean.subproject.variables)

$(SUBPROJECT_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.subproject.variables

else
# This part gets included the second time make is invoked.

FRAMEWORK_HEADERS_DIR = $(FRAMEWORK_VERSION_DIR_NAME)/Headers/
FRAMEWORK_HEADER_FILES = $(patsubst %.h,$(FRAMEWORK_HEADERS_DIR)%.h,$(HEADER_FILES))

#
# Internal targets
#

#
# Compilation targets
#
ifeq ($(FRAMEWORK_NAME),)
internal-subproject-all:: before-$(TARGET)-all \
                       $(GNUSTEP_OBJ_DIR) \
                       $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) \
                       after-$(TARGET)-all
else
internal-subproject-all:: before-$(TARGET)-all \
                       $(GNUSTEP_OBJ_DIR) \
                       $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) \
                       framework-components \
                       framework-resource-files \
                       localized-framework-resource-files \
                       framework-webresource-files \
                       framework-localized-webresource-files \
                       after-$(TARGET)-all
endif

# We need to depend on SUBPROJECT_OBJ_FILES to account for sub-subprojects.
$(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT): $(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
                                          $(OBJ_FILES) $(SUBPROJECT_OBJ_FILES)
	$(OBJ_MERGE_CMD)

before-$(TARGET)-all::

after-$(TARGET)-all::

ifneq ($(FRAMEWORK_NAME),)
internal-subproject-build-headers:: $(FRAMEWORK_HEADER_FILES)

# We need to build the FRAMEWORK_HEADERS_DIR directory here because
# this rule could be executed before the top-level framework has built
# his dirs
$(FRAMEWORK_HEADER_FILES):: $(HEADER_FILES) $(FRAMEWORK_HEADERS_DIR)
ifneq ($(HEADER_FILES),)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) ./$$file $(FRAMEWORK_HEADERS_DIR)/$$file ; \
	  fi; \
	done
endif

$(FRAMEWORK_HEADERS_DIR):
	$(MKDIRS) $@

framework-components::
ifneq ($(COMPONENTS),)
	@ echo "Copying components into the framework wrapper..."; \
	cd $(FRAMEWORK_VERSION_DIR_NAME)/Resources; \
	for component in $(COMPONENTS) __done; do \
	  if [ $$component != __done ]; then \
	    if [ -d ../../../../$(SUBPROJECT_ROOT_DIR)/$$component ]; then \
	      cp -r ../../../../$(SUBPROJECT_ROOT_DIR)/$$component ./; \
	    fi; \
	  fi; \
	done; \
	echo "Copying localized components into the framework wrapper..."; \
	for l in $(LANGUAGES) __done; do \
	  if [ $$l != __done ]; then \
	    if [ ! -f $$l.lproj ]; then \
	      $(MKDIRS) $$l.lproj; \
	    fi; \
	  fi; \
	  cd $$l.lproj; \
	  for f in $(COMPONENTS) __done; do \
	    if [ $$f != __done ]; then \
	      if [ -d ../../../../../$(SUBPROJECT_ROOT_DIR)/$$l.lproj/$$f ]; then \
	        cp -r ../../../../../$(SUBPROJECT_ROOT_DIR)/$$l.lproj/$$f .; \
	      fi; \
	     fi; \
	   done; \
	   cd ..; \
	  done
endif

framework-resource-files::
ifneq ($(RESOURCE_FILES),)
	echo "Copying resources into the framework wrapper..."; \
	for f in "$(RESOURCE_FILES)"; do \
	  cp -r $$f $(FRAMEWORK_VERSION_DIR_NAME)/Resources; \
	done;
endif

localized-framework-resource-files::
ifneq ($(LOCALIZED_RESOURCE_FILES),)
	echo "Copying localized resources into the framework wrapper..."; \
	for l in $(LANGUAGES) __done; do \
	  if [ $$l != __done ]; then \
	    if [ ! -f $$l.lproj ]; then \
	      $(MKDIRS) $(FRAMEWORK_VERSION_DIR_NAME)/Resources/$$l.lproj; \
	     fi; \
	   fi; \
	   for f in $(LOCALIZED_RESOURCE_FILES) __done; do \
	     if [ $$f != __done ]; then \
	       if [ -f $$l.lproj/$$f ]; then \
	         cp -r $$l.lproj/$$f $(FRAMEWORK_VERSION_DIR_NAME)/Resources/$$l.lproj/; \
	       fi; \
	     fi; \
	   done; \
	 done
endif

# FIXME - FRAMEWORK_WEBSERVER_RESOURCE_DIRS is not defined ...
framework-webresource-dir::
	@(if [ "$(WEBSERVER_RESOURCE_FILES)" != "" ] || [ "$(FRAMEWORK_WEBSERVER_RESOURCE_DIRS)" != "" ]; then \
	  $(MKDIRS) $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources; \
	  $(MKDIRS) $(FRAMEWORK_WEBSERVER_RESOURCE_DIRS); \
	  if test ! -L "$(FRAMEWORK_DIR_NAME)/WebServerResources"; then \
	    $(LN_S) Versions/Current/WebServerResources $(FRAMEWORK_DIR_NAME);\
	  fi; \
	fi;)

framework-webresource-files:: framework-webresource-dir
ifneq ($(WEBSERVER_RESOURCE_FILES),)
	echo "Copying webserver resources into the framework wrapper..."; \
	cd $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources; \
	for ff in $(WEBSERVER_RESOURCE_FILES) __done; do \
	  if [ $$ff != __done ]; then \
	    if [ -f ../../../../$(SUBPROJECT_ROOT_DIR)/WebServerResources/$$ff ]; then \
	      cp -r ../../../../$(SUBPROJECT_ROOT_DIR)/WebServerResources/$$ff .; \
	    fi; \
	  fi; \
	done
endif

framework-localized-webresource-files:: framework-webresource-dir
ifneq ($(LOCALIZED_WEBSERVER_RESOURCE_FILES),)
	echo "Copying localized webserver resources into the framework wrapper..."; \
	cd $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources; \
	for l in $(LANGUAGES) __done; do \
	  if [ $$l != __done ]; then \
	    if [ ! -f $$l.lproj ]; then \
	      $(MKDIRS) $$l.lproj; \
	    fi; \
	  fi; \
	  cd $$l.lproj; \
	  for f in $(LOCALIZED_WEBSERVER_RESOURCE_FILES) __done; do \
	    if [ $$f != __done ]; then \
	      if [ -f ../../../../../$(SUBPROJECT_ROOT_DIR)/WebServerResources/$$l.lproj/$$f ]; then \
	        if [ ! -r $$f ]; then \
		  cp -r ../../../../../$(SUBPROJECT_ROOT_DIR)/WebServerResources/$$l.lproj/$$f $$f; \
		fi; \
	      fi;\
	    fi;\
	  done;\
	  cd ..; \
	done
endif

endif # FRAMEWORK code

#
# Installation targets - we only need to install headers and only 
# if this is not in a framework
#
ifeq ($(FRAMEWORK_NAME),)

ifeq ($(strip $(HEADER_FILES_DIR)),)
override HEADER_FILES_DIR = .
endif

internal-subproject-install:: $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR) \
                              $(ADDITIONAL_INSTALL_DIRS) \
                              internal-install-headers

$(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR):
	$(MKDIRS) $@

$(ADDITIONAL_INSTALL_DIRS):
	$(MKDIRS) $@

internal-install-headers::
ifneq ($(HEADER_FILES),)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) \
	      $(HEADER_FILES_DIR)/$$file \
	      $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done
endif

internal-subproject-uninstall::
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    rm -f $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done

endif

#
# Cleaning targets
#
internal-subproject-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-subproject-distclean::
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
