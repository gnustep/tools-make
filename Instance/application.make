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

ifneq ($(FOUNDATION_LIB), apple)
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

ifneq ($(FOUNDATION_LIB), apple)
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
ifeq ($(FOUNDATION_LIB), apple)
	@$(TRANSFORM_PATHS_SCRIPT) $(subst -L,,$(ALL_LIB_DIRS)) \
		>$(APP_DIR_NAME)/library_paths.openapp
else
	@$(TRANSFORM_PATHS_SCRIPT) $(subst -L,,$(ALL_LIB_DIRS)) \
	>$(APP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/library_paths.openapp
endif

#
# Compilation targets
#

ifeq ($(FOUNDATION_LIB), apple)
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

ifneq ($(FOUNDATION_LIB), apple)
# Only for efficiency
$(GNUSTEP_STAMP_DIR): $(APP_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)
endif

include $(GNUSTEP_MAKEFILES)/Instance/Shared/stamp-string.make

# FIXME: Missing dependency on $(GNUSTEP_INSTANCE)Info.plist files

# You can have a single xxxInfo.plist for both GNUstep and Apple.

# Often enough, you can just put in it all fields required by both
# GNUstep and Apple; if there is a conflict, you can add
# xxx_PREPROCESS_INFO_PLIST = yes to your GNUmakefile, and provide a
# xxxInfo.cplist (please note the suffix!) - that file is
# automatically run through the C preprocessor to generate a
# xxxInfo.plist file from it.  The preprocessor will define GNUSTEP
# when using gnustep-base, APPLE when using Apple FoundationKit, NEXT
# when using NeXT/OPENStep FoundationKit, and UNKNOWN when using
# something else, so you can use
# #ifdef GNUSTEP
#   ... some plist code for GNUstep ...
# #else
#   ... some plist code for Apple ...
# #endif
# to have your .cplist use different code for each.
#

# The following is really a hack, but very elegant.  Our problem is
# that we'd like to always depend on xxxInfo.plist if it's there, and
# not depend on it if it's not there - but we don't have a solution to
# this problem at the moment, so we don't depend on it.  Adding
# xxx_PREPROCESS_INFO_PLIST = yes at the moment just turns on the
# dependency on xxxInfo.plist, which is then built from xxxInfo.cplist
# using the %.plist: %.cplist rules.
ifeq ($($(GNUSTEP_INSTANCE)_PREPROCESS_INFO_PLIST), yes)
  GNUSTEP_PLIST_DEPEND = $(GNUSTEP_INSTANCE)Info.plist
else
  GNUSTEP_PLIST_DEPEND =
endif

# On Apple we assume that xxxInfo.plist has a '{' (and nothing else)
# on the first line, and the rest of the file is a plain property list
# dictionary.  You must make sure your xxxInfo.plist is in this format
# to use it on Apple.

# The problem is, we need to add the automatically generated entries
# to this custom dictionary on Apple - to do that, we generate '{'
# followed by the custom entries, followed by xxxInfo.plist (with the
# first line removed), or by '}'.  NB: "sed '1d' filename" prints out
# filename, except the first line.

# On GNUstep we use plmerge which is much slower, but should probably
# be safer, because as soon as xxxInfo.plist is in plist format, it
# should always work (even if the first line is not just a '{' and
# nothing else).

ifeq ($(FOUNDATION_LIB), apple)
$(APP_INFO_PLIST_FILE): $(GNUSTEP_STAMP_DEPEND) $(GNUSTEP_PLIST_DEPEND)
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_INSTANCE)\";"; \
	  echo "  NSMainNibFile = \"$(MAIN_MODEL_FILE)\";"; \
	  if [ "$(APPLICATION_ICON)" != "" ]; then \
	    echo "  CFBundleIconFile = \"$(APPLICATION_ICON)\";"; \
	  fi; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  if [ -r "$(GNUSTEP_INSTANCE)Info.plist" ]; then \
	    sed '1d' "$(GNUSTEP_INSTANCE)Info.plist"; \
	  else \
	    echo "}"; \
	  fi) > $@
else

$(APP_INFO_PLIST_FILE): $(GNUSTEP_STAMP_DEPEND) $(GNUSTEP_PLIST_DEPEND)
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_INSTANCE)\";"; \
	  echo "  NSMainNibFile = \"$(MAIN_MODEL_FILE)\";"; \
	  if [ "$(APPLICATION_ICON)" != "" ]; then \
	    echo "  NSIcon = \"$(APPLICATION_ICON)\";"; \
	  fi; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "}") >$@
	 @if [ -r "$(GNUSTEP_INSTANCE)Info.plist" ]; then \
	   plmerge $@ "$(GNUSTEP_INSTANCE)Info.plist"; \
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
