#
#   ctool.make
#
#   Makefile rules to build GNUstep-based command line ctools.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
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
# The name of the ctools is in the CTOOL_NAME variable.
#
# xxx We need to prefix the target name when cross-compiling
#

# prevent multiple inclusions
ifeq ($(CTOOL_MAKE_LOADED),)
CTOOL_MAKE_LOADED=yes

CTOOL_NAME:=$(strip $(CTOOL_NAME))

#
# Include in the common makefile rules
#
include $(GNUSTEP_MAKEFILES)/rules.make

# This is the directory where the ctools get installed. If you don't specify a
# directory they will get installed in the GNUstep system root.
ifeq ($(TOOL_INSTALLATION_DIR),)
  TOOL_INSTALLATION_DIR = \
    $(GNUSTEP_INSTALLATION_DIR)/Tools/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)
endif

ifeq ($(INTERNAL_ctool_NAME),)

internal-all:: $(CTOOL_NAME:=.all.ctool.variables)

internal-install:: $(CTOOL_NAME:=.install.ctool.variables)

internal-uninstall:: $(CTOOL_NAME:=.uninstall.ctool.variables)

internal-clean:: $(CTOOL_NAME:=.clean.ctool.variables)

internal-distclean:: $(CTOOL_NAME:=.distclean.ctool.variables)

$(CTOOL_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going $@.all.ctool.variables

else

ALL_TOOL_LIBS = $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) \
   $(TARGET_SYSTEM_LIBS)

ALL_TOOL_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_TOOL_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

#
# Compilation targets
#
internal-ctool-all:: before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
	$(GNUSTEP_OBJ_DIR)/$(INTERNAL_ctool_NAME)$(EXEEXT) after-$(TARGET)-all

$(GNUSTEP_OBJ_DIR)/$(INTERNAL_ctool_NAME)$(EXEEXT): $(C_OBJ_FILES) $(SUBPROJECT_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ \
		$(C_OBJ_FILES) $(SUBPROJECT_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TOOL_LIBS)

before-$(TARGET)-all::

after-$(TARGET)-all::

internal-ctool-install:: internal-ctool-all internal-install-dirs install-ctool

internal-install-dirs::
	$(MKDIRS) $(TOOL_INSTALLATION_DIR)

install-ctool::
	$(INSTALL_PROGRAM) -m 0755 $(GNUSTEP_OBJ_DIR)/$(INTERNAL_ctool_NAME)$(EXEEXT) \
	    $(TOOL_INSTALLATION_DIR);

internal-ctool-uninstall::
	rm -f $(TOOL_INSTALLATION_DIR)/$(INTERNAL_ctool_NAME)$(EXEEXT)

#
# Cleaning targets
#
internal-ctool-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-ctool-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

endif

endif
# ctool.make loaded

## Local variables:
## mode: makefile
## End:
