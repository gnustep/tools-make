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
	$(MKDIRS) $@

# FIXME: We need appropriate rules here to determine when to run
# autogsdoc ... this simplistic rule inefficiently runs autogsdoc
# every time.
generate-autogsdoc: $(GNUSTEP_INSTANCE)
	$(AUTOGSDOC) $(INTERNAL_AGSDOCFLAGS) $(AGSDOC_FILES)

internal-doc-install_:: 
	rm -rf $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)
	$(TAR) cf - $(GNUSTEP_INSTANCE) | \
	  (cd $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR); $(TAR) xf -)
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) \
	      $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)
endif

internal-doc-uninstall_:: 
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)

internal-doc-clean::
	@ -rm -Rf $(GNUSTEP_INSTANCE)

else

internal-doc-all_::
	@echo "No libxml - processing of autogsdoc files skipped"

endif # GNUSTEP_BASE_HAVE_LIBXML
