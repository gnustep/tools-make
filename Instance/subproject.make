#
#   Instance/subproject.make
#
#   Instance Makefile rules to build subprojects in GNUstep projects.
#
#   Copyright (C) 1998, 2001 Free Software Foundation, Inc.
#
#   Author:  Jonathan Gapen <jagapen@whitewater.chem.wisc.edu>
#   Author:  Nicola Pero <nicola@brainstorm.co.uk>
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

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

.PHONY: internal-subproject-all       \
        internal-subproject-install   \
        internal-subproject-uninstall

override HEADER_FILES = $($(GNUSTEP_INSTANCE)_HEADER_FILES)

FRAMEWORK_HEADERS_DIR = $(FRAMEWORK_VERSION_DIR_NAME)/Headers/
FRAMEWORK_HEADER_FILES = $(patsubst %.h,$(FRAMEWORK_HEADERS_DIR)%.h,$(HEADER_FILES))

#
# Compilation targets
#
ifeq ($(FRAMEWORK_NAME),)
internal-subproject-all:: before-$(GNUSTEP_INSTANCE)-all \
                       $(GNUSTEP_OBJ_DIR) \
                       $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) \
                       after-$(GNUSTEP_INSTANCE)-all
else
internal-subproject-all:: before-$(GNUSTEP_INSTANCE)-all \
                       $(GNUSTEP_OBJ_DIR) \
                       $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) \
                       framework-components \
                       framework-resource-files \
                       framework-localized-resource-files \
                       framework-webresource-files \
                       framework-localized-webresource-files \
                       after-$(GNUSTEP_INSTANCE)-all
endif

# We need to depend on SUBPROJECT_OBJ_FILES to account for sub-subprojects.
$(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT): $(OBJ_FILES_TO_LINK)
	$(OBJ_MERGE_CMD)

ifneq ($(FRAMEWORK_NAME),)
.PHONY: internal-subproject-build-headers       \
        framework-components \
        framework-resource-files \
        framework-localized-resource-files \
        framework-webresource-dir \
        framework-webresource-files \
        framework-localized-webresource-files

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

#
# FIXME - this is sure all wrong - frameworks are no different than
# bundles, applications, tools, libraries, gswbundles, gswapps - and
# should behave consistently with the other project types
# 
# So if we don't install resource files of an application into the
# application wrapper from a subproject, we shouldn't be installing
# resource files of a framework into the framework wrapper from a
# subproject!
#
# It's also *extremely* ugly that we have to duplicate here
# framework-specific code.  We want makefiles which are fairly independent
# of each other.
#
# Perhaps we might modify subproject.make so that a subproject can
# have resources, and it stores them into a bundle.
#
# Then, we modify tools, apps, libraries etc to merge the resources from
# all the subproject bundles into the main project bundle.  Since tools,
# apps, libraries etc will use the same code to manage their bundles,
# we need to write the code merging the subproject bundles only once.
#
# In any case - that must be done in a consistent way across all
# project types, so that subproject.make doesn't need to know if it's
# the subproject of a framework, bundle or something else, and doesn't
# contain this horrible framework specific code.
#

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
	    if [ -d ../../../../$(SUBPROJECT_ROOT_DIR)/$$l.lproj ]; then \
	      $(MKDIRS) $$l.lproj; \
	      cd $$l.lproj; \
	      for f in $(COMPONENTS) __done; do \
	        if [ $$f != __done ]; then \
	          if [ -d ../../../../../$(SUBPROJECT_ROOT_DIR)/$$l.lproj/$$f ]; then \
	            cp -r ../../../../../$(SUBPROJECT_ROOT_DIR)/$$l.lproj/$$f .; \
	          fi; \
	        fi; \
	      done; \
	      cd ..; \
	    fi;\
	  fi;\
	done
endif

framework-resource-files::
ifneq ($(RESOURCE_FILES),)
	@ echo "Copying resources into the framework wrapper..."; \
	for f in "$(RESOURCE_FILES)"; do \
	  cp -r $$f $(FRAMEWORK_VERSION_DIR_NAME)/Resources; \
	done;
endif

framework-localized-resource-files::
ifneq ($(LOCALIZED_RESOURCE_FILES),)
	@ echo "Copying localized resources into the framework wrapper..."; \
	for l in $(LANGUAGES) __done; do \
	  if [ $$l != __done ]; then \
	    if [ -d $$l.lproj ]; then \
	      $(MKDIRS) $(FRAMEWORK_VERSION_DIR_NAME)/Resources/$$l.lproj; \
	      for f in $(LOCALIZED_RESOURCE_FILES) __done; do \
	        if [ $$f != __done ]; then \
	          if [ -f $$l.lproj/$$f ]; then \
	            cp -r $$l.lproj/$$f $(FRAMEWORK_VERSION_DIR_NAME)/Resources/$$l.lproj/; \
	          fi; \
	        fi; \
	      done; \
	    else \
	      echo "Warning - $$l.lproj not found - ignoring"; \
	    fi;\
	  fi;\
	done
endif

# FIXME - FRAMEWORK_WEBSERVER_RESOURCE_DIRS is not defined ...
framework-webresource-dir::
	@(if [ "$(WEBSERVER_RESOURCE_FILES)" != "" ] || [ "$(FRAMEWORK_WEBSERVER_RESOURCE_DIRS)" != "" ]; then \
	  $(MKDIRS) $(FRAMEWORK_VERSION_DIR_NAME)/Resources/WebServer; \
	  $(MKDIRS) $(FRAMEWORK_WEBSERVER_RESOURCE_DIRS); \
	fi;)

framework-webresource-files:: framework-webresource-dir
ifneq ($(WEBSERVER_RESOURCE_FILES),)
	@ echo "Copying webserver resources into the framework wrapper..."; \
	cd $(FRAMEWORK_VERSION_DIR_NAME)/Resources/WebServer; \
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
	@ echo "Copying localized webserver resources into the framework wrapper..."; \
	cd $(FRAMEWORK_VERSION_DIR_NAME)/Resources/WebServer; \
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

include $(GNUSTEP_MAKEFILES)/Instance/Shared/headers.make

internal-subproject-install:: shared-instance-headers-install

internal-subproject-uninstall:: shared-instance-headers-uninstall

endif # no FRAMEWORK_NAME

## Local variables:
## mode: makefile
## End:
