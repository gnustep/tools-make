#
#   tool.make
#
#   Makefile rules to build GNUstep-based command line tools.
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
# The name of the tools is in the TOOL_NAME variable.
#
# xxx We need to prefix the target name when cross-compiling
#

# prevent multiple inclusions
ifeq ($(TOOL_MAKE_LOADED),)
TOOL_MAKE_LOADED=yes

TOOL_NAME:=$(strip $(TOOL_NAME))

#
# Include in the common makefile rules
#
include $(GNUSTEP_MAKEFILES)/rules.make

# This is the directory where the tools get installed. If you don't specify a
# directory they will get installed in the GNUstep system root.
ifeq ($(TOOL_INSTALLATION_DIR),)
  TOOL_INSTALLATION_DIR = \
    $(GNUSTEP_TOOLS)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)
endif

ifeq ($(INTERNAL_tool_NAME),)

internal-all:: $(TOOL_NAME:=.all.tool.variables)

internal-install:: $(TOOL_NAME:=.install.tool.variables)

internal-uninstall:: $(TOOL_NAME:=.uninstall.tool.variables)

internal-clean:: $(TOOL_NAME:=.clean.tool.variables)

internal-distclean:: $(TOOL_NAME:=.distclean.tool.variables)

$(TOOL_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going $@.all.tool.variables

else # second pass

ALL_TOOL_LIBS = $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) $(FND_LIBS) \
   $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS) \
   $(TARGET_SYSTEM_LIBS)

ALL_TOOL_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_TOOL_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

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
TTMP_LIBS := $(TTMP_LIBS:%=-Dlib%_ISDLL=1)
ALL_CPPFLAGS += $(TTMP_LIBS)
endif

#
# Compilation targets
#
internal-tool-all:: before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
	$(GNUSTEP_OBJ_DIR)/$(INTERNAL_tool_NAME)$(EXEEXT) after-$(TARGET)-all

$(GNUSTEP_OBJ_DIR)/$(INTERNAL_tool_NAME)$(EXEEXT): $(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(SUBPROJECT_OBJ_FILES) $(OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(OBJ_FILES) $(SUBPROJECT_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TOOL_LIBS)

before-$(TARGET)-all::

after-$(TARGET)-all::

internal-tool-install:: internal-tool-all internal-install-dirs install-tool

internal-install-dirs::
	$(MKDIRS) $(TOOL_INSTALLATION_DIR)

install-tool::
	$(INSTALL_PROGRAM) -m 0755 $(GNUSTEP_OBJ_DIR)/$(INTERNAL_tool_NAME)$(EXEEXT) \
	    $(TOOL_INSTALLATION_DIR);
	cp $(GNUSTEP_MAKEFILES)/executable.template $(GNUSTEP_INSTALLATION_DIR)/Tools/$(INTERNAL_tool_NAME)
	chmod a+x $(GNUSTEP_INSTALLATION_DIR)/Tools/$(INTERNAL_tool_NAME)

internal-tool-uninstall::
	rm -f $(TOOL_INSTALLATION_DIR)/$(INTERNAL_tool_NAME)$(EXEEXT)

#
# Cleaning targets
#
internal-tool-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-tool-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

endif

endif
# tool.make loaded

## Local variables:
## mode: makefile
## End:
