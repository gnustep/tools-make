#
#   java-wrapper.make
#
#   Makefile rules to build GNUstep-based Java wrapper libraries.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author: Lyndon Tremblay <ltremblay@mezzanine.xnot.com>
#   Based on library.make from  Scott Christley <scottc@net-community.com>
#	     and Ovidiu Predescu <ovidiu@net-community.com>
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
ifeq ($(JAVA_WRAPPER_MAKE_LOADED),)
JAVA_WRAPPER_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
include $(GNUSTEP_MAKEFILES)/rules.make

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

JAVA_WRAPPER_NAME:=$(strip $(JAVA_WRAPPER_NAME))

ifeq ($(INTERNAL_java_wrapper_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(JAVA_WRAPPER_NAME:=.all.java_wrapper.variables)

internal-install:: all $(JAVA_WRAPPER_NAME:=.install.java_wrapper.variables)

internal-uninstall:: $(JAVA_WRAPPER_NAME:=.uninstall.java_wrapper.variables)

internal-clean:: $(JAVA_WRAPPER_NAME:=.clean.java_wrapper.variables)

internal-distclean:: $(JAVA_WRAPPER_NAME:=.distclean.java_wrapper.variables)

$(JAVA_WRAPPER_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going \
		$@.all.java_wrapper.variables

else
# This part gets included the second time make is invoked.

ifeq ($(shared), yes)
LIBRARY_FILE = $(INTERNAL_java_wrapper_NAME)$(LIBRARY_NAME_SUFFIX)$(SHARED_LIBEXT)
LIBRARY_FILE_EXT=$(SHARED_LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE).$(VERSION)
SOVERSION = `echo $(VERSION)|awk -F. '{print $$1}'`
SONAME_LIBRARY_FILE=$(LIBRARY_FILE).$(SOVERSION)
else
LIBRARY_FILE = $(INTERNAL_java_wrapper_NAME)$(LIBRARY_NAME_SUFFIX)$(LIBEXT)
LIBRARY_FILE_EXT=$(LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE)
SONAME_LIBRARY_FILE=$(LIBRARY_FILE)
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
internal-java_wrapper-all:: before-all before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
		$(JAVA_OBJ_FILES) \
		$(GNUSTEP_OBJ_DIR)/$(VERSION_JAVA_WRAPPER_FILE) import-java_wrapper \
		after-$(TARGET)-all after-all

$(GNUSTEP_OBJ_DIR)/$(VERSION_JAVA_WRAPPER_FILE): $(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(SUBPROJECT_OBJ_FILES)
	$(LIB_LINK_CMD)

before-$(TARGET)-all::
	@echo "Building Java classes...";
	@(../bridget bridget $(JAVA_JOBS_FILES))

after-$(TARGET)-all::

import-java_wrapper::

#
# Install and uninstall targets
#
internal-java_wrapper-install:: internal-install-dirs internal-install-lib \
	internal-install-headers

internal-install-dirs::
	$(MKDIRS) \
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
	if [ -f $(GNUSTEP_OBJ_DIR)/$(VERSION_JAVA_WRAPPER_FILE) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(VERSION_JAVA_WRAPPER_FILE) \
	      $(GNUSTEP_LIBRARIES) ; \
	  $(AFTER_INSTALL_LIBRARY_CMD) \
	fi

internal-install-import-lib::

internal-java_wrapper-uninstall:: before-uninstall internal-uninstall-headers internal-uninstall-lib after-uninstall

before-uninstall after-uninstall::

internal-uninstall-headers::
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    rm -f $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done

internal-uninstall-libs:: internal-uninstall-lib \
    internal-uninstall-import-lib

internal-uninstall-lib::
	rm -f $(GNUSTEP_LIBRARIES)/$(VERSION_JAVA_WRAPPER_FILE)
	rm -f $(GNUSTEP_LIBRARIES)/$(JAVA_WRAPPER_FILE)

internal-uninstall-import-lib::

#
# Cleaning targets
#
internal-java_wrapper-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-java_wrapper-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

#
# Testing targets
#
internal-java_wrapper-check::

endif

endif
# java_wrapper.make loaded

## Local variables:
## mode: makefile
## End:
