#
#   Instance/objc.make
#
#   Instance Makefile rules to build ObjC-based (but not GNUstep) programs.
#
#   Copyright (C) 1997, 2001 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Nicola Pero <nicola@brainstorm.co.uk>
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
# The name of the ObjC program(s) is in the OBJC_PROGRAM_NAME variable.
#
# xxx We need to prefix the target name when cross-compiling
#

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

.PHONY: internal-objc_program-all_ \
        internal-objc_program-install_ \
        internal-objc_program-uninstall_

# This is the directory where the objc programs get installed. If you
# don't specify a directory they will get installed in the Tools
# directory in GNUSTEP_LOCAL_ROOT.
ifeq ($(OBJC_PROGRAM_INSTALLATION_DIR),)
OBJC_PROGRAM_INSTALLATION_DIR = $(GNUSTEP_TOOLS)/$(GNUSTEP_TARGET_DIR)
endif

ALL_OBJC_LIBS =								\
    $(shell $(WHICH_LIB_SCRIPT)						\
	$(ALL_LIB_DIRS)							\
	$(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS)	\
        $(TARGET_SYSTEM_LIBS)						\
        debug=$(debug) profile=$(profile) shared=$(shared)		\
        libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

internal-objc_program-all_:: \
                  $(GNUSTEP_OBJ_DIR) \
                  $(GNUSTEP_OBJ_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT)

$(GNUSTEP_OBJ_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT): $(OBJ_FILES_TO_LINK)
	$(ECHO_LINKING)$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ $(OBJ_FILES_TO_LINK)\
	      $(ALL_OBJC_LIBS)$(END_ECHO)

internal-objc_program-install_:: $(OBJC_PROGRAM_INSTALLATION_DIR)
	$(ECHO_INSTALLING)$(INSTALL_PROGRAM) -m 0755 \
	    $(GNUSTEP_OBJ_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT) \
	    $(OBJC_PROGRAM_INSTALLATION_DIR)$(END_ECHO)

$(OBJC_PROGRAM_INSTALLATION_DIR):
	@$(MKINSTALLDIRS) $@

internal-objc_program-uninstall_::
	rm -f $(OBJC_PROGRAM_INSTALLATION_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT)

## Local variables:
## mode: makefile
## End:
