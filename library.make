#
#   library.make
#
#   Makefile rules to build GNUstep-based libraries.
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
include $(GNUSTEP_ROOT)/Makefiles/rules.make

#
# The name of the library is in the LIBRARY_NAME variable.
#
# The list of Objective-C source files to be compiled and put
# in the librar are in the OBJC_FILES variable.
#
# The list of C source files to be compiled and put
# in the librar are in the C_FILES variable.
#

LIBRARY_FILE = $(LIBRARY_NAME)$(LIBEXT)

OBJC_OBJ_FILES = $(OBJC_FILES:.m=${OEXT})

C_OBJ_FILES = $(C_FILES:.c=${OEXT})

#
# Internal targets
#

#
# Compilation targets
#
internal-all:: shared-library static-library import-library

shared-library::

static-library:: $(OBJC_OBJ_FILES) $(C_OBJ_FILES)
	$(AR) $(ARFLAGS) $(AROUT)$(LIBRARY_FILE) \
		 $(OBJC_OBJ_FILES) $(C_OBJ_FILES)
	$(RANLIB) $(LIBRARY_FILE)

import-library::

#
# Install and uninstall targets
#

#
# Cleaning targets
#
internal-clean::
	rm -f $(OBJC_OBJ_FILES)
	rm -f $(C_OBJ_FILES)
	rm -f $(LIBRARY_FILE)

internal-distclean:: clean

#
# Testing targets
#
internal-check::