#
#   bundle.make
#
#   Makefile rules to build GNUstep-based bundles.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
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

# The name of the bundle is in the BUNDLE_NAME variable.
# The list of bundle resource file are in xxx_RESOURCES
# The list of bundle resource directories are in xxx_RESOURCE_DIRS
# where xxx is the bundle name
#

ifeq ($(INTERNAL_bundle_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(BUNDLE_NAME:=.all.bundle.variables)

internal-install:: all $(BUNDLE_NAME:=.install.bundle.variables)

internal-uninstall:: $(BUNDLE_NAME:=.uninstall.bundle.variables)

internal-clean:: $(BUNDLE_NAME:=.clean.bundle.variables)

internal-distclean:: $(BUNDLE_NAME:=.distclean.bundle.variables)

$(BUNDLE_NAME):
	@$(MAKE) --no-print-directory $@.all.bundle.variables

else
# This part gets included the second time make is invoked.

internal-bundle-all:: before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
		build-bundle-dir build-bundle \
		after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

BUNDLE_DIR_NAME := $(INTERNAL_bundle_NAME:=$(BUNDLE_EXTENSION))
BUNDLE_FILE := \
    $(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)/$(BUNDLE_NAME)
BUNDLE_RESOURCE_DIRS = $(foreach d, $(RESOURCE_DIRS), $(BUNDLE_DIR_NAME)/$(d))

build-bundle-dir::
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs \
		$(BUNDLE_DIR_NAME)/Resources \
		$(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO) \
		$(BUNDLE_RESOURCE_DIRS)

build-bundle:: $(BUNDLE_FILE) bundle-resource-files

$(BUNDLE_FILE) : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(BUNDLE_LD) $(BUNDLE_LDFLAGS) $(ALL_LDFLAGS) \
		$(LDOUT)$(BUNDLE_FILE) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(BUNDLE_LIBS)

bundle-resource-files::
	for f in $(RESOURCE_FILES) __done; do \
	  if [ $$f != __done ]; then \
	    $(INSTALL_DATA) $$f $(BUNDLE_DIR_NAME)/$$f ;\
	  fi; \
	done

internal-bundle-install::
	tar cf - $(BUNDLE_DIR_NAME) | (cd $(BUNDLE_INSTALL_DIR); tar xf -)

internal-bundle-install::
	rm -rf $(BUNDLE_INSTALL_DIR)/$(BUNDLE_DIR_NAME)

#
# Cleaning targets
#
internal-bundle-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-bundle-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

endif

