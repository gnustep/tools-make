#
#   Instance/gswbundle.make
#
#   Instance Makefile rules to build GNUstep web bundles.
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

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

# FIXME - this file has not been updated to use Shared/bundle.make
# because it is using symlinks rather than copying resources.  It also
# has 'COMPONENTS' (what's that ?)  it looks like it's the same as
# 'RESOURCE_FILES', but actually directories rather than simple files.

# override which can be removed once Master/rules.make has been updated
# not to push them down to submakes
override COMPONENTS = $($(GNUSTEP_INSTANCE)_COMPONENTS)
override LANGUAGES = $($(GNUSTEP_INSTANCE)_LANGUAGES)
override WEBSERVER_RESOURCE_FILES = $($(GNUSTEP_INSTANCE)_WEBSERVER_RESOURCE_FILES)
override LOCALIZED_WEBSERVER_RESOURCE_FILES = $($(GNUSTEP_INSTANCE)_LOCALIZED_WEBSERVER_RESOURCE_FILES)
override WEBSERVER_RESOURCE_DIRS = $($(GNUSTEP_INSTANCE)_WEBSERVER_RESOURCE_DIRS)
override LOCALIZED_RESOURCE_FILES = $($(GNUSTEP_INSTANCE)_LOCALIZED_RESOURCE_FILES)
override RESOURCE_FILES = $($(GNUSTEP_INSTANCE)_RESOURCE_FILES)
override RESOURCE_DIRS = $($(GNUSTEP_INSTANCE)_RESOURCE_DIRS)

include $(GNUSTEP_MAKEFILES)/Instance/Shared/headers.make

ifeq ($(strip $(GSWBUNDLE_EXTENSION)),)
GSWBUNDLE_EXTENSION = .gswbundle
endif

GSWBUNDLE_LD = $(BUNDLE_LD)
GSWBUNDLE_LDFLAGS = $(BUNDLE_LDFLAGS)

ifeq ($(GSWBUNDLE_INSTALL_DIR),)
GSWBUNDLE_INSTALL_DIR = $(GNUSTEP_INSTALLATION_DIR)/Libraries
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

.PHONY: internal-gswbundle-all \
        internal-gswbundle-clean \
        internal-gswbundle-distclean \
        internal-gswbundle-install \
        internal-gswbundle-uninstall \
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
#ALL_GSWBUNDLE_LIBS = \
    $(shell $(WHICH_LIB_SCRIPT) $(ALL_LIB_DIRS) $(ALL_GSWBUNDLE_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

internal-gswbundle-all:: before-$(GNUSTEP_INSTANCE)-all \
                      $(GNUSTEP_OBJ_DIR) \
                      build-bundle-dir \
                      build-bundle \
                      after-$(GNUSTEP_INSTANCE)-all

GSWBUNDLE_DIR_NAME = $(GNUSTEP_INSTANCE:=$(GSWBUNDLE_EXTENSION))
GSWBUNDLE_FILE = \
    $(GSWBUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/$(GNUSTEP_INSTANCE)
GSWBUNDLE_RESOURCE_DIRS = $(foreach d, $(RESOURCE_DIRS), $(GSWBUNDLE_DIR_NAME)/Resources/$(d))
GSWBUNDLE_WEBSERVER_RESOURCE_DIRS =  $(foreach d, $(WEBSERVER_RESOURCE_DIRS), $(GSWBUNDLE_DIR_NAME)/WebServerResources/$(d))

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
	                $(ALL_GSWBUNDLE_LIBS)

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
override PRINCIPAL_CLASS = $(GNUSTEP_INSTANCE)
endif

$(GSWBUNDLE_DIR_NAME)/bundle-info.plist: $(GSWBUNDLE_DIR_NAME)
	@(cd $(GSWBUNDLE_DIR_NAME); $(LN_S) -f ../bundle-info.plist .)

HAS_GSWCOMPONENTS = $($(GNUSTEP_INSTANCE)_HAS_GSWCOMPONENTS)

$(GSWBUNDLE_DIR_NAME)/Resources/Info-gnustep.plist: $(GSWBUNDLE_DIR_NAME)/Resources
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_INSTANCE)\";"; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  if [ "$(HAS_GSWCOMPONENTS)" != "" ]; then \
	    echo "  HasGSWComponents = \"$(HAS_GSWCOMPONENTS)\";"; \
	  fi; \
	  echo "}") >$@

$(GSWBUNDLE_DIR_NAME)/Resources:
	@$(MKDIRS) $@

$(GSWBUNDLE_DIR_NAME)/WebServerResources:
	@$(MKDIRS) $@

internal-gswbundle-install:: $(GSWBUNDLE_INSTALL_DIR) shared-instance-headers-install
	rm -rf $(GSWBUNDLE_INSTALL_DIR)/$(GSWBUNDLE_DIR_NAME); \
	$(TAR) ch --exclude=CVS --to-stdout $(GSWBUNDLE_DIR_NAME) | (cd $(GSWBUNDLE_INSTALL_DIR); $(TAR) xf -)
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) $(GSWBUNDLE_INSTALL_DIR)/$(GSWBUNDLE_DIR_NAME)
endif
ifeq ($(strip),yes)
	$(STRIP) $(GSWBUNDLE_INSTALL_DIR)/$(GSWBUNDLE_FILE) 
endif

$(GSWBUNDLE_INSTALL_DIR)::
	@$(MKINSTALLDIRS) $@

internal-gswbundle-uninstall:: shared-instance-headers-uninstall
	rm -rf $(GSWBUNDLE_INSTALL_DIR)/$(GSWBUNDLE_DIR_NAME)

## Local variables:
## mode: makefile
## End:
