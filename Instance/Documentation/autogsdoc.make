#   -*-makefile-*-
#   Instance/Documentation/autogsdoc.make
#
#   Instance Makefile rules to build Autogsdoc documentation.
#
#   Copyright (C) 1998, 2000, 2001, 2002 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author: Nicola Pero <n.pero@mi.flashnet.it> 
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

ifeq ($(BASE_MAKE_LOADED), yes)
ifeq ($(GNUSTEP_BASE_HAVE_LIBXML), 1)

ifeq ($(AUTOGSDOC),)
  AUTOGSDOC = autogsdoc
endif

AGSDOC_FLAGS = $($(GNUSTEP_INSTANCE)_AGSDOC_FLAGS)

INTERNAL_AGSDOCFLAGS = -Project $(GNUSTEP_INSTANCE)
INTERNAL_AGSDOCFLAGS += -DocumentationDirectory $(GNUSTEP_INSTANCE)
INTERNAL_AGSDOCFLAGS += $(AGSDOC_FLAGS)

internal-doc-all_:: generate-autogsdoc

$(GNUSTEP_INSTANCE):
	$(ECHO_CREATING)$(MKDIRS) $@$(END_ECHO)

# FIXME: We need appropriate rules here to determine when to run
# autogsdoc ... this simplistic rule inefficiently runs autogsdoc
# every time.
generate-autogsdoc: $(GNUSTEP_INSTANCE)
	$(AUTOGSDOC) $(INTERNAL_AGSDOCFLAGS) $(AGSDOC_FILES)

internal-doc-install_:: 
	$(ECHO_INSTALLING)rm -rf $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE); \
	$(TAR) cf - $(GNUSTEP_INSTANCE) | \
	  (cd $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR); $(TAR) xf -)$(END_ECHO)
ifneq ($(CHOWN_TO),)
	$(ECHO_CHOWNING)$(CHOWN) -R $(CHOWN_TO) \
	      $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)$(END_ECHO)
endif

internal-doc-uninstall_:: 
	-$(ECHO_UNINSTALLING)rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)$(END_ECHO)

internal-doc-clean::
	-$(ECHO_NOTHING)rm -Rf $(GNUSTEP_INSTANCE)$(END_ECHO)

else

internal-doc-all_::
	@echo "No libxml - processing of autogsdoc files skipped"

endif # GNUSTEP_BASE_HAVE_LIBXML

else

internal-doc-all_::
	@echo "GNUstep-Base not installed - processing of autogsdoc files skipped"
	@echo "If you want to generate documentation, install GNUstep-base first"
	@echo "and then rerun make here"


endif # BASE_MAKE_LOADED
