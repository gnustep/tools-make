#
#   subproject.make
#
#   Makefile rules to build subprojects in GNUstep projects.
#
#   Copyright (C) 1998 Free Software Foundation, Inc.
#
#   Author:  Jonathan Gapen <jagapen@whitewater.chem.wisc.edu>
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
ifeq ($(SUBPROJECT_MAKE_LOADED),)
SUBPROJECT_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
include $(GNUSTEP_MAKEFILES)/rules.make

#
# The names of the subproject is in the SUBPROJECT_NAME variable.
#

SUBPROJECT_NAME:=$(strip $(SUBPROJECT_NAME))

ifeq ($(INTERNAL_subproj_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(SUBPROJECT_NAME:=.all.subproj.variables)

internal-install:: $(SUBPROJECT_NAME:=.install.subproj.variables)

internal-clean:: $(SUBPROJECT_NAME:=.clean.subproj.variables)

internal-distclean:: $(SUBPROJECT_NAME:=.distclean.subproj.variables)

$(SUBPROJECT_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.subproj.variables

else
# This part gets included the second time make is invoked.

#
# Internal targets
#

#
# Compilation targets
#
internal-subproj-all:: before-all before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
                   $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) \
                   after-$(TARGET)-all after-all

$(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT): $(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
					  $(SUBPROJECT_OBJ_FILES)
	$(OBJ_MERGE_CMD)

before-$(TARGET)-all::

after-$(TARGET)-all::

after-all::

#
# Installation and Uninstallation targets
#

internal-subproj-install:: internal-install-subproj-dirs \
	internal-install-subproj-headers

internal-install-subproj-dirs::
	$(MKDIRS) \
		$(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR) \
		$(ADDITIONAL_INSTALL_DIRS)

internal-install-subproj-headers::
	if [ "$(HEADER_FILES)" != "" ]; then \
	  for file in $(HEADER_FILES) __done; do \
	    if [ $$file != __done ]; then \
	      $(INSTALL_DATA) $(HEADER_FILES_DIR)/$$file \
		$(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	    fi; \
	  done; \
	fi

internal-library-uninstall:: before-uninstall internal-uninstall-headers after-uninstall

before-uninstall after-uninstall::

internal-uninstall-headers::
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    rm -f $(GNUSTEP_HEADERS)$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done

#
# Cleaning targets
#
internal-subproj-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-subproj-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

#
# Testing targets
#

endif

endif
# subproject.make loaded
