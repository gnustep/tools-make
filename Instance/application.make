#   -*-makefile-*-
#   application.make
#
#   Instance Makefile rules to build GNUstep-based applications.
#
#   Copyright (C) 1997, 2001, 2002 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola@brainstorm.co.uk>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
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

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
  include $(GNUSTEP_MAKEFILES)/rules.make
endif

#
# The name of the application is in the APP_NAME variable.
# The list of application resource directories is in xxx_RESOURCE_DIRS
# The list of application resource files is in xxx_RESOURCE_FILES
# The list of localized resource files is in xxx_LOCALIZED_RESOURCE_FILES
# The list of supported languages is in xxx_LANGUAGES
# The name of the application icon (if any) is in xxx_APPLICATION_ICON
# The name of the app class is xxx_PRINCIPAL_CLASS (defaults to NSApplication).
# The name of a file containing info.plist entries to be inserted into
# Info-gnustep.plist (if any) is xxxInfo.plist
# where xxx is the application name
#

.PHONY: internal-app-all_ \
        internal-app-install_ \
        internal-app-uninstall_ \
        internal-app-copy_into_dir \
        internal-application-build-template

#
# Determine where to install.  By default, install into GNUSTEP_APPS.
#
ifneq ($($(GNUSTEP_INSTANCE)_INSTALL_DIR),)
  APP_INSTALL_DIR = $($(GNUSTEP_INSTANCE)_INSTALL_DIR)
endif

ifeq ($(APP_INSTALL_DIR),)
  APP_INSTALL_DIR = $(GNUSTEP_APPS)
endif

ALL_GUI_LIBS =								     \
    $(shell $(WHICH_LIB_SCRIPT)						     \
     $(ALL_LIB_DIRS)							     \
     $(ADDITIONAL_GUI_LIBS) $(AUXILIARY_GUI_LIBS) $(GUI_LIBS)		     \
     $(BACKEND_LIBS) $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS)	     \
     $(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS) \
     $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)				     \
        debug=$(debug) profile=$(profile) shared=$(shared)		     \
	libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

APP_DIR_NAME = $(GNUSTEP_INSTANCE:=.$(APP_EXTENSION))

#
# Now include the standard resource-bundle routines from Shared/bundle.make
#

ifneq ($(FOUNDATION_LIB),nx)
  # GNUstep bundle
  GNUSTEP_SHARED_BUNDLE_RESOURCE_PATH = $(APP_DIR_NAME)/Resources
  APP_INFO_PLIST_FILE = $(APP_DIR_NAME)/Resources/Info-gnustep.plist
else
  # OSX bundle
  GNUSTEP_SHARED_BUNDLE_RESOURCE_PATH = $(APP_DIR_NAME)/Contents/Resources
  APP_INFO_PLIST_FILE = $(APP_DIR_NAME)/Contents/Info.plist
endif
GNUSTEP_SHARED_BUNDLE_MAIN_PATH = $(APP_DIR_NAME)
GNUSTEP_SHARED_BUNDLE_INSTALL_DIR = $(APP_INSTALL_DIR)
include $(GNUSTEP_MAKEFILES)/Instance/Shared/bundle.make

# Support building NeXT applications
ifneq ($(OBJC_COMPILER), NeXT)
APP_FILE = \
    $(APP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/$(GNUSTEP_INSTANCE)$(EXEEXT)
else
APP_FILE = $(APP_DIR_NAME)/$(GNUSTEP_INSTANCE)$(EXEEXT)
endif

#
# Internal targets
#

$(APP_FILE): $(OBJ_FILES_TO_LINK)
	$(ECHO_LINKING)$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ $(OBJ_FILES_TO_LINK)\
	      $(ALL_GUI_LIBS)$(END_ECHO)
ifeq ($(OBJC_COMPILER), NeXT)
	@$(TRANSFORM_PATHS_SCRIPT) $(subst -L,,$(ALL_LIB_DIRS)) \
		>$(APP_DIR_NAME)/library_paths.openapp
else
	@$(TRANSFORM_PATHS_SCRIPT) $(subst -L,,$(ALL_LIB_DIRS)) \
	>$(APP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/library_paths.openapp
endif

#
# Compilation targets
#

ifeq ($(FOUNDATION_LIB), nx)
internal-app-all_:: $(GNUSTEP_OBJ_DIR) \
                    $(APP_DIR_NAME) \
                    $(APP_FILE) \
                    shared-instance-bundle-all \
                    $(APP_INFO_PLIST_FILE)

$(APP_DIR_NAME):
	@$(MKDIRS) $@

else

internal-app-all_:: $(GNUSTEP_OBJ_DIR) \
                    $(APP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR) \
                    $(APP_FILE) \
                    internal-application-build-template \
                    $(APP_DIR_NAME)/Resources \
                    $(APP_INFO_PLIST_FILE) \
                    $(APP_DIR_NAME)/Resources/$(GNUSTEP_INSTANCE).desktop \
                    shared-instance-bundle-all

$(APP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR):
	@$(MKDIRS) $@

ifeq ($(GNUSTEP_FLATTENED),)
internal-application-build-template: $(APP_DIR_NAME)/$(GNUSTEP_INSTANCE)

$(APP_DIR_NAME)/$(GNUSTEP_INSTANCE):
	@cp $(GNUSTEP_MAKEFILES)/executable.template \
	   $(APP_DIR_NAME)/$(GNUSTEP_INSTANCE); \
	chmod a+x $(APP_DIR_NAME)/$(GNUSTEP_INSTANCE)
else
internal-application-build-template:

endif
endif

PRINCIPAL_CLASS = $(strip $($(GNUSTEP_INSTANCE)_PRINCIPAL_CLASS))

ifeq ($(PRINCIPAL_CLASS),)
  PRINCIPAL_CLASS = NSApplication
endif

APPLICATION_ICON = $($(GNUSTEP_INSTANCE)_APPLICATION_ICON)

MAIN_MODEL_FILE = $(strip $(subst .gmodel,,$(subst .gorm,,$(subst .nib,,$($(GNUSTEP_INSTANCE)_MAIN_MODEL_FILE)))))


# We must recreate Info.plist if PRINCIPAL_CLASS and/or
# APPLICATION_ICON and/or MAIN_MODEL_FILE has changed since last time
# we built Info.plist.  We use stamp-string.make, which will store the
# variables in a stamp file inside GNUSTEP_STAMP_DIR, and rebuild
# Info.plist iff GNUSTEP_STAMP_STRING changes.
GNUSTEP_STAMP_STRING = $(PRINCIPAL_CLASS)-$(APPLICATION_ICON)-$(MAIN_MODEL_FILE)
GNUSTEP_STAMP_DIR = $(APP_DIR_NAME)

ifneq ($(FOUNDATION_LIB),nx)
# Only for efficiency
$(GNUSTEP_STAMP_DIR): $(APP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)
endif

include $(GNUSTEP_MAKEFILES)/Instance/Shared/stamp-string.make

ifeq ($(FOUNDATION_LIB), nx)
$(APP_INFO_PLIST_FILE): $(GNUSTEP_STAMP_DEPEND)
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_INSTANCE)\";"; \
	  echo "  NSMainNibFile = \"$(MAIN_MODEL_FILE)\";"; \
	  if [ "$(APPLICATION_ICON)" != "" ]; then \
	    echo "  NSIcon = \"$(APPLICATION_ICON)\";"; \
	  fi; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "}") >$@
else
$(APP_INFO_PLIST_FILE): $(GNUSTEP_STAMP_DEPEND)
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_INSTANCE)\";"; \
	  echo "  NSMainNibFile = \"$(MAIN_MODEL_FILE)\";"; \
	  if [ "$(APPLICATION_ICON)" != "" ]; then \
	    echo "  NSIcon = \"$(APPLICATION_ICON)\";"; \
	  fi; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "}") >$@
	@if [ -r "$(GNUSTEP_INSTANCE)Info.plist" ]; then \
	   plmerge $@ $(GNUSTEP_INSTANCE)Info.plist; \
	 fi
endif

$(APP_DIR_NAME)/Resources/$(GNUSTEP_INSTANCE).desktop: \
		$(APP_DIR_NAME)/Resources/Info-gnustep.plist
	@pl2link $^ $(APP_DIR_NAME)/Resources/$(GNUSTEP_INSTANCE).desktop


internal-app-copy_into_dir:: shared-instance-bundle-copy_into_dir

# install/uninstall targets

$(APP_INSTALL_DIR):
	$(MKINSTALLDIRS) $@

internal-app-install_:: shared-instance-bundle-install
ifeq ($(strip),yes)
	$(STRIP) $(APP_INSTALL_DIR)/$(APP_FILE)
endif

internal-app-uninstall_:: shared-instance-bundle-uninstall

include $(GNUSTEP_MAKEFILES)/Instance/Shared/strings.make
