#
#   application.make
#
#   Makefile rules to build GNUstep-based applications.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Manuel Guesdon <mguesdon@sbuilders.com>
#   Based on application.make by Ovidiu Predescu <ovidiu@net-community.com>
#   Based on gswapp.make by Helge Hess, MDlink online service center GmbH.
#   Based on the original version by Scott Christley.
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
ifeq ($(GSWAPP_MAKE_LOADED),)
GSWAPP_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

GNUSTEP_GSWAPPS=$(GNUSTEP_INSTALLATION_DIR)/GSWApps

#
# The name of the application is in the GSWAPP_NAME variable.
# The list of languages the app is localized in are in xxx_LANGUAGES <==
# The list of application resource file are in xxx_RESOURCE_FILES
# The list of localized application resource file are in 
#  xxx_LOCALIZED_RESOURCE_FILES <==
# The list of application resource directories are in xxx_RESOURCE_DIRS
# The list of application web server resource directories are in 
#  xxx_WEBSERVER_RESOURCE_DIRS <==
# The list of localized application web server resource directories are in 
#  xxx_LOCALIZED_WEBSERVER_RESOURCE_DIRS
# where xxx is the application name <==

GSWAPP_NAME:=$(strip $(GSWAPP_NAME))

# Determine the application directory extension
ifeq ($(profile), yes)
  GSWAPP_EXTENSION=profile
else
  ifeq ($(debug), yes)
    GSWAPP_EXTENSION=debug
  else
    GSWAPP_EXTENSION=gswa
  endif
endif

ifeq ($(INTERNAL_gswapp_NAME),)
# This part gets included by the first invoked make process.
internal-all:: $(GSWAPP_NAME:=.all.gswapp.variables)

internal-install:: $(GSWAPP_NAME:=.install.gswapp.variables)

internal-uninstall:: $(GSWAPP_NAME:=.uninstall.gswapp.variables)

internal-clean:: $(GSWAPP_NAME:=.clean.gswapp.subprojects)
	rm -rf $(GNUSTEP_OBJ_DIR)
ifeq ($(OBJC_COMPILER), NeXT)
	rm -f *.iconheader
	for f in *.$(GSWAPP_EXTENSION); do \
	  rm -f $$f/`basename $$f .$(GSWAPP_EXTENSION)`; \
	done
else
ifeq ($(GNUSTEP_FLATTENED),)
	rm -rf *.$(GSWAPP_EXTENSION)/$(GNUSTEP_TARGET_LDIR)
else
	rm -rf *.$(GSWAPP_EXTENSION)
endif
endif

internal-distclean:: $(GSWAPP_NAME:=.distclean.gswapp.subprojects)
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj *.gswa *.debug *.profile *.iconheader

$(GSWAPP_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
	            $@.all.gswapp.variables

else

.PHONY: internal-gswapp-all \
        internal-gswapp-install \
        internal-gswapp-uninstall \
        before-$(TARGET)-all \
        after-$(TARGET)-all \
        gswapp-components \
        gswapp-webresource-dir \
        gswapp-webresource-files \
        gswapp-localized-webresource-files \
        gswapp-resource-dir \
        gswapp-resource-files \
        gswapp-localized-resource-files

# Libraries that go before the WO libraries
ALL_GSW_LIBS =								\
    $(shell $(WHICH_LIB_SCRIPT)						\
	$(LIB_DIRS_NO_SYSTEM)						\
	$(ADDITIONAL_GSW_LIBS) $(AUXILIARY_GSW_LIBS) $(GSW_LIBS)	\
	$(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS)			\
	$(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS)	\
        $(OBJC_LIBS) $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)		\
	debug=$(debug) profile=$(profile) shared=$(shared)		\
	libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))


# Don't include these definitions the first time make is invoked. This part is
# included when make is invoked the second time from the %.build rule (see
# rules.make).
GSWAPP_DIR_NAME = $(INTERNAL_gswapp_NAME:=.$(GSWAPP_EXTENSION))
GSWAPP_RESOURCE_DIRS =  $(foreach d, $(RESOURCE_DIRS), $(GSWAPP_DIR_NAME)/Resources/$(d))
GSWAPP_WEBSERVER_RESOURCE_DIRS =  $(foreach d, $(WEBSERVER_RESOURCE_DIRS), $(GSWAPP_DIR_NAME)/WebServerResources/$(d))
ifeq ($(strip $(LANGUAGES)),)
  override LANGUAGES="English"
endif

# Support building NeXT applications
ifneq ($(OBJC_COMPILER), NeXT)
GSWAPP_FILE = \
    $(GSWAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/$(INTERNAL_gswapp_NAME)$(EXEEXT)
else
GSWAPP_FILE = $(GSWAPP_DIR_NAME)/$(INTERNAL_gswapp_NAME)$(EXEEXT)
endif

#
# Internal targets
#

$(GSWAPP_FILE): $(OBJ_FILES_TO_LINK)
	$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ $(OBJ_FILES_TO_LINK) \
	    $(ALL_LIB_DIRS) $(ALL_GSW_LIBS)

ifeq ($(OBJC_COMPILER), NeXT)
	@$(TRANSFORM_PATHS_SCRIPT) $(subst -L,,$(ALL_LIB_DIRS)) \
		>$(GSWAPP_DIR_NAME)/library_paths.openapp
# This is a hack for OPENSTEP systems to remove the iconheader file
# automatically generated by the makefile package.
	rm -f $(INTERNAL_gswapp_NAME).iconheader
else
	@$(TRANSFORM_PATHS_SCRIPT) $(subst -L,,$(ALL_LIB_DIRS)) \
	>$(GSWAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/library_paths.openapp
endif

#
# Compilation targets
#
ifeq ($(OBJC_COMPILER), NeXT)
internal-gswapp-all:: \
	before-$(TARGET)-all \
	$(GNUSTEP_OBJ_DIR) $(GSWAPP_DIR_NAME) $(GSWAPP_FILE) \
	gswapp-components \
	gswapp-localized-webresource-files \
	gswapp-webresource-files \
	gswapp-localized-resource-files \
	gswapp-resource-files \
	$(GSWAPP_DIR_NAME)/$(GSWAPP_NAME).sh \
	after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

$(INTERNAL_gswapp_NAME).iconheader:
	@(echo "F	$(INTERNAL_gswapp_NAME).$(GSWAPP_EXTENSION)	$(INTERNAL_gswapp_NAME)	$(GSWAPP_EXTENSION)"; \
	  echo "F	$(INTERNAL_gswapp_NAME)	$(INTERNAL_gswapp_NAME)	app") >$@

$(GSWAPP_DIR_NAME):
	mkdir $@
else

internal-gswapp-all:: \
   before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
   $(GSWAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR) $(GSWAPP_FILE) \
   gswapp-components \
   gswapp-localized-webresource-files \
   gswapp-webresource-files \
   gswapp-localized-resource-files \
   gswapp-resource-files \
   $(GSWAPP_DIR_NAME)/$(GSWAPP_NAME).sh \
   after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

$(GSWAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR):
	@$(MKDIRS) $(GSWAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)
endif

ifeq ($(GSWAPP_NAME)_GEN_SCRIPT,yes) #<==
$(GSWAPP_DIR_NAME)/$(GSWAPP_NAME).sh: $(GSWAPP_DIR_NAME)
	@(echo "#!/bin/sh"; \
	  echo '# Automatically generated, do not edit!'; \
	  echo '$${GNUSTEP_HOST_LDIR}/$(INTERNAL_gswapp_NAME) $$1 $$2 $$3 $$4 $$5 $$6 $$7 $$8') >$@
	chmod +x $@
else
$(GSWAPP_DIR_NAME)/$(GSWAPP_NAME).sh:

endif

gswapp-components:: $(GSWAPP_DIR_NAME)/Resources
ifneq ($(strip $(COMPONENTS)),)
	@ echo "Linking components into the application wrapper..."; \
        cd $(GSWAPP_DIR_NAME)/Resources; \
        for component in $(COMPONENTS); do \
	  if [ -d ../../$$component ]; then \
	     $(LN_S) -f ../../$$component ./;\
	  fi; \
        done; \
	echo "Linking localized components into the application wrapper..."; \
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
	done
endif

gswapp-webresource-dir:: $(GSWAPP_WEBSERVER_RESOURCE_DIRS)
ifneq ($(strip $(WEBSERVER_RESOURCE_DIRS)),)
	@ echo "Linking webserver Resource Dirs into the application wrapper..."; \
        cd $(GSWAPP_DIR_NAME)/Resources; \
        for dir in $(WEBSERVER_RESOURCE_DIRS); do \
	  if [ -d ../../$$dir ]; then \
	     $(LN_S) -f ../../$$dir ./;\
	  fi; \
        done;
endif

$(GSWAPP_WEBSERVER_RESOURCE_DIRS):
	#@$(MKDIRS) $(GSWAPP_WEBSERVER_RESOURCE_DIRS)

gswapp-webresource-files:: $(GSWAPP_DIR_NAME)/WebServerResources \
                           gswapp-webresource-dir
ifneq ($(strip $(WEBSERVER_RESOURCE_FILES)),)
	@echo "Linking webserver resources into the application wrapper..."; \
        cd $(GSWAPP_DIR_NAME)/WebServerResources; \
        for ff in $(WEBSERVER_RESOURCE_FILES); do \
	  $(LN_S) -f ../../WebServerResources/$$ff .;\
        done
endif

gswapp-localized-webresource-files:: $(GSWAPP_DIR_NAME)/WebServerResources gswapp-webresource-dir
ifneq ($(strip $(LOCALIZED_WEBSERVER_RESOURCE_FILES)),)
	@ echo "Linking localized web resources into the application wrapper..."; \
	cd $(GSWAPP_DIR_NAME)/WebServerResources; \
	for l in $(LANGUAGES); do \
	  if [ -d ../../WebServerResources/$$l.lproj ]; then \
	    $(MKDIRS) $$l.lproj;\
	    cd $$l.lproj; \
	    for f in $(LOCALIZED_WEBSERVER_RESOURCE_FILES); do \
	      if [ -f ../../../WebServerResources/$$l.lproj/$$f ]; then \
	        if [ ! -r $$f ]; then \
	          $(LN_S) ../../../WebServerResources/$$l.lproj/$$f $$f;\
	        fi;\
	      fi;\
	    done;\
	    cd ..; \
	  else\
	   echo "Warning - WebServerResources/$$l.lproj not found - ignoring";\
	  fi;\
	done
endif

gswapp-resource-dir:: $(GSWAPP_RESOURCE_DIRS)
ifneq ($(strip $(RESOURCE_DIRS)),)
	@ echo "Linking Resource Dirs into the application wrapper..."; \
        cd $(GSWAPP_DIR_NAME)/Resources; \
        for dir in $(RESOURCE_DIRS); do \
	  if [ -d ../../$$dir ]; then \
	     $(LN_S) -f ../../$$dir ./;\
	  fi; \
        done;
endif

$(GSWAPP_RESOURCE_DIRS):
	#@$(MKDIRS) $(GSWAPP_RESOURCE_DIRS)

gswapp-resource-files:: $(GSWAPP_DIR_NAME)/Resources/Info-gnustep.plist \
                        gswapp-resource-dir
ifneq ($(strip $(RESOURCE_FILES)),)
	@ echo "Linking resources into the application wrapper..."; \
        cd $(GSWAPP_DIR_NAME)/Resources/; \
        for ff in $(RESOURCE_FILES); do \
	  echo $$ff; \
	  $(LN_S) -f ../../$$ff .;\
        done
endif

gswapp-localized-resource-files:: $(GSWAPP_DIR_NAME)/Resources \
                                  gswapp-resource-dir
ifneq ($(strip $(LOCALIZED_RESOURCE_FILES)),)
	@ echo "Linking localized resources into the application wrapper..."; \
        cd $(GSWAPP_DIR_NAME)/Resources; \
        for l in $(LANGUAGES); do \
	  if [ -d ../../$$l.lproj ]; then 
	    $(MKDIRS) $$l.lproj; \
	    cd $$l.lproj; \
	    for f in $(LOCALIZED_RESOURCE_FILES); do \
              if [ -f ../../../$$l.lproj/$$f ]; then \
	        echo $$l.lproj/$$ff; \
	        $(LN_S) -f ../../../$$l.lproj/$$f .;\
	      fi;\
	    done;\
	    cd ..; \
	  else \
	   echo "Warning - $$l.lproj not found - ignoring";\
	  fi;\
	done
endif

$(GSWAPP_DIR_NAME)/Resources/Info-gnustep.plist: $(GSWAPP_DIR_NAME)/Resources
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(INTERNAL_gswapp_NAME)\";"; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  if [ "$(HAS_GSWCOMPONENTS)" != "" ]; then \
			  echo "  HasGSWComponents = \"$(HAS_GSWCOMPONENTS)\";"; \
	  fi; \
	  if [ "$(MAIN_MODEL_FILE)" = "" ]; then \
	    echo "  NSMainNibFile = \"\";"; \
	  else \
	    echo "  NSMainNibFile = \"$(subst .gmodel,,$(subst .gorm,,$(subst .nib,,$(MAIN_MODEL_FILE))))\";"; \
	  fi; \
	  if [ -r "$(INTERNAL_gswapp_NAME)Info.plist" ]; then \
	    cat $(INTERNAL_gswapp_NAME)Info.plist; \
	  fi; \
	  if [ "$(GSWAPP_INFO_PLIST)" != "" ]; then \
	    cat $(GSWAPP_INFO_PLIST); \
	  fi; \
	  echo "}") >$@

$(GSWAPP_DIR_NAME)/Resources:
	@$(MKDIRS) $@

$(GSWAPP_DIR_NAME)/WebServerResources:
	@$(MKDIRS) $@

internal-gswapp-install::
	@($(MKINSTALLDIRS) $(GNUSTEP_GSWAPPS); \
	rm -rf $(GNUSTEP_GSWAPPS)/$(GSWAPP_DIR_NAME); \
	$(TAR) ch --exclude=CVS --to-stdout $(GSWAPP_DIR_NAME) | (cd $(GNUSTEP_GSWAPPS); $(TAR) xf -))
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) $(GNUSTEP_GSWAPPS)/$(GSWAPP_DIR_NAME)
endif
ifeq ($(strip),yes)
	$(STRIP) $(GNUSTEP_GSWAPPS)/$(GSWAPP_FILE) 
endif

internal-gswapp-uninstall::
	(cd $(GNUSTEP_GSWAPPS); rm -rf $(GSWAPP_DIR_NAME))

endif

endif

## Local variables:
## mode: makefile
## End:
