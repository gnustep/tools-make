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

# prevent multiple inclusions
ifeq ($(MASTER_JAVA_PACKAGE_MAKE_LOADED),)
MASTER_JAVA_PACKAGE_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

JAVA_PACKAGE_NAME:=$(strip $(JAVA_PACKAGE_NAME))

internal-all:: $(JAVA_PACKAGE_NAME:=.all.java-package.variables)

internal-install:: $(JAVA_PACKAGE_NAME:=.install.java-package.variables)

internal-uninstall:: $(JAVA_PACKAGE_NAME:=.uninstall.java-package.variables)

internal-clean:: $(JAVA_PACKAGE_NAME:=.clean.java-package.variables)

internal-distclean:: $(JAVA_PACKAGE_NAME:=.distclean.java-package.variables)

$(JAVA_PACKAGE_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.java-package.variables

endif # Master/java.make loaded

## Local variables:
## mode: makefile
## End:
