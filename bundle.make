#
#   bundle.make
#
#   Makefile rules to build GNUstep-based bundles.
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

BUNDLE_LINK_CMD = $(CC) $(ALL_CFLAGS) $@$(OEXT) -o $@ $(ALL_LDFLAGS)

#
# The name of the bundle is in the BUNDLE_NAME variable.
# The list of bundle resource file are in xxx_RESOURCES
# The list of bundle resource directories are in xxx_RESOURCE_DIRS
# where xxx is the bundle name
#

BUNDLE_DIR_NAME := $(foreach bundle,$(BUNDLE_NAME),$(bundle).bundle)
BUNDLE_FILE = $(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)/$(BUNDLE_NAME)
BUNDLE_STAMPS := $(foreach bundle,$(BUNDLE_NAME),stamp-bundle-$(bundle))
BUNDLE_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(BUNDLE_STAMPS))
BUNDLE_RESOURCE_DIRS = $(foreach d,$(RESOURCE_DIRS),$(BUNDLE_DIR_NAME)/$(d))

#
# Internal targets
#

$(GNUSTEP_OBJ_DIR)/stamp-bundle-% : $(BUNDLE_FILE) bundle-resource-files
	touch $@

$(BUNDLE_FILE) : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(BUNDLE_LDFLAGS) $(ALL_LDFLAGS) \
		$(LDOUT)$(BUNDLE_FILE) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES)

#
# Compilation targets
#
internal-all:: $(GNUSTEP_OBJ_DIR) $(BUNDLE_DIR_NAME)

internal-bundle-all:: $(GNUSTEP_OBJ_DIR) build-bundle-dir build-bundle

build-bundle-dir::
	$(GNUSTEP_MAKEFILES)/mkinstalldirs \
		$(BUNDLE_DIR_NAME) \
		$(BUNDLE_DIR_NAME)/Resources \
		$(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_CPU) \
		$(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_DIR) \
		$(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO) \
		$(BUNDLE_RESOURCE_DIRS)

build-bundle:: $(GNUSTEP_OBJ_DIR)/stamp-bundle-$(BUNDLE_NAME)

bundle-resource-files::
	for f in $(RESOURCE_FILES); do \
	  $(INSTALL_DATA) $$f $(BUNDLE_DIR_NAME)/$$f ;\
	done

#
# Cleaning targets
#
internal-clean::
	for f in $(BUNDLE_DIR_NAME); do \
	  rm -rf $$f ; \
	done
	rm -rf $(GNUSTEP_OBJ_PREFIX)
