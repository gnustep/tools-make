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

.PHONY: internal-tool-all_       \
        internal-tool-install_   \
        internal-tool-uninstall_ \
        internal-install-dirs    \
        install-tool 

# Deprecation warning - will be remove on Dec 2002
ifneq ($(TOOL_INSTALLATION_DIR),)
  $(warning TOOL_INSTALLATION_DIR is deprecated! Please use TOOL_INSTALL_DIR instead)
endif

# This is the directory where the tools get installed. If you don't specify a
# directory they will get installed in the GNUstep Local Root.
ifeq ($(TOOL_INSTALL_DIR),)
  TOOL_INSTALL_DIR = $(GNUSTEP_TOOLS)
endif

ifneq ($(FRAMEWORK_NAME),)
  TOOL_INSTALL_DIR = $(FRAMEWORK_VERSION_DIR_NAME)/Resources
endif

ALL_TOOL_LIBS =								\
    $(shell $(WHICH_LIB_SCRIPT)						\
       $(ALL_LIB_DIRS)							\
       $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) $(FND_LIBS)	\
       $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS)	\
       $(TARGET_SYSTEM_LIBS)						\
	debug=$(debug) profile=$(profile) shared=$(shared)		\
	libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

#
# Compilation targets
#
internal-tool-all_:: $(GNUSTEP_OBJ_DIR) \
                     $(GNUSTEP_OBJ_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT)

ifneq ($(FRAMEWORK_NAME),)
internal-tool-all_:: internal-install-dirs install-tool
endif

$(GNUSTEP_OBJ_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT): $(OBJ_FILES_TO_LINK)
	$(ECHO_LINKING)$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ \
		$(OBJ_FILES_TO_LINK) \
		$(ALL_TOOL_LIBS)$(END_ECHO)

ifneq ($(FRAMEWORK_NAME),)
ifneq ($(FRAMEWORK_OPERATION),all)
   NULL_INSTALL = yes
endif
endif

ifeq ($(NULL_INSTALL),yes)
internal-tool-install_::
else
internal-tool-install_:: internal-install-dirs install-tool
endif

# Depend on having created the installation dir
internal-install-dirs:: $(TOOL_INSTALL_DIR)/$(GNUSTEP_TARGET_LDIR)

# This rule runs $(MKDIRS) only if needed
$(TOOL_INSTALL_DIR)/$(GNUSTEP_TARGET_LDIR):
	@$(MKINSTALLDIRS) $@

install-tool::
	$(ECHO_INSTALLING)$(INSTALL_PROGRAM) -m 0755 \
		$(GNUSTEP_OBJ_DIR)/$(GNUSTEP_INSTANCE)$(EXEEXT) \
		$(TOOL_INSTALL_DIR)/$(GNUSTEP_TARGET_LDIR)$(END_ECHO)

ifneq ($(NULL_INSTALL),yes)
internal-tool-uninstall_::
	rm -f $(TOOL_INSTALL_DIR)/$(GNUSTEP_TARGET_LDIR)/$(GNUSTEP_INSTANCE)$(EXEEXT)
endif

#
# Cleaning targets
#

# we don't have any cleaning targets for tools here, because we clean
# during the Master make invocation.

## Local variables:
## mode: makefile
## End:
