#
#   Shared/headers.make
#
#   Makefile fragment with rules to install header files
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
#  $(GNUSTEP_INSTANCE)_HEADER_FILES : the list of .h files to install
#
#  $(GNUSTEP_INSTANCE)_HEADER_FILES_DIR : the dir in which the .h files are;
#  defaults to `.' if no set.
#
#  $(GNUSTEP_INSTANCE)_HEADER_FILES_INSTALL_DIR : the dir in which to install
#  the .h files; defaults to $(GNUSTEP_INSTANCE) if not set.
#
#  $(GNUSTEP_INSTANCE)_EMPTY_HEADER_FILES_INSTALL_DIR : if this is set to YES
#  then an empty $(GNUSTEP_INSTANCE)_HEADER_FILES_INSTALL_DIR is tollerated 
#  and the $(GNUSTEP_INSTANCE) default not used.  This is an exceptional 
#  behaviour and you don't want it unless you really know what you're doing.
#

#
# public targets:
# 
#  shared-instance-headers-install 
#  shared-instance-headers-uninstall
#


# NB: The 'override' in all this file are needed to override the
# Master/rules.make setting of HEADER_FILES and similar variables.
# Once that setting will be removed (as it should be), the 'override'
# in this file should be removed as well.
override HEADER_FILES = $($(GNUSTEP_INSTANCE)_HEADER_FILES)

.PHONY: \
shared-install-headers-install \
shared-install-headers-uninstall

ifeq ($(HEADER_FILES),)

shared-instance-headers-install:

shared-instance-headers-uninstall:

else # we have some HEADER_FILES

override HEADER_FILES_DIR = $($(GNUSTEP_INSTANCE)_HEADER_FILES_DIR)

ifeq ($(HEADER_FILES_DIR),)
override HEADER_FILES_DIR = .
endif

override HEADER_FILES_INSTALL_DIR = $($(GNUSTEP_INSTANCE)_HEADER_FILES_INSTALL_DIR)

ifeq ($(HEADER_FILES_INSTALL_DIR),)
ifneq ($($(GNUSTEP_INSTANCE)_EMPTY_HEADER_FILES_INSTALL_DIR),YES)
override HEADER_FILES_INSTALL_DIR = $(GNUSTEP_INSTANCE)
endif
endif

shared-instance-headers-install: $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $(HEADER_FILES_DIR)/$$file \
	              $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR)/$$file; \
	  fi; \
	done

$(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR):
	$(MKINSTALLDIRS) $@


shared-instance-headers-uninstall:
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    rm -rf $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done

# TODO - during uninstall, it would be pretty to remove
# $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR) if it's empty.

endif # HEADER_FILES = ''

## Local variables:
## mode: makefile
## End:
