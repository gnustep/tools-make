#
#   palette.make
#
#   Makefile rules to build GNUstep-based palettes.
#
#   Copyright (C) 1999 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#   Author:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
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
ifeq ($(PALETTE_MAKE_LOADED),)
PALETTE_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
include $(GNUSTEP_MAKEFILES)/rules.make

# The name of the palette is in the PALETTE_NAME variable.
# The list of palette resource file are in xxx_RESOURCE_FILES
# The list of palette resource directories are in xxx_RESOURCE_DIRS
# The name of the palette class is xxx_PALETTE_CLASS
# The name of the palette icon is xxx_PALETTE_ICON
# The name of a file containing info.plist entries to be inserted into
# Info-gnustep.plist (if any) is xxxInfo.plist where xxx is the palette name
# The name of a file containing palette.table entries to be inserted into
# palette.table (if any) is xxxpalette.table where xxx is the palette name
#

PALETTE_NAME:=$(strip $(PALETTE_NAME))

ifeq ($(INTERNAL_palette_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(PALETTE_NAME:=.all.palette.variables)

internal-install:: all $(PALETTE_NAME:=.install.palette.variables)

internal-uninstall:: $(PALETTE_NAME:=.uninstall.palette.variables)

internal-clean:: $(PALETTE_NAME:=.clean.palette.variables)

internal-distclean:: $(PALETTE_NAME:=.distclean.palette.variables)

$(PALETTE_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.palette.variables

else
# This part gets included the second time make is invoked.

# On Solaris we don't need to specifies the libraries the palette needs.
# How about the rest of the systems? ALL_PALETTE_LIBS is temporary empty.
#ALL_PALETTE_LIBS = $(ADDITIONAL_GUI_LIBS) $(AUXILIARY_GUI_LIBS) $(BACKEND_LIBS) \
   $(GUI_LIBS) $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) \
   $(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS) \
   $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)

#ALL_PALETTE_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_PALETTE_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

internal-palette-all:: before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
		build-palette-dir build-palette \
		after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

PALETTE_DIR_NAME := $(INTERNAL_palette_NAME).palette
PALETTE_FILE := \
    $(PALETTE_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)/$(PALETTE_NAME)
PALETTE_RESOURCE_DIRS = $(foreach d, $(RESOURCE_DIRS), $(PALETTE_DIR_NAME)/Resources/$(d))
ifeq ($(strip $(RESOURCE_FILES)),)
  override RESOURCE_FILES=""
endif

build-palette-dir::
	@$(MKDIRS) \
		$(PALETTE_DIR_NAME)/Resources \
		$(PALETTE_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO) \
		$(PALETTE_RESOURCE_DIRS)

build-palette:: $(PALETTE_FILE) palette-resource-files

$(PALETTE_FILE) : $(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(SUBPROJECT_OBJ_FILES)
	$(BUNDLE_LD) $(BUNDLE_LDFLAGS) $(ALL_LDFLAGS) \
		-o $(LDOUT)$(PALETTE_FILE) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(SUBPROJECT_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_PALETTE_LIBS)

palette-resource-files:: $(PALETTE_DIR_NAME)/Resources/Info-gnustep.plist \
$(PALETTE_DIR_NAME)/Resources/palette.table
	@(if [ "$(RESOURCE_FILES)" != "" ]; then \
	  echo "Copying resources into the palette wrapper..."; \
	  for f in "$(RESOURCE_FILES)"; do \
	    cp -r $$f $(PALETTE_DIR_NAME)/Resources; \
	  done \
	fi)

ifeq ($(PALETTE_CLASS),)
override PALETTE_CLASS = $(INTERNAL_palette_NAME)
endif

ifeq ($(PALETTE_ICON),)
override PALETTE_ICON = $(INTERNAL_palette_NAME)
endif

$(PALETTE_DIR_NAME)/Resources/Info-gnustep.plist: $(PALETTE_DIR_NAME)/Resources
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(INTERNAL_palette_NAME)\";"; \
	  if [ -r "$(INTERNAL_palette_NAME)Info.plist" ]; then \
	    cat $(INTERNAL_palette_NAME)Info.plist; \
	  fi; \
	  echo "}") >$@

$(PALETTE_DIR_NAME)/Resources/palette.table: $(PALETTE_DIR_NAME)/Resources
	@(echo '  NOTE = "Automatically generated, do not edit!";'; \
	  if [ "$(PALETTE_NIB)" = "" ]; then \
	    echo "  NibFile = \"\";"; \
	  else \
	    echo "  NibFile = \"`echo $(PALETTE_NIB) | sed 's/.gmodel//'`\";"; \
	  fi; \
	  echo "  Class = \"$(PALETTE_CLASS)\";"; \
	  echo "  Icon = \"$(PALETTE_ICON)\";"; \
	  if [ -r "$(INTERNAL_palette_NAME)palette.table" ]; then \
	    cat $(INTERNAL_palette_NAME)palette.table; \
	  fi; \
	  ) >$@

internal-palette-install:: $(PALETTE_INSTALL_DIR)
	tar cf - $(PALETTE_DIR_NAME) | (cd $(PALETTE_INSTALL_DIR); tar xf -)

$(PALETTE_DIR_NAME)/Resources $(PALETTE_INSTALL_DIR)::
	@$(MKDIRS) $@

internal-palette-uninstall::
	rm -rf $(PALETTE_INSTALL_DIR)/$(PALETTE_DIR_NAME)

#
# Cleaning targets
#
internal-palette-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-palette-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj $(PALETTE_DIR_NAME)

endif

endif
# palette.make loaded

## Local variables:
## mode: makefile
## End:
