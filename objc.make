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

#
# Include in the common makefile rules
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/rules.make

# This is the directory where the objc programss get installed. If you
# don't specify a directory they will get installed in the GNUstep
# system root.
OBJC_PROGRAM_INSTALLATION_DIR = \
    $(GNUSTEP_INSTALLATION_DIR)/Tools

#
# The name of the ObjC program is in the OBJC_PROGRAM_NAME variable.
#
# xxx We need to prefix the target name when cross-compiling
#
OBJC_PROGRAM_LIST := $(OBJC_PROGRAM_NAME:=.buildobjc)
OBJC_PROGRAM_FILE = $(OBJC_PROGRAM_LIST)

#
# Internal targets
#

$(OBJC_PROGRAM_NAME) : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(OBJC_PROGRAM_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_OBJC_LIBS)

#
# Compilation targets
#
internal-all:: $(GNUSTEP_OBJ_DIR) $(OBJC_PROGRAM_LIST)

internal-objc-all:: build-objc-program

internal-install:: all internal-install-objc-dirs internal-install-objc-program

internal-install-objc-dirs::
	$(GNUSTEP_MAKEFILES)/mkinstalldirs $(OBJC_PROGRAM_INSTALLATION_DIR)

internal-install-objc-program::
	for f in $(OBJC_PROGRAM_NAME); do \
	  $(INSTALL_PROGRAM) -m 0755 $$f $(OBJC_PROGRAM_INSTALLATION_DIR); \
	done

build-objc-program:: $(OBJC_PROGRAM_NAME)

#
# Cleaning targets
#
internal-clean::
	rm -f $(OBJC_PROGRAM_NAME)
	rm -rf $(GNUSTEP_OBJ_PREFIX)

internal-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj
