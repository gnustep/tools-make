#
#   Master/java-tool.make
#
#   Master Makefile rules to build Java command-line tools.
#
#   Copyright (C) 2001 Free Software Foundation, Inc.
#
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

# Why using Java if you can use Objective-C ...
# Anyway if you really want it, here we go.

#
# The name of the tools is in the JAVA_TOOL_NAME variable.
# The main class (the one implementing main) is in the
# xxx_PRINCIPAL_CLASS variable.
#

# prevent multiple inclusions
ifeq ($(MASTER_JAVA_TOOL_MAKE_LOADED),)
MASTER_JAVA_TOOL_MAKE_LOADED = yes

JAVA_TOOL_NAME:=$(strip $(JAVA_TOOL_NAME))

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

internal-all:: $(JAVA_TOOL_NAME:=.all.java_tool.variables)

internal-install:: $(JAVA_TOOL_NAME:=.install.java_tool.variables)

internal-uninstall:: $(JAVA_TOOL_NAME:=.uninstall.java_tool.variables)

internal-clean:: $(JAVA_TOOL_NAME:=.clean.java_tool.variables)

internal-distclean:: $(JAVA_TOOL_NAME:=.distclean.java_tool.subprojects)

$(JAVA_TOOL_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
	         $@.all.java_tool.variables

endif # Master/java-tool.make loaded

## Local variables:
## mode: makefile
## End:
