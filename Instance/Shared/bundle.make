#
#   Shared/bundle.make
#
#   Makefile fragment with rules to copy resource files 
#   into a local bundle
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

#
# input variables:
#
#  GNUSTEP_SHARED_INSTANCE_BUNDLE_PATH : the path to the local
#  resource bundle.  Resource files will be copied into this path.
#  For example, for a normal bundle it would be $(BUNDLE_DIR)/Resources; 
#  for an application it would be $(APP_DIR)/Resources; etc
#
#  $(GNUSTEP_INSTANCE)_RESOURCE_FILES : the list of resource files to install
#
#  $(GNUSTEP_INSTANCE)_RESOURCE_DIRS : the list of additional resource dirs
#  to create.
#
#  $(GNUSTEP_INSTANCE)_LANGUAGES : the list of languages of localized resource
#  files
#
#  $(GNUSTEP_INSTANCE)_LOCALIZED_RESOURCE_FILES : the list of localized
#  resource files to install
#
#  GNUSTEP_TYPE : used when printing the message 'Copying resources into 
#  the $(GNUSTEP_TYPE) wrapper...'
#

#
# public targets:
# 
#  shared-instance-bundle-all
#
#  $(GNUSTEP_SHARED_INSTANCE_BUNDLE_PATH): Creates the bundle path (invoked
#  automatically)
#

# NB: The 'override' in all this file are needed to override the
# Master/rules.make setting of LANGUAGES and similar variables.
# Once that setting will be removed (as it should be), the 'override'
# in this file should be removed as well.
override RESOURCE_FILES = $(strip $($(GNUSTEP_INSTANCE)_RESOURCE_FILES))
override RESOURCE_DIRS = $(strip $($(GNUSTEP_INSTANCE)_RESOURCE_DIRS))
override LANGUAGES = $(strip $($(GNUSTEP_INSTANCE)_LANGUAGES))
override LOCALIZED_RESOURCE_FILES = $(strip $($(GNUSTEP_INSTANCE)_LOCALIZED_RESOURCE_FILES))

.PHONY: \
shared-instance-bundle-all \
shared-instance-bundle-all-resources \
shared-instance-bundle-all-localized-resources

ifneq ($(RESOURCE_DIRS),)

FULL_RESOURCE_DIRS = \
$(foreach d, $(RESOURCE_DIRS), $(GNUSTEP_SHARED_INSTANCE_BUNDLE_PATH)/$(d))

endif

ifeq ($(LANGUAGES),)
override LANGUAGES = English
endif

# TODO - rewrite all this so that we only copy resources if they have
# changed!

shared-instance-bundle-all: $(GNUSTEP_SHARED_INSTANCE_BUNDLE_PATH) $(FULL_RESOURCE_DIRS)
ifneq ($(RESOURCE_FILES),)
	@(echo "Copying resources into the $(GNUSTEP_TYPE) wrapper..."; \
	for f in "$(RESOURCE_FILES)"; do \
	  cp -r $$f $(GNUSTEP_SHARED_INSTANCE_BUNDLE_PATH); \
	done)
endif
ifneq ($(LOCALIZED_RESOURCE_FILES),)
	@(echo "Copying localized resources into the $(GNUSTEP_TYPE) wrapper..."; \
	for l in $(LANGUAGES); do \
	  if [ -d $$l.lproj ]; then \
	    $(MKDIRS) $(GNUSTEP_SHARED_INSTANCE_BUNDLE_PATH)/$$l.lproj; \
	    for f in $(LOCALIZED_RESOURCE_FILES); do \
	      if [ -f $$l.lproj/$$f ]; then \
	        cp -r $$l.lproj/$$f \
	              $(GNUSTEP_SHARED_INSTANCE_BUNDLE_PATH)/$$l.lproj; \
	      fi; \
	    done; \
	  else \
	    echo "Warning: $$l.lproj not found - ignoring"; \
	  fi; \
	done)
endif

$(GNUSTEP_SHARED_INSTANCE_BUNDLE_PATH):
	$(MKDIRS) $@

$(FULL_RESOURCE_DIRS):
	$(MKDIRS) $@

## Local variables:
## mode: makefile
## End:
