#
#   Master/java.make
#
#   Master Makefile rules to build java-based (not necessarily
#   GNUstep) packages.  
#
#   Copyright (C) 2000 Free Software Foundation, Inc.
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

JAVA_PACKAGE_NAME:=$(strip $(JAVA_PACKAGE_NAME))

internal-all:: $(JAVA_PACKAGE_NAME:=.all.java-package.variables)

internal-install:: $(JAVA_PACKAGE_NAME:=.install.java-package.variables)

internal-uninstall:: $(JAVA_PACKAGE_NAME:=.uninstall.java-package.variables)

internal-clean:: $(JAVA_PACKAGE_NAME:=.clean.java-package.variables)

internal-distclean:: $(JAVA_PACKAGE_NAME:=.distclean.java-package.subprojects)

$(JAVA_PACKAGE_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.java-package.variables

## Local variables:
## mode: makefile
## End:
