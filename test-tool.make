#
#   test-tool.make
#
#   Makefile rules for dejagnu/GNUstep based testing
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
ifeq ($(TEST_TOOL_MAKE_LOADED),)
TEST_TOOL_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/rules.make

# building of test tools calls the tool.make rules
ifeq ($(INTERNAL_tool_NAME),)

internal-all:: $(TEST_TOOL_NAME:=.all.tool.variables)

internal-clean:: $(TEST_TOOL_NAME:=.clean.tool.variables)

internal-distclean:: $(TEST_TOOL_NAME:=.distclean.tool.variables)

$(TEST_TOOL_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory $@.all.tool.variables

else

# We use the tool.make rules for building
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/tool.make

endif

# However we do not install test tools
ifeq ($(INTERNAL_testtool_NAME),)

internal-install:: $(TEST_TOOL_NAME:=.install.testtool.variables)

internal-uninstall:: $(TEST_TOOL_NAME:=.uninstall.testtool.variables)

internal-check:: $(TEST_TOOL_NAME:=.check.testtool.variables)

else

internal-install:: $(TEST_TOOL_NAME:=.install.testtool.variables)

internal-uninstall:: $(TEST_TOOL_NAME:=.uninstall.testtool.variables)

endif

endif
# test-tool.make loaded
