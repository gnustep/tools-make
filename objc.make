#
#   objc.make
#
#   Makefile rules to build ObjC-based (but not GNUstep) programs.
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

# prevent multiple inclusions
ifeq ($(OBJC_PROGRAM_MAKE_LOADED),)
OBJC_PROGRAM_MAKE_LOADED=yes

#
# The name of the ObjC program is in the OBJC_PROGRAM_NAME variable.
#
# xxx We need to prefix the target name when cross-compiling
#

#
# Include in the common makefile rules
#
include $(GNUSTEP_MAKEFILES)/rules.make

ifeq ($(INTERNAL_objc_program_NAME),)

# This part gets included by the first invoked make process.
internal-all:: $(OBJC_PROGRAM_NAME:=.all.objc-program.variables)

internal-install:: $(OBJC_PROGRAM_NAME:=.install.objc-program.variables)

internal-uninstall:: $(OBJC_PROGRAM_NAME:=.uninstall.objc-program.variables)

internal-clean:: $(OBJC_PROGRAM_NAME:=.clean.objc-program.variables)

internal-distclean:: $(OBJC_PROGRAM_NAME:=.distclean.objc-program.variables)

$(OBJC_PROGRAM_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.objc-program.variables

else

# This is the directory where the objc programss get installed. If you
# don't specify a directory they will get installed in the GNUstep
# system root.
OBJC_PROGRAM_INSTALLATION_DIR = \
    $(GNUSTEP_INSTALLATION_DIR)/Tools/$(GNUSTEP_TARGET_DIR)

ALL_OBJC_LIBS = $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS) \
	 $(TARGET_SYSTEM_LIBS)

ALL_OBJC_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_OBJC_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

#
# Internal targets
#

$(GNUSTEP_OBJ_DIR)/$(INTERNAL_objc_program_NAME)$(EXEEXT): \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$@ \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_OBJC_LIBS)

#
# Compilation targets
#
internal-objc_program-all:: before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
	$(GNUSTEP_OBJ_DIR)/$(INTERNAL_objc_program_NAME)$(EXEEXT) after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

internal-objc_program-install:: internal-install-objc-dirs install-objc_program

internal-install-objc-dirs::
	$(MKDIRS) $(OBJC_PROGRAM_INSTALLATION_DIR)

install-objc_program::
	$(INSTALL_PROGRAM) -m 0755 \
	    $(GNUSTEP_OBJ_DIR)/$(INTERNAL_objc_program_NAME)$(EXEEXT) \
	    $(OBJC_PROGRAM_INSTALLATION_DIR);

#
# Cleaning targets
#
internal-objc_program-clean::
	rm -f $(OBJC_PROGRAM_NAME)
	rm -rf $(GNUSTEP_OBJ_PREFIX)

internal-objc_program-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

endif

endif
# objc.make loaded

## Local variables:
## mode: makefile
## End:
