#
#   Instance/tool.make
#
#   Instance Makefile rules to build GNUstep-based command line tools.
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
# The name of the tools is in the TOOL_NAME variable.
#
# xxx We need to prefix the target name when cross-compiling
#

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

# This is the directory where the tools get installed. If you don't specify a
# directory they will get installed in the GNUstep Local Root.
ifeq ($(TOOL_INSTALLATION_DIR),)
  TOOL_INSTALLATION_DIR = $(GNUSTEP_TOOLS)/$(GNUSTEP_TARGET_LDIR)
endif

.PHONY: internal-tool-all       \
        internal-tool-install   \
        internal-tool-uninstall \
        before-$(GNUSTEP_INSTANCE)-all    \
        after-$(GNUSTEP_INSTANCE)-all     \
        internal-install-dirs   \
        install-tool 

ifneq ($(FRAMEWORK_NAME),)
  TOOL_INSTALLATION_DIR = $(FRAMEWORK_VERSION_DIR_NAME)/Resources/$(GNUSTEP_TARGET_LDIR)
endif

ALL_TOOL_LIBS =								\
    $(shell $(WHICH_LIB_SCRIPT)						\
       $(ALL_LIB_DIRS)							\
       $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) $(FND_LIBS)	\
       $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS)	\
       $(TARGET_SYSTEM_LIBS)						\
	debug=$(debug) profile=$(profile) shared=$(shared)		\
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
# Compilation targets
#
internal-tool-all:: before-$(GNUSTEP_INSTANCE)-all \
                    $(GNUSTEP_OBJ_DIR) \
                    $(GNUSTEP_OBJ_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT) \
                    after-$(GNUSTEP_INSTANCE)-all

ifneq ($(FRAMEWORK_NAME),)
internal-tool-all:: internal-install-dirs install-tool
endif

$(GNUSTEP_OBJ_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT): $(OBJ_FILES_TO_LINK)
	$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ \
		$(OBJ_FILES_TO_LINK) \
		$(ALL_TOOL_LIBS)

before-$(GNUSTEP_INSTANCE)-all::

after-$(GNUSTEP_INSTANCE)-all::

ifneq ($(FRAMEWORK_NAME),)
ifneq ($(FRAMEWORK_OPERATION),all)
   NULL_INSTALL = yes
endif
endif

ifeq ($(NULL_INSTALL),yes)
internal-tool-install::
else
internal-tool-install:: internal-install-dirs install-tool
endif

# Depend on having created the installation dir
internal-install-dirs:: $(TOOL_INSTALLATION_DIR)

# This rule runs $(MKDIRS) only if needed
$(TOOL_INSTALLATION_DIR):
	$(MKINSTALLDIRS) $@

install-tool::
	$(INSTALL_PROGRAM) -m 0755 \
		$(GNUSTEP_OBJ_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT) \
		$(TOOL_INSTALLATION_DIR)

internal-tool-uninstall::
	rm -f $(TOOL_INSTALLATION_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT)

#
# Cleaning targets
#

# we don't have any cleaning targets for tools here, because we clean
# at the first make invocation.

## Local variables:
## mode: makefile
## End:
