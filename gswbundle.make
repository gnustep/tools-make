#
#   gswbundle.make
#
#   Makefile rules to build GNUstep-based bundles.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Manuel Guesdon <mguesdon@sbuilders.com>
#   Based on WOBundle.make by Helge Hess, MDlink online service center GmbH.
#   Based on bundle.make by Ovidiu Predescu <ovidiu@net-community.com>
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
ifeq ($(GSWBUNDLE_MAKE_LOADED),)
GSWBUNDLE_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

ifeq ($(strip $(GSWBUNDLE_EXTENSION)),)
GSWBUNDLE_EXTENSION = .gswbundle
endif

GSWBUNDLE_LD= $(BUNDLE_LD)
GSWBUNDLE_LDFLAGS = $(BUNDLE_LDFLAGS)

ifeq ($(GSWBUNDLE_INSTALL_DIR),)
GSWBUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Libraries
endif
# The name of the bundle is in the BUNDLE_NAME variable.
# The list of languages the bundle is localized in are in xxx_LANGUAGES
# The list of bundle resource file are in xxx_RESOURCE_FILES
# The list of localized bundle resource file are in xxx_LOCALIZED_RESOURCE_FILES
# The list of bundle resource directories are in xxx_RESOURCE_DIRS
# The name of the principal class is xxx_PRINCIPAL_CLASS
# The header files are in xxx_HEADER_FILES
# The directory where the header files are located is xxx_HEADER_FILES_DIR
# The directory where to install the header files inside the library
# installation directory is xxx_HEADER_FILES_INSTALL_DIR
# where xxx is the bundle name
#  xxx_WEBSERVER_RESOURCE_DIRS <==
# The list of localized application web server resource directories are in 
#  xxx_LOCALIZED_WEBSERVER_RESOURCE_DIRS
# where xxx is the application name <==

GSWBUNDLE_NAME:=$(strip $(GSWBUNDLE_NAME))

ifeq ($(INTERNAL_bundle_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(GSWBUNDLE_NAME:=.all.bundle.variables)

internal-install:: $(GSWBUNDLE_NAME:=.install.bundle.variables)

internal-uninstall:: $(GSWBUNDLE_NAME:=.uninstall.bundle.variables)

internal-clean:: $(GSWBUNDLE_NAME:=.clean.bundle.subprojects)
	rm -rf $(GNUSTEP_OBJ_DIR) \
	       $(addsuffix $(GSWBUNDLE_EXTENSION),$(GSWBUNDLE_NAME))

internal-distclean:: $(GSWBUNDLE_NAME:=.distclean.bundle.subprojects)
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

$(GSWBUNDLE_NAME):
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
        gswbundle-components \
        gswbundle-resource-files \
        gswbundle-localized-resource-files \
        gswbundle-webresource-dir \
        gswbundle-webresource-files \
        gswbundle-localized-webresource-files

# On Solaris we don't need to specifies the libraries the bundle needs.
# How about the rest of the systems? ALL_BUNDLE_LIBS is temporary empty.
#ALL_GSWBUNDLE_LIBS = $(ADDITIONAL_GSW_LIBS) $(AUXILIARY_GSW_LIBS) $(GSW_LIBS) \
	$(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) \
	$(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) \
	$(OBJC_LIBS) $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)
#ALL_GSWBUNDLE_LIBS = 
#ALL_GSWBUNDLE_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_GSWBUNDLE_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

internal-bundle-all:: before-$(TARGET)-all \
                      $(GNUSTEP_OBJ_DIR) \
                      build-bundle-dir \
                      build-bundle \
                      after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

GSWBUNDLE_DIR_NAME := $(INTERNAL_bundle_NAME:=$(GSWBUNDLE_EXTENSION))
GSWBUNDLE_FILE := \
    $(GSWBUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/$(GSWBUNDLE_NAME)
GSWBUNDLE_RESOURCE_DIRS = $(foreach d, $(RESOURCE_DIRS), $(GSWBUNDLE_DIR_NAME)/Resources/$(d))
GSWBUNDLE_WEBSERVER_RESOURCE_DIRS =  $(foreach d, $(WEBSERVER_RESOURCE_DIRS), $(GSWBUNDLE_DIR_NAME)/WebServerResources/$(d))

ifeq ($(strip $(HEADER_FILES_DIR)),)
HEADER_FILES_DIR = .
endif

ifeq ($(strip $(LANGUAGES)),)
  override LANGUAGES="English"
endif

build-bundle-dir:: $(GSWBUNDLE_DIR_NAME)/Resources \
                   $(GSWBUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR) \
                   $(GSWBUNDLE_RESOURCE_DIRS)

$(GSWBUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR):
	@$(MKDIRS) $(GSWBUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)

$(GSWBUNDLE_RESOURCE_DIRS):
	@$(MKDIRS) $(GSWBUNDLE_RESOURCE_DIRS)

build-bundle:: $(GSWBUNDLE_FILE) \
               gswbundle-components \
               gswbundle-resource-files \
               gswbundle-localized-resource-files \
               gswbundle-localized-webresource-files \
               gswbundle-webresource-files


$(GSWBUNDLE_FILE) : $(OBJ_FILES_TO_LINK)
	$(GSWBUNDLE_LD) $(GSWBUNDLE_LDFLAGS) \
	                $(ALL_LDFLAGS) -o $(LDOUT)$(GSWBUNDLE_FILE) \
			$(OBJ_FILES_TO_LINK) \
	                $(ALL_LIB_DIRS) $(ALL_GSWBUNDLE_LIBS)

gswbundle-components :: $(GSWBUNDLE_DIR_NAME)
ifneq ($(strip $(COMPONENTS)),)
	@(echo "Linking components into the bundle wrapper..."; \
        cd $(GSWBUNDLE_DIR_NAME)/Resources; \
        for component in $(COMPONENTS); do \
	  if [ -d ../../$$component ]; then \
	    $(LN_S) -f ../../$$component ./;\
	  fi; \
        done; \
	echo "Linking localized components into the bundle wrapper..."; \
        for l in $(LANGUAGES); do \
	  if [ -d ../../$$l.lproj ]; then \
	    $(MKDIRS) $$l.lproj; \
	    cd $$l.lproj; \
	    for f in $(COMPONENTS); do \
	      if [ -d ../../../$$l.lproj/$$f ]; then \
	        $(LN_S) -f ../../../$$l.lproj/$$f .;\
	      fi;\
	    done;\
	    cd ..; \
	  fi;\
	done)
endif

gswbundle-resource-files:: $(GSWBUNDLE_DIR_NAME)/bundle-info.plist \
                           $(GSWBUNDLE_DIR_NAME)/Resources/Info-gnustep.plist
ifneq ($(strip $(RESOURCE_FILES)),)
	@(echo "Linking resources into the bundle wrapper..."; \
	cd $(GSWBUNDLE_DIR_NAME)/Resources/; \
	for ff in $(RESOURCE_FILES); do \
	  $(LN_S) -f ../../$$ff .;\
	done)
endif

gswbundle-localized-resource-files:: $(GSWBUNDLE_DIR_NAME)/Resources/Info-gnustep.plist
ifneq ($(strip $(LOCALIZED_RESOURCE_FILES)),)
	@(echo "Linking localized resources into the bundle wrapper..."; \
	cd $(GSWBUNDLE_DIR_NAME)/Resources; \
	for l in $(LANGUAGES); do \
	  if [ -d ../../$$l.lproj ]; then \
	    $(MKDIRS) $$l.lproj; \
	    cd $$l.lproj; \
	    for f in $(LOCALIZED_RESOURCE_FILES); do \
	      if [ -f ../../../$$l.lproj/$$f ]; then \
	        $(LN_S) -f ../../../$$l.lproj/$$f .;\
	      fi;\
	    done;\
	    cd ..;\
	  else\
	   echo "Warning - $$l.lproj not found - ignoring";\
	  fi;\
	done)
endif

gswbundle-webresource-dir::
	@$(MKDIRS) $(GSWBUNDLE_WEBSERVER_RESOURCE_DIRS)

gswbundle-webresource-files:: $(GSWBUNDLE_DIR_NAME)/WebServerResources \
                              gswbundle-webresource-dir
ifneq ($(strip $(WEBSERVER_RESOURCE_FILES)),)
	@(echo "Linking webserver resources into the application wrapper..."; \
	cd $(GSWBUNDLE_DIR_NAME)/WebServerResources; \
	for ff in $(WEBSERVER_RESOURCE_FILES); do \
	  $(LN_S) -f ../../WebServerResources/$$ff .;\
	done)
endif

gswbundle-localized-webresource-files:: $(GSWBUNDLE_DIR_NAME)/WebServerResources \
                                        gswbundle-webresource-dir
ifneq ($(strip $(LOCALIZED_WEBSERVER_RESOURCE_FILES)),)
	@(echo "Linking localized web resources into the application wrapper..."; \
	cd $(GSWBUNDLE_DIR_NAME)/WebServerResources; \
	for l in $(LANGUAGES); do \
	  if [ -d ../../WebServerResources/$$l.lproj ]; then \
	    $(MKDIRS) $$l.lproj; \
	    cd $$l.lproj; \
	    for f in $(LOCALIZED_WEBSERVER_RESOURCE_FILES); do \
	      if [ -f ../../../WebServerResources/$$l.lproj/$$f ]; then \
	        if [ ! -r $$f ]; then \
	          $(LN_S) ../../../WebServerResources/$$l.lproj/$$f $$f;\
	        fi;\
	      fi;\
	    done;\
	    cd ..; \
	  else \
	    echo "Warning - WebServerResources/$$l.lproj not found - ignoring";\
	  fi;\
	done)
endif

ifeq ($(PRINCIPAL_CLASS),)
override PRINCIPAL_CLASS = $(INTERNAL_bundle_NAME)
endif

$(GSWBUNDLE_DIR_NAME)/bundle-info.plist: $(GSWBUNDLE_DIR_NAME)
	@(cd $(GSWBUNDLE_DIR_NAME); $(LN_S) -f ../bundle-info.plist .)

$(GSWBUNDLE_DIR_NAME)/Resources/Info-gnustep.plist: $(GSWBUNDLE_DIR_NAME)/Resources
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(INTERNAL_bundle_NAME)\";"; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  if [ "$(HAS_GSWCOMPONENTS)" != "" ]; then \
			  echo "  HasGSWComponents = \"$(HAS_GSWCOMPONENTS)\";"; \
	  fi; \
	  echo "}") >$@

$(GSWBUNDLE_DIR_NAME)/Resources:
	@$(MKDIRS) $@

$(GSWBUNDLE_DIR_NAME)/WebServerResources:
	@$(MKDIRS) $@

internal-bundle-install:: $(GSWBUNDLE_INSTALL_DIR)
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
	rm -rf $(GSWBUNDLE_INSTALL_DIR)/$(GSWBUNDLE_DIR_NAME); \
	$(TAR) ch --exclude=CVS --to-stdout $(GSWBUNDLE_DIR_NAME) | (cd $(GSWBUNDLE_INSTALL_DIR); $(TAR) xf -)

$(GSWBUNDLE_INSTALL_DIR)::
	@$(MKDIRS) $@

internal-bundle-uninstall::
ifneq ($(HEADER_FILES),)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    rm -rf $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done;
endif
	rm -rf $(GSWBUNDLE_INSTALL_DIR)/$(GSWBUNDLE_DIR_NAME)

endif

endif
# bundle.make loaded

## Local variables:
## mode: makefile
## End:
