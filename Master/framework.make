#
#   Master/framework.make
#
#   Master Makefile rules to build GNUstep-based frameworks.
#
#   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
#
#   Author: Mirko Viviani <mirko.viviani@rccr.cremona.it>
#   Author: Nicola Pero <n.pero@mi.flashnet.it>
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

# A framework has a special task to do before-all, which is to build 
# the public framework headers.
before-all:: $(FRAMEWORK_NAME:=.build-headers.framework.variables)

internal-all:: $(FRAMEWORK_NAME:=.all.framework.variables)

internal-install:: $(FRAMEWORK_NAME:=.install.framework.variables)

internal-uninstall:: $(FRAMEWORK_NAME:=.uninstall.framework.variables)

internal-clean:: $(FRAMEWORK_NAME:=.clean.framework.variables)

internal-distclean:: $(FRAMEWORK_NAME:=.distclean.framework.variables)

$(FRAMEWORK_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going \
		$@.all.framework.variables

## Local variables:
## mode: makefile
## End:
