#   -*-makefile-*-
#   Instance/Documentation/javadoc.make
#
#   Instance Makefile rules to build JavaDoc documentation.
#
#   Copyright (C) 1998, 2000, 2001, 2002 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Nicola Pero <n.pero@mi.flashnet.it> 
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

JAVADOC_SOURCEPATH = $($(GNUSTEP_INSTANCE)_JAVADOC_SOURCEPATH)

.PHONY: generate-javadoc

ifeq ($(JAVADOC),)
  JAVADOC = $(JAVA_HOME)/bin/javadoc
endif

ifeq ($(JAVADOC_SOURCEPATH),)
  INTERNAL_JAVADOCFLAGS = -sourcepath ./
else
  INTERNAL_JAVADOCFLAGS = -sourcepath ./:$(strip $(JAVADOC_SOURCEPATH))
endif

ALL_JAVADOCFLAGS = $(INTERNAL_CLASSPATHFLAGS) $(INTERNAL_JAVADOCFLAGS) \
$(ADDITIONAL_JAVADOCFLAGS) $(AUXILIARY_JAVADOCFLAGS)

# incremental compilation with javadoc is not supported - you can only
# build once, or always.  by default we build only once - use
# `JAVADOC_BUILD_ALWAYS = YES' to force rebuilding it always

ifneq ($(JAVADOC_BUILD_ALWAYS),YES) # Build only once

internal-doc-all_:: $(GNUSTEP_INSTANCE)/index.html

$(GNUSTEP_INSTANCE)/index.html:
	$(MKDIRS) $(GNUSTEP_INSTANCE); \
	$(JAVADOC) $(ALL_JAVADOCFLAGS) $(JAVADOC_FILES) -d $(GNUSTEP_INSTANCE)

else # Build always

internal-doc-all_:: generate-javadoc

generate-javadoc:
	$(MKDIRS) $(GNUSTEP_INSTANCE); \
	$(JAVADOC) $(ALL_JAVADOCFLAGS) $(JAVADOC_FILES) -d $(GNUSTEP_INSTANCE)

endif


#
# Javadoc installation
#
ifneq ($(JAVADOC_FILES),)

internal-doc-install_:: 
	rm -rf $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)
	$(TAR) cf - $(GNUSTEP_INSTANCE) |  \
	  (cd $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR); $(TAR) xf -)
ifneq ($(CHOWN_TO),)
	$(ECHO_CHOWNING)$(CHOWN) -R $(CHOWN_TO) \
	      $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)$(END_ECHO)
endif

internal-doc-uninstall_:: 
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)

endif # JAVADOC_FILES

internal-doc-clean::
	@ -rm -Rf $(GNUSTEP_INSTANCE)

internal-doc-distclean::

