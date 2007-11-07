#
#   Master/ctool.make
#
#   Master Makefile rules to build GNUstep-based command line ctools.
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
#   as published by the Free Software Foundation; either version 3
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.
#   If not, write to the Free Software Foundation,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

CTOOL_NAME := $(strip $(CTOOL_NAME))

internal-all:: $(CTOOL_NAME:=.all.ctool.variables)

internal-install:: $(CTOOL_NAME:=.install.ctool.variables)

internal-uninstall:: $(CTOOL_NAME:=.uninstall.ctool.variables)

internal-clean::

internal-distclean::

CTOOLS_WITH_SUBPROJECTS = $(strip $(foreach ctool,$(CTOOL_NAME),$(patsubst %,$(ctool),$($(ctool)_SUBPROJECTS))))
ifneq ($(CTOOLS_WITH_SUBPROJECTS),)
internal-clean:: $(CTOOLS_WITH_SUBPROJECTS:=.clean.ctool.subprojects)
internal-distclean:: $(CTOOLS_WITH_SUBPROJECTS:=.distclean.ctool.subprojects)
endif

internal-strings:: $(CTOOL_NAME:=.strings.ctool.variables)

$(CTOOL_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
	         $@.all.ctool.variables
