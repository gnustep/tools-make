#
#   Instace/resources.make
#
#   Instance makefile rules to install resource files
#
#   Copyright (C) 2002 Free Software Foundation, Inc.
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

#
# The name of the set of resources is in the RESOURCE_SET_NAME variable.
# The list of resource file are in xxx_RESOURCE_FILES
# The list of resource directories to create are in xxx_RESOURCE_DIRS
# The directory in which to install the resources is in the
#                xxx_RESOURCE_FILES_INSTALL_DIR
# The directory in which the resources are is in the 
#                xxx_RESOURCE_FILES_DIR (defaults to ./ if omitted)
#

.PHONY: internal-resource_set-install \
       internal-resource_set-uninstall

# Determine installation dir
RESOURCE_FILES_INSTALL_DIR = $($(GNUSTEP_INSTANCE)_RESOURCE_FILES_INSTALL_DIR)
RESOURCE_FILES_FULL_INSTALL_DIR = $(GNUSTEP_INSTALLATION_DIR)/$(RESOURCE_FILES_INSTALL_DIR)

# Rule to build the installation dir
$(RESOURCE_FILES_FULL_INSTALL_DIR):
	$(MKDIRS) $@

# Determine the additional installation dirs to build
RESOURCE_DIRS = $($(GNUSTEP_INSTANCE)_RESOURCE_DIRS)

ifneq ($(RESOURCE_DIRS),)
# Rule to build the additional installation dirs
$(RESOURCE_FILES_FULL_INSTALL_DIR)/$(RESOURCE_DIRS):
	$(MKDIRS) $@
endif

# Determine the dir to take the resources from
RESOURCE_FILES_DIR = $($(GNUSTEP_INSTANCE)_RESOURCE_FILES_DIR)
ifeq ($(RESOURCE_FILES_DIR),)
  RESOURCE_FILES_DIR = ./
endif

# Determine the list of resource files
RESOURCE_FILES = $($(GNUSTEP_INSTANCE)_RESOURCE_FILES)

#
# We provide two different algorithms of installing resource files.
#

ifeq ($(GNUSTEP_DEVELOPER),)

# Standard one - just run a subshell and loop, and install everything.
internal-resource_set-install: $(RESOURCE_FILES_FULL_INSTALL_DIR) \
                        $(RESOURCE_FILES_FULL_INSTALL_DIR)/$(RESOURCE_DIRS)
	for file in $(RESOURCE_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $(RESOURCE_FILES_DIR)/$$file \
	                    $(RESOURCE_FILES_FULL_INSTALL_DIR)/$$file; \
	  fi; \
	done

else

# One optimized for recurrent installations during development - this
# rule installs a single file only if strictly needed
$(RESOURCE_FILES_INSTALL_DIR)/% : $(RESOURCE_FILES_DIR)/%
	$(INSTALL_DATA) $< $@

# This rule depends on having installed all files
internal-resource_set-install: \
   $(RESOURCE_FILES_FULL_INSTALL_DIR) \
   $(RESOURCE_FILES_FULL_INSTALL_DIR)/$(RESOURCE_DIRS) \
   $(addprefix $(RESOURCE_FILES_FULL_INSTALL_DIR)/,$(RESOURCE_FILES))

endif


internal-resource_set-uninstall:
	for file in $(RESOURCE_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    rm -rf $(RESOURCE_FILES_FULL_INSTALL_DIR)/$$file ; \
	  fi; \
	done

