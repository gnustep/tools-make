#
#   Instance/subproject.make
#
#   Instance Makefile rules to build subprojects in GNUstep projects.
#
#   Copyright (C) 1998, 2001 Free Software Foundation, Inc.
#
#   Author:  Jonathan Gapen <jagapen@whitewater.chem.wisc.edu>
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

.PHONY: internal-subproject-all_       \
        internal-subproject-install_   \
        internal-subproject-uninstall_

#
# A subproject can have resources, which it stores into the
# Resources/Subproject directory.  The project which owns us can then
# copy recursively this directory into its own Resources directory
# (that is done automatically if the project uses
# Instance/Shared/bundle.make to manage its own resource bundle)
#
GNUSTEP_SHARED_BUNDLE_RESOURCE_PATH = Resources/Subproject
include $(GNUSTEP_MAKEFILES)/Instance/Shared/bundle.make


#
# Compilation targets
#
internal-subproject-all_:: $(GNUSTEP_OBJ_DIR) \
                           $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) \
                           shared-instance-bundle-all

# We need to depend on SUBPROJECT_OBJ_FILES to account for sub-subprojects.
$(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT): $(OBJ_FILES_TO_LINK)
	$(ECHO_LINKING)$(OBJ_MERGE_CMD)$(END_ECHO)


#
# Build-header target for framework subprojects
#
ifneq ($(FRAMEWORK_NAME),)
.PHONY: internal-subproject-build-headers

HEADER_FILES = $($(GNUSTEP_INSTANCE)_HEADER_FILES)
FRAMEWORK_HEADERS_DIR = $(FRAMEWORK_VERSION_DIR_NAME)/Headers/
FRAMEWORK_HEADER_FILES = $(patsubst %.h,$(FRAMEWORK_HEADERS_DIR)%.h,$(HEADER_FILES))

internal-subproject-build-headers:: $(FRAMEWORK_HEADER_FILES)

# We need to build the FRAMEWORK_HEADERS_DIR directory here because
# this rule could be executed before the top-level framework has built
# his dirs
$(FRAMEWORK_HEADER_FILES):: $(HEADER_FILES) $(FRAMEWORK_HEADERS_DIR)
ifneq ($(HEADER_FILES),)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) ./$$file $(FRAMEWORK_HEADERS_DIR)/$$file ; \
	  fi; \
	done
endif # we got HEADER_FILES

$(FRAMEWORK_HEADERS_DIR):
	$(MKDIRS) $@

endif # FRAMEWORK code



#
# Installation targets - we only need to install headers and only 
# if this is not in a framework
#
ifeq ($(FRAMEWORK_NAME),)

include $(GNUSTEP_MAKEFILES)/Instance/Shared/headers.make

internal-subproject-install_:: shared-instance-headers-install

internal-subproject-uninstall_:: shared-instance-headers-uninstall

endif # no FRAMEWORK_NAME

## Local variables:
## mode: makefile
## End:
