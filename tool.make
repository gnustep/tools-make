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
# Include in the common makefile rules
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/rules.make

#
# The name of the tools is in the TOOL_NAME variable.
#
# xxx We need to prefix the target name when cross-compiling
#
TOOL_LIST := $(TOOL_NAME:=.tool)
TOOL_FILE = $(TOOL_LIST)
TOOL_STAMPS := $(foreach tool,$(TOOL_NAME),stamp-tool-$(tool))
TOOL_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(TOOL_STAMPS))

#
# Internal targets
#

$(GNUSTEP_OBJ_DIR)/stamp-tool-% : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(TOOL_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TOOL_LIBS)
	touch $@

#
# Compilation targets
#
internal-all:: $(GNUSTEP_OBJ_DIR) $(TOOL_LIST)

internal-tool-all:: build-tool

build-tool:: $(GNUSTEP_OBJ_DIR)/stamp-tool-$(TOOL_NAME)

#
# Cleaning targets
#
internal-clean::
	rm -f $(TOOL_NAME)
	rm -rf $(GNUSTEP_OBJ_PREFIX)
