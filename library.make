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
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/rules.make

#
# The name of the library is in the LIBRARY_NAME variable.
#

LIBRARY_FILE = $(LIBRARY_NAME)$(LIBEXT)
SHARED_LIBRARY_NAME = $(LIBRARY_NAME)$(SHARED_LIBEXT)
SHARED_LIBRARY_FILE = $(LIBRARY_NAME)$(SHARED_LIBEXT).$(VERSION)

#
# Internal targets
#

#
# Compilation targets
#
internal-all:: object-dir static-library shared-library import-library

object-dir::
	$(GNUSTEP_MAKEFILES)/mkinstalldirs \
		./$(GNUSTEP_OBJ_DIR)

static-library:: $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(AR) $(ARFLAGS) $(AROUT)$(GNUSTEP_OBJ_DIR)/$(LIBRARY_FILE) \
		 $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(RANLIB) $(GNUSTEP_OBJ_DIR)/$(LIBRARY_FILE)

shared-library:: $(SHARED_C_OBJ_FILES) $(SHARED_OBJC_OBJ_FILES)
	$(SHARED_LIB_LINK_CMD)

import-library::

#
# Install and uninstall targets
#
internal-install:: internal-install-dirs internal-install-headers \
   internal-install-libs

internal-install-dirs::
	$(GNUSTEP_MAKEFILES)/mkinstalldirs \
		$(GNUSTEP_LIBRARIES_ROOT) \
		$(GNUSTEP_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_CPU) \
		$(GNUSTEP_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR) \
		$(GNUSTEP_LIBRARIES) \
		$(GNUSTEP_HEADERS) \
		$(ADDITIONAL_INSTALL_DIRS)

internal-install-headers::
	for file in $(HEADER_FILES); do \
	  $(INSTALL_DATA) $(HEADER_FILES_DIR)/$$file \
	    $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	done

internal-install-libs:: internal-install-static-lib \
   internal-install-shared-lib internal-install-import-lib

internal-install-static-lib::
	if [ -e $(GNUSTEP_OBJ_DIR)/$(LIBRARY_FILE) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(LIBRARY_FILE) \
	    $(GNUSTEP_LIBRARIES) ; \
	  $(RANLIB) $(GNUSTEP_LIBRARIES)/$(LIBRARY_FILE) ; \
	fi

internal-install-shared-lib::
	if [ -e $(GNUSTEP_OBJ_DIR)/$(SHARED_LIBRARY_FILE) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(SHARED_LIBRARY_FILE) \
	    $(GNUSTEP_LIBRARIES) ; \
	  (cd $(GNUSTEP_LIBRARIES); \
	   rm -f $(SHARED_LIBRARY_NAME); \
	   $(LN_S) $(SHARED_LIBRARY_FILE) $(SHARED_LIBRARY_NAME)) \
	fi

internal-install-import-lib::

#
# Cleaning targets
#
internal-clean::
	rm -f $(OBJC_OBJ_FILES)
	rm -f $(SHARED_OBJC_OBJ_FILES)
	rm -f $(C_OBJ_FILES)
	rm -f $(SHARED_C_OBJ_FILES)
	rm -f $(PSWRAP_C_FILES)
	rm -f $(PSWRAP_H_FILES)
	rm -f $(GNUSTEP_OBJ_DIR)/$(LIBRARY_FILE)
	rm -f $(GNUSTEP_OBJ_DIR)/$(SHARED_LIBRARY_NAME)
	rm -f $(GNUSTEP_OBJ_DIR)/$(SHARED_LIBRARY_FILE)

internal-distclean:: clean
	rm -rf objs

#
# Testing targets
#
internal-check::