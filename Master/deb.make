#   -*-makefile-*-
#   deb.make
#
#   Makefile rules to build a Debian package
#
#   Copyright (C) 2013 Free Software Foundation, Inc.
#
#   Author: Ivan Vucica <ivan@vucica.net>
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

#
# This file provides targets 'deb' and 'debfile'.
#
# - debfile - produces a 'packagename.debequivs' file, which can be
#             processed by program 'equivs-build' inside Debian package
#             'equivs'. Such processing will produce file named
#             gomoku_1.1.1_i386.deb (for example).
# - deb     - runs 'equivs'build.
#
# Processor architecture is detected from output of $(CC) -dumpmachine.
# If $(CC) is not defined, gcc is used.

# [1] Add - after common.make - the following lines in your GNUmakefile:
#
# PACKAGE_NAME = Gomoku
# PACKAGE_VERSION = 1.1.1
# 
# The other important variable you may want to set in your makefiles is
#
# GNUSTEP_INSTALLATION_DOMAIN - Installation domain (defaults to LOCAL)
#
# A special note: if you need `./configure' to be run before
# compilation (usually only needed for GNUstep core libraries
# themselves), define the following make variable:
#
# PACKAGE_NEEDS_CONFIGURE = yes
#
# in your makefile.

ifeq ($(CC), )
  CC=cc
endif
_DEB_ARCH=$(GNUSTEP_TARGET_CPU) # $(shell (/bin/bash -c "$(CC) -dumpmachine | sed -e 's,\\([^-]*\\).*,\\1,g'"))
_DEB_LOWERCASE_PACKAGE_NAME=$(shell (echo $(PACKAGE_NAME) | sed -e 's/\(.*\)/\L\1/'))

_DEB_VERSION=$(PACKAGE_VERSION)
ifeq ($(_DEB_VERSION), )
  _DEB_VERSION=$(VERSION)
endif
_DEB_ORIGTARNAME=$(_DEB_LOWERCASE_PACKAGE_NAME)_$(_DEB_VERSION)
_DEB_FILE=$(_DEB_TARNAME)_$(_DEB_ARCH).deb

_ABS_OBJ_DIR=$(shell (cd "$(GNUSTEP_BUILD_DIR)"; pwd))/obj

ifeq ($(DEB_BUILD_DEPENDS), )
DEB_BUILD_DEPENDS=gnustep-make (=$(GNUSTEP_MAKE_VERSION))
else
DEB_BUILD_DEPENDS=$(DEB_BUILD_DEPENDS), gnustep-make (=$(GNUSTEP_MAKE_VERSION))
endif

.PHONY: deb

ifeq ($(_DEB_SHOULD_EXPORT), )
../$(PACKAGE_NAME)-$(PACKAGE_VERSION).tar.gz: dist
deb: ../$(PACKAGE_NAME)-$(PACKAGE_VERSION).tar.gz
	_DEB_SHOULD_EXPORT=1 make deb
else
# Export all variables, but only in explicit invocation of 'make deb'
export
deb:
	$(ECHO_NOTHING)echo "Generating the deb package..."$(END_ECHO)
	-rm -rf $(_ABS_OBJ_DIR)/debian_dist
	mkdir -p $(_ABS_OBJ_DIR)/debian_dist
	cp ../$(PACKAGE_NAME)-$(PACKAGE_VERSION).tar.gz $(_ABS_OBJ_DIR)/debian_dist/$(_DEB_ORIGTARNAME).orig.tar.gz
	cd $(_ABS_OBJ_DIR)/debian_dist && tar xfz $(_DEB_ORIGTARNAME).orig.tar.gz
	/bin/bash $(GNUSTEP_MAKEFILES)/bake_debian_files.sh $(_ABS_OBJ_DIR)/debian_dist/$(PACKAGE_NAME)-$(PACKAGE_VERSION)/
	printf "\noverride_dh_auto_configure:\n\tdh_auto_configure -- $(DEB_CONFIGURE_FLAGS)\noverride_dh_auto_build:\n\tmake\n\tdh_auto_build\nbuild::\n\tmake" >> $(_ABS_OBJ_DIR)/debian_dist/$(PACKAGE_NAME)-$(PACKAGE_VERSION)/debian/rules
	cd $(_ABS_OBJ_DIR)/debian_dist/$(PACKAGE_NAME)-$(PACKAGE_VERSION)/ && debuild -us -uc
endif
