#
#   library.make
#
#   Makefile rules to build GNUstep-based libraries.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#	     Ovidiu Predescu <ovidiu@net-community.com>
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
# The Objective-C files that gets included in the library are in xxx_OBJC_FILES
# The C files are in xxx_C_FILES
# The pswrap files are in xxx_PSWRAP_FILES
# The header files are in xxx_HEADER_FILES
# The directory where the header files are located is xxx_HEADER_FILES_DIR
# The directory where to install the header files inside the library
# installation directory is xxx_HEADER_FILES_INSTALL_DIR
#
#	Where xxx is the name of the library
#

ifeq ($(INTERNAL_library_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(LIBRARY_NAME:=.all.library.variables)

internal-install:: all $(LIBRARY_NAME:=.install.library.variables)

internal-uninstall:: $(LIBRARY_NAME:=.uninstall.library.variables)

internal-clean:: $(LIBRARY_NAME:=.clean.library.variables)

internal-distclean:: $(LIBRARY_NAME:=.distclean.library.variables)

$(LIBRARY_NAME):
	@$(MAKE) --no-print-directory $@.all.library.variables

else
# This part gets included the second time make is invoked.

ifeq ($(shared), yes)
LIBRARY_FILE = $(INTERNAL_library_NAME)$(LIBRARY_NAME_SUFFIX)$(SHARED_LIBEXT)
LIBRARY_FILE_EXT=$(SHARED_LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE).$(VERSION)
else
LIBRARY_FILE = $(INTERNAL_library_NAME)$(LIBRARY_NAME_SUFFIX)$(LIBEXT)
LIBRARY_FILE_EXT=$(LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE)
endif

ifeq ($(strip $(HEADER_FILES_DIR)),)
HEADER_FILES_DIR = .
endif

#
# Internal targets
#

#
# Compilation targets
#
internal-library-all:: before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
		$(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) import-library \
		after-$(TARGET)-all

$(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE): $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LIB_LINK_CMD)

before-$(TARGET)-all::

after-$(TARGET)-all::

import-library::

#
# Install and uninstall targets
#
internal-library-install:: internal-install-dirs internal-install-lib \
	internal-install-headers
   
internal-install-dirs::
	$(GNUSTEP_MAKEFILES)/mkinstalldirs \
		$(GNUSTEP_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR) \
		$(GNUSTEP_LIBRARIES) \
		$(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR) \
		$(ADDITIONAL_INSTALL_DIRS)

internal-install-headers::
	if [ "$(HEADER_FILES)" != "" ]; then \
	  for file in $(HEADER_FILES) __done; do \
	    if [ $$file != __done ]; then \
	      $(INSTALL_DATA) $(HEADER_FILES_DIR)/$$file \
		$(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	    fi; \
	  done; \
	fi

internal-install-libs:: internal-install-lib \
    internal-install-import-lib

internal-install-lib::
	if [ -f $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) \
	      $(GNUSTEP_LIBRARIES) ; \
	  $(AFTER_INSTALL_LIBRARY_CMD) \
	fi

internal-install-import-lib::

internal-library-uninstall:: internal-uninstall-headers internal-uninstall-lib

internal-uninstall-headers::
	for file in $(HEADER_FILES); do \
	  rm -f $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	done

internal-uninstall-libs:: internal-uninstall-lib \
    internal-uninstall-import-lib

internal-uninstall-lib::
	rm -f $(GNUSTEP_LIBRARIES)/$(VERSION_LIBRARY_FILE)
	rm -f $(GNUSTEP_LIBRARIES)/$(LIBRARY_FILE)

internal-uninstall-import-lib::

#
# Cleaning targets
#
internal-library-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-library-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

#
# Testing targets
#
internal-library-check::

endif
