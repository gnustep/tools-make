#
#   woapp.make
#
#   Makefile rules to build GNUstep-based WebObjects applications.
#
#   Copyright (C) 1999 Helge Hess, MDlink online service center GmbH
#
#   Author: Helge Hess <Helge.Hess@mdlink.de>
#   Based on application.make by Ovidiu Predescu <ovidiu@net-community.com>
#   which was: Based on the original version by Scott Christley.
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
ifeq ($(WOAPP_MAKE_LOADED),)
WOAPP_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
include $(GNUSTEP_MAKEFILES)/rules.make

#
# The name of the application is in the WOAPP_NAME variable.
# The list of languages the app is localized in are in xxx_LANGUAGES
# The list of application resource file are in xxx_RESOURCE_FILES
# The list of localized application resource file are in 
#  xxx_LOCALIZED_RESOURCE_FILES
# The list of application resource directories are in xxx_RESOURCE_DIRS
# The list of application web server resource directories are in 
#  xxx_WEBSERVER_RESOURCE_DIRS
# The list of localized application web server resource directories are in 
#  xxx_LOCALIZED_WEBSERVER_RESOURCE_DIRS
# where xxx is the application name
#

# Determine the application directory extension (not used currently)
ifeq ($(profile), yes)
  WOAPP_EXTENSION=profile
else
  ifeq ($(debug), yes)
    WOAPP_EXTENSION=debug
  else
    WOAPP_EXTENSION=woa
  endif
endif

WOAPP_EXTENSION=woa

ifeq ($(INTERNAL_woapp_NAME),)
# This part gets included by the first invoked make process.
internal-all:: $(WOAPP_NAME:=.all.woapp.variables)

internal-install:: $(WOAPP_NAME:=.install.woapp.variables)

internal-uninstall:: $(WOAPP_NAME:=.uninstall.woapp.variables)

internal-clean:: $(WOAPP_NAME:=.clean.woapp.variables)

internal-distclean:: $(WOAPP_NAME:=.distclean.woapp.variables)

$(WOAPP_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory $@.all.woapp.variables

else

# Libraries that go before the WO libraries
ALL_WO_LIBS = \
	$(ADDITIONAL_WO_LIBS) \
	$(AUXILIARY_WO_LIBS) \
	$(WO_LIBS) \
	$(ADDITIONAL_TOOL_LIBS) \
	$(AUXILIARY_TOOL_LIBS) \
	$(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS) \
	$(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)

ALL_WO_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_WO_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

ifeq ($(WITH_DLL),yes)
TTMP_LIBS := $(ALL_WO_LIBS)
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
endif

# Don't include these definitions the first time make is invoked. This part is
# included when make is invoked the second time from the %.build rule (see
# rules.make).
WOAPP_DIR_NAME = $(INTERNAL_woapp_NAME:=.$(WOAPP_EXTENSION))
WOAPP_RESOURCE_DIRS =  $(foreach d, $(RESOURCE_DIRS), $(WOAPP_DIR_NAME)/Resources/$(d))
WOAPP_WEBSERVER_RESOURCE_DIRS =  $(foreach d, $(WEBSERVER_RESOURCE_DIRS), $(WOAPP_DIR_NAME)/WebServerResources/$(d))
ifeq ($(strip $(COMPONENTS)),)
  override COMPONENTS=""
endif
ifeq ($(strip $(RESOURCE_FILES)),)
  override RESOURCE_FILES=""
endif
ifeq ($(strip $(WEBSERVER_RESOURCE_FILES)),)
  override WEBSERVER_RESOURCE_FILES=""
endif
ifeq ($(strip $(LANGUAGES)),)
  override LANGUAGES="English"
endif
ifeq ($(strip $(LOCALIZED_RESOURCE_FILES)),)
  override LOCALIZED_RESOURCE_FILES=""
endif
ifeq ($(strip $(LOCALIZED_WEBSERVER_RESOURCE_FILES)),)
  override LOCALIZED_WEBSERVER_RESOURCE_FILES=""
endif

# Support building NeXT applications
ifneq ($(OBJC_COMPILER), NeXT)
WOAPP_FILE = \
    $(WOAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/$(INTERNAL_woapp_NAME)$(EXEEXT)
else
WOAPP_FILE = $(WOAPP_DIR_NAME)/$(INTERNAL_woapp_NAME)$(EXEEXT)
endif

#
# Internal targets
#

$(WOAPP_FILE): $(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(SUBPROJECT_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$@ $(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(SUBPROJECT_OBJ_FILES) $(ALL_LIB_DIRS) $(ALL_WO_LIBS)
ifeq ($(OBJC_COMPILER), NeXT)
	@$(TRANSFORM_PATHS_SCRIPT) `echo $(ALL_LIB_DIRS) | sed 's/-L//g'` \
		>$(WOAPP_DIR_NAME)/library_paths.openapp
# This is a hack for OPENSTEP systems to remove the iconheader file
# automatically generated by the makefile package.
	rm -f $(INTERNAL_woapp_NAME).iconheader
else
	@$(TRANSFORM_PATHS_SCRIPT) `echo $(ALL_LIB_DIRS) | sed 's/-L//g'` \
	>$(WOAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/library_paths.openapp
endif

#
# Compilation targets
#
ifeq ($(OBJC_COMPILER), NeXT)
internal-woapp-all:: \
	before-$(TARGET)-all \
	$(GNUSTEP_OBJ_DIR) $(WOAPP_DIR_NAME) $(WOAPP_FILE) \
	woapp-components \
	woapp-localized-webresource-files \
	woapp-webresource-files \
	woapp-localized-resource-files \
	woapp-resource-files \
	$(WOAPP_DIR_NAME)/$(WOAPP_NAME).sh \
	after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

$(INTERNAL_woapp_NAME).iconheader:
	@(echo "F	$(INTERNAL_woapp_NAME).$(WOAPP_EXTENSION)	$(INTERNAL_woapp_NAME)	$(WOAPP_EXTENSION)"; \
	  echo "F	$(INTERNAL_woapp_NAME)	$(INTERNAL_woapp_NAME)	app") >$@

$(WOAPP_DIR_NAME):
	mkdir $@
else

internal-woapp-all:: \
   before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
   $(WOAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR) $(WOAPP_FILE) \
   woapp-components \
   woapp-localized-webresource-files \
   woapp-webresource-files \
   woapp-localized-resource-files \
   woapp-resource-files \
   $(WOAPP_DIR_NAME)/$(WOAPP_NAME).sh \
   after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

$(WOAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR):
	@$(MKDIRS) $(WOAPP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)
endif

ifeq ($(WOAPP_NAME)_GEN_SCRIPT,yes)
$(WOAPP_DIR_NAME)/$(WOAPP_NAME).sh: $(WOAPP_DIR_NAME)
	@(echo "#!/bin/sh"; \
	  echo '# Automatically generated, do not edit!'; \
	  echo '$${GNUSTEP_HOST_LDIR}/$(INTERNAL_woapp_NAME) $$1 $$2 $$3 $$4 $$5 $$6 $$7 $$8') >$@
	chmod +x $@
else
$(WOAPP_DIR_NAME)/$(WOAPP_NAME).sh:

endif

woapp-components:: $(WOAPP_DIR_NAME)
	@(if [ "$(COMPONENTS)" != "" ]; then \
	  echo "Linking components into the application wrapper..."; \
          cd $(WOAPP_DIR_NAME); \
          for component in $(COMPONENTS); do \
	    $(LN_S) -f ../$$component .;\
          done; \
	fi)

woapp-webresource-dir::
	@$(MKDIRS) $(WOAPP_WEBSERVER_RESOURCE_DIRS)

woapp-webresource-files:: $(WOAPP_DIR_NAME)/WebServerResources woapp-webresource-dir
	@(if [ "$(WEBSERVER_RESOURCE_FILES)" != "" ]; then \
	  echo "Linking webserver resources into the application wrapper..."; \
          cd $(WOAPP_DIR_NAME)/WebServerResources; \
          for ff in $(WEBSERVER_RESOURCE_FILES); do \
	    $(LN_S) -f ../../$$ff .;\
          done; \
	fi)

woapp-localized-webresource-files:: $(WOAPP_DIR_NAME)/WebServerResources woapp-webresource-dir
	@(if [ "$(LOCALIZED_WEBSERVER_RESOURCE_FILES)" != "" ]; then \
	  echo "Linking localized web resources into the application wrapper..."; \
          cd $(WOAPP_DIR_NAME)/WebServerResources; \
          for l in $(LANGUAGES); do \
	    if [ ! -f $$l.lproj ]; then $(MKDIRS) $$l.lproj; fi; \
	    cd $$l.lproj; \
	    for f in $(LOCALIZED_WEBSERVER_RESOURCE_FILES); do \
              if [ -f ../../../$$l.lproj/$$f ]; then \
                if [ ! -r $$f ]; then \
		  $(LN_S) ../../../$$l.lproj/$$f $$f;\
		fi;\
              fi;\
            done;\
	    cd ..; \
          done;\
	fi)

woapp-resource-dir::
	@$(MKDIRS) $(WOAPP_RESOURCE_DIRS)

woapp-resource-files:: $(WOAPP_DIR_NAME)/Resources/Info-gnustep.plist woapp-resource-dir
	@(if [ "$(RESOURCE_FILES)" != "" ]; then \
	  echo "Linking resources into the application wrapper..."; \
          cd $(WOAPP_DIR_NAME)/Resources; \
          for ff in $(RESOURCE_FILES); do \
	    $(LN_S) -f ../../$$ff .;\
          done; \
	fi)

woapp-localized-resource-files:: $(WOAPP_DIR_NAME)/Resources woapp-resource-dir
	@(if [ "$(LOCALIZED_RESOURCE_FILES)" != "" ]; then \
	  echo "Linking localized resources into the application wrapper..."; \
          cd $(WOAPP_DIR_NAME)/Resources; \
          for l in $(LANGUAGES); do \
	    if [ ! -f $$l.lproj ]; then $(MKDIRS) $$l.lproj; fi; \
	    cd $$l.lproj; \
	    for f in $(LOCALIZED_RESOURCE_FILES); do \
              if [ -f ../../../$$l.lproj/$$f ]; then \
		$(LN_S) -f ../../../$$l.lproj/$$f .;\
              fi;\
            done;\
	    cd ..; \
          done;\
	fi)

$(WOAPP_DIR_NAME)/Resources/Info-gnustep.plist: $(WOAPP_DIR_NAME)/Resources
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(INTERNAL_woapp_NAME)\";"; \
	  echo "  NSPrincipalClass = OWApplication;"; \
	  echo "}") >$@

$(WOAPP_DIR_NAME)/Resources:
	@$(MKDIRS) $@

$(WOAPP_DIR_NAME)/WebServerResources:
	@$(MKDIRS) $@

internal-woapp-install:: internal-woapp-all
	@$(MKDIRS) $(GNUSTEP_WOAPPS)
	rm -rf $(GNUSTEP_WOAPPS)/$(WOAPP_DIR_NAME)
	$(TAR) ch --exclude=CVS --to-stdout $(WOAPP_DIR_NAME) | (cd $(GNUSTEP_WOAPPS); $(TAR) xf -)

internal-woapp-uninstall::
	(cd $(GNUSTEP_WOAPPS); rm -rf $(WOAPP_DIR_NAME))

#
# Cleaning targets
#
internal-woapp-clean::
	rm -rf $(GNUSTEP_OBJ_PREFIX)/$(GNUSTEP_TARGET_LDIR)
ifeq ($(OBJC_COMPILER), NeXT)
	rm -f *.iconheader
	for f in *.$(WOAPP_EXTENSION); do \
	  rm -f $$f/`basename $$f .$(WOAPP_EXTENSION)`; \
	done
else
	rm -rf *.$(WOAPP_EXTENSION)/$(GNUSTEP_TARGET_LDIR)
endif


internal-woapp-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj *.woa *.debug *.profile *.iconheader

endif

endif
# application.make loaded
