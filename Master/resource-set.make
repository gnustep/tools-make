#
#   Master/resource-set.make
#
#   Master makefile rules to install resource files
#
#   Copyright (C) 2002 Free Software Foundation, Inc.
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

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

RESOURCE_SET_NAME := $(strip $(RESOURCE_SET_NAME))

# Only install and uninstall are actually performed for this project type

internal-all:: $(RESOURCE_SET_NAME:=.all.resource-set.subprojects)

internal-install:: $(RESOURCE_SET_NAME:=.install.resource-set.variables)

internal-uninstall:: $(RESOURCE_SET_NAME:=.uninstall.resource-set.variables)

internal-clean:: $(RESOURCE_SET_NAME:=.clean.resource-set.subprojects)

internal-distclean:: $(RESOURCE_SET_NAME:=.distclean.resource-set.subprojects)

$(RESOURCE_SET_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.bundle.variables
