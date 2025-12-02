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
#   as published by the Free Software Foundation; either version 3
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.
#   If not, write to the Free Software Foundation,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

ifeq ($(BASE_MAKE_LOADED), yes)
ifeq ($(GNUSTEP_BASE_HAVE_LIBXML), 1)

ifeq ($(AUTOGSDOC),)
  AUTOGSDOC = autogsdoc
endif

ifeq ($(PACKAGE_VERSION),)
  PACKAGE_VERSION = $(VERSION)
  # Use a default of 0.0.1 if nothing better is provided.
  ifeq ($(PACKAGE_VERSION),)
    PACKAGE_VERSION = 0.0.1
  endif
endif

INTERNAL_AGSDOCFLAGS = \
	-Project $(GNUSTEP_INSTANCE) \
	-Version $(PACKAGE_VERSION) \

AGSDOC_FLAGS = $($(GNUSTEP_INSTANCE)_AGSDOC_FLAGS)

INTERNAL_AGSDOCFLAGS += $(AGSDOC_FLAGS)

# The autogsdoc output location may be specified with AGSDOC_LOCAL_DIR
# If unspecified, this defaults to using the project name (GNUSTEP_INSTANCE).
AGSDOC_LOCAL_DIR = $($(GNUSTEP_INSTANCE)_AGSDOC_LOCAL_DIR)
ifeq ($(AGSDOC_LOCAL_DIR),)
AGSDOC_LOCAL_DIR = $(GNUSTEP_INSTANCE)
endif
INTERNAL_AGSDOCFLAGS += -DocumentationDirectory "$(AGSDOC_LOCAL_DIR)"

# If there was no installation subdirectory use Developer by default.
# The make file can specify xxx_DOC_INSTALL_DIR=. to use the top level
# documentation directory by default.
ifeq ($(DOC_INSTALL_DIR),)
DOC_INSTALL_DIR = Developer
endif

# The autogsdoc output bundle is a directory within AGSDOC_INSTALL_DIR
# If unspecified, thes defaults to using the project name (GNUSTEP_INSTANCE).
AGSDOC_INSTALL_BUNDLE = $($(GNUSTEP_INSTANCE)_AGSDOC_INSTALL_BUNDLE)
ifeq ($(AGSDOC_INSTALL_BUNDLE),)
AGSDOC_INSTALL_BUNDLE = $(GNUSTEP_INSTANCE)
endif
AGSDOC_INSTALL_DIR = $(DOC_INSTALL_DIR)/$(AGSDOC_INSTALL_BUNDLE)

INTERNAL_AGSDOCFLAGS += \
	-InstallationDomain "$(GNUSTEP_INSTALLATION_DOMAIN)" \
	-InstallDir "$(AGSDOC_INSTALL_DIR)" \

ifeq ($(AGSDOC_INDEXING),yes)
INTERNAL_AGSDOCFLAGS += -GenerateHtml NO
endif

ifeq ($(AGSDOC_RELOCATABLE), yes)
INTERNAL_AGSDOCFLAGS += -RelocatableHtml YES
endif


internal-doc-all_:: \
	$(AGSDOC_LOCAL_DIR)/dependencies \
	$(AGSDOC_LOCAL_DIR)/dependencies_html \

# Only include (and implicitly automatically rebuild if needed) the
# dependencies file when we are compiling.  Ignore it when cleaning or
# installing.
ifeq ($(GNUSTEP_OPERATION), all)
-include $(AGSDOC_LOCAL_DIR)/dependencies
-include $(AGSDOC_LOCAL_DIR)/dependencies_html
endif

$(AGSDOC_LOCAL_DIR)/dependencies:
$(AGSDOC_LOCAL_DIR)/dependencies_html:
	$(ECHO_AUTOGSDOC)$(AUTOGSDOC) $(INTERNAL_AGSDOCFLAGS) -MakeDependencies $(AGSDOC_LOCAL_DIR)/dependencies $(AGSDOC_FILES)$(END_ECHO)

internal-doc-install_:: 
	$(ECHO_INSTALLING)rm -rf $(GNUSTEP_DOC)/$(AGSDOC_INSTALL_DIR); \
	$(MKDIRS) $(GNUSTEP_DOC)/$(AGSDOC_INSTALL_DIR); \
	(cd $(AGSDOC_LOCAL_DIR); $(TAR) cf - -X \
	$(GNUSTEP_MAKEFILES)/tar-exclude-list \
	* | (cd $(GNUSTEP_DOC)/$(AGSDOC_INSTALL_DIR); \
	$(TAR) xf -))$(END_ECHO)
ifneq ($(CHOWN_TO),)
	$(ECHO_CHOWNING)$(CHOWN) -R $(CHOWN_TO) \
	      $(GNUSTEP_DOC)/$(AGSDOC_INSTALL_DIR)$(END_ECHO)
endif

internal-doc-uninstall_:: 
	-$(ECHO_UNINSTALLING)rm -rf $(GNUSTEP_DOC)/$(AGSDOC_INSTALL_DIR)$(END_ECHO)

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
