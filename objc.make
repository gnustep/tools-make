#
#   objc.make
#
#   Makefile rules to build ObjC-based (but not GNUstep) programs.
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

# prevent multiple inclusions
ifeq ($(OBJC_PROGRAM_MAKE_LOADED),)
OBJC_PROGRAM_MAKE_LOADED=yes

#
# The name of the ObjC program is in the OBJC_PROGRAM_NAME variable.
#
# xxx We need to prefix the target name when cross-compiling
#

OBJC_PROGRAM_NAME:=$(strip $(OBJC_PROGRAM_NAME))

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

ifeq ($(INTERNAL_objc_program_NAME),)

# This part gets included by the first invoked make process.
internal-all:: $(OBJC_PROGRAM_NAME:=.all.objc-program.variables)

internal-install:: $(OBJC_PROGRAM_NAME:=.install.objc-program.variables)

internal-uninstall:: $(OBJC_PROGRAM_NAME:=.uninstall.objc-program.variables)

internal-clean:: $(OBJC_PROGRAM_NAME:=.clean.objc-program.subprojects)
	rm -rf $(GNUSTEP_OBJ_PREFIX)

internal-distclean:: $(OBJC_PROGRAM_NAME:=.distclean.objc-program.subprojects)
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

$(OBJC_PROGRAM_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.objc-program.variables

else

.PHONY: internal-objc_program-all \
        internal-objc_program-install \
        internal-objc_program-uninstall \
        before-$(TARGET)-all \
        after-$(TARGET)-all \
        install-objc_program

# This is the directory where the objc programs get installed. If you
# don't specify a directory they will get installed in the Tools
# directory in GNUSTEP_LOCAL_ROOT.
OBJC_PROGRAM_INSTALLATION_DIR = $(GNUSTEP_TOOLS)/$(GNUSTEP_TARGET_DIR)

ALL_OBJC_LIBS = $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS) \
	        $(TARGET_SYSTEM_LIBS)

ALL_OBJC_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_OBJC_LIBS) \
            debug=$(debug) profile=$(profile) shared=$(shared) \
            libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

ifeq ($(WITH_DLL),yes)
TTMP_LIBS := $(ALL_TOOL_LIBS)
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

#
# Internal targets
#

$(GNUSTEP_OBJ_DIR)/$(INTERNAL_objc_program_NAME)$(EXEEXT): \
                $(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(SUBPROJECT_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ \
	      $(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(SUBPROJECT_OBJ_FILES) \
	      $(ALL_LIB_DIRS) $(ALL_OBJC_LIBS)

#
# Compilation targets
#
internal-objc_program-all:: \
                  before-$(TARGET)-all \
                  $(GNUSTEP_OBJ_DIR) \
                  $(GNUSTEP_OBJ_DIR)/$(INTERNAL_objc_program_NAME)$(EXEEXT) \
                  after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

internal-objc_program-install:: $(OBJC_PROGRAM_INSTALLATION_DIR) \
                                install-objc_program

$(OBJC_PROGRAM_INSTALLATION_DIR):
	$(MKDIRS) $(OBJC_PROGRAM_INSTALLATION_DIR)

install-objc_program::
	$(INSTALL_PROGRAM) -m 0755 \
	    $(GNUSTEP_OBJ_DIR)/$(INTERNAL_objc_program_NAME)$(EXEEXT) \
	    $(OBJC_PROGRAM_INSTALLATION_DIR)

endif

endif
# objc.make loaded

## Local variables:
## mode: makefile
## End:
