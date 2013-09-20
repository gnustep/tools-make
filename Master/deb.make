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
#
# NOTE! NOTE! NOTE!
# equivs-build 2.0.9 has a bug and will NOT work with absolute
# paths, which is something this version of deb.make depends on.
# See: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=662946
#
# Until the patch goes into upstream 'equivs', you will need to 
# patch your /usr/bin/equivs-build manually. Find the line:
#  $install_files{"$2/$1"} = $1;
# change it to:
#  $install_files{"$2/".basename($1)} = $1;
#

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
DEB_BUILD=equivs-build

# the GNUstep Debian packages always put things in, e.g. /GNUstep/System, 
# so we need to match these regardless of the local filesystem layout
# Hackish way to get the installation dir/domain
DEB_DOMAIN=System
ifeq ($(GNUSTEP_INSTALLATION_DOMAIN), LOCAL)
  DEB_DOMAIN=Local
endif
# Which user would we install in? Use Local instead.
ifeq ($(GNUSTEP_INSTALLATION_DOMAIN), USER)
  DEB_DOMAIN=Local
endif
DEB_BASE=$(dir $(GNUSTEP_APPS))

ABS_OBJ_DIR=$(shell (cd "$(GNUSTEP_BUILD_DIR)"; pwd))/obj
GNUSTEP_FILE_LIST = $(ABS_OBJ_DIR)/package/file-list
REL_INSTALL_DIR=$(GNUSTEP_OBJ_DIR)/package/$(DEB_BASE)

ifeq ($(CC), )
  CC=gcc
endif
DEB_ARCHITECTURE=$(shell (/bin/bash -c "$(CC) -dumpmachine | sed -e 's,\\([^-]*\\).*,\\1,g'"))
DEB_LOWERCASE_PACKAGE_NAME=$(shell (echo $(PACKAGE_NAME) | sed -e 's/\(.*\)/\L\1/'))

DEB_FILE_NAME=$(PACKAGE_NAME).debequivs
DEB_FILE=$(DEB_LOWERCASE_PACKAGE_NAME)_$(VERSION)_$(DEB_ARCHITECTURE).deb
DEB_TEMPLATE=$(GNUSTEP_MAKEFILES)/deb-equivs-control.template
DEB_IN=$(PACKAGE_NAME).control.in

# DEB_DESTINATION=\$$DOMDIR
DEB_DESTINATION=/GNUstep

.PHONY: debfile deb deb_package_install deb_build_filelist

deb_package_install:
	$(ECHO_NOTHING)if [ -d $(ABS_OBJ_DIR)/package ]; then \
	  rm -rf $(ABS_OBJ_DIR)/package; fi;$(END_ECHO)
	$(ECHO_NOTHING)$(MAKE) DESTDIR=$(ABS_OBJ_DIR)/package deblist=yes install$(END_ECHO)

#
# Target to build up the file lists
#
deb_build_filelist::
	# Note: 'readlink -f PATH' is here in place of 'realpath'.
	# While 'readlink' is not available everywhere, it's available under Debian,
	# and that's what counts.
	$(ECHO_NOTHING)rm -f $(GNUSTEP_FILE_LIST)$(END_ECHO)
	$(ECHO_NOTHING)echo -n "Files:" > $(GNUSTEP_FILE_LIST)$(END_ECHO)
	$(ECHO_NOTHING)cdir="nosuchdirectory";					\
	for file in `$(TAR) Pcf - $(REL_INSTALL_DIR) | $(TAR) t`; do		\
	  wfile=`echo $$file | sed "s,$(REL_INSTALL_DIR),,"`;	\
	  wodir=`readlink -f $(REL_INSTALL_DIR)`;				\
	  wodir="$$wodir/";							\
	  slashsuffix=`basename $${file}yes`;					\
	  if [ "$$slashsuffix" = yes ]; then					\
	    newdir=`dirname $$file`/`basename $$file`;				\
	  else									\
	    newdir=`dirname $$file`;						\
	  fi;									\
	  if [ "$$file" = "$(REL_INSTALL_DIR)/" ]; then				\
	    :;									\
	  elif [ -d "$$file" ]; then						\
	    cdir=$$newdir;							\
	    wdir=$$wfile;							\
	  elif [ $$cdir != $$newdir ]; then					\
	    cdir=$$newdir;							\
	    wdir=`dirname "$$wfile"`;						\
	    echo " $$wodir$$wfile $(DEB_DESTINATION)/$(DEB_DOMAIN)/$$wdir" >> $(GNUSTEP_FILE_LIST); \
	  else									\
	    echo " $$wodir$$wfile $(DEB_DESTINATION)/$(DEB_DOMAIN)/$$wdir" >> $(GNUSTEP_FILE_LIST); \
	  fi;									\
	done$(END_ECHO)                                                    

#
# The user will type `make debfile' to generate the equivs control file
#
debfile: $(DEB_FILE_NAME)

#
# This is the real target
#
$(DEB_FILE_NAME): deb_package_install deb_build_filelist
	$(ECHO_NOTHING)echo "Generating the deb equivs control file..."$(END_ECHO)
	$(ECHO_NOTHING)rm -f $@$(END_ECHO)
	$(ECHO_NOTHING)if [ -f $(DEB_IN) ]; then		\
	  deb_infile=${DEB_IN};					\
	  else							\
	  deb_infile=${DEB_TEMPLATE}; fi;			\
	  sed -e :t						\
	    -e "s,@gs_domain@,$(DEB_DOMAIN),;t t"		\
	    -e "s,@gs_name@,$(DEB_LOWERCASE_PACKAGE_NAME),;t t"	\
	    -e "s,@gs_version@,$(PACKAGE_VERSION),;t t"		\
	    -e "s,@gs_arch@,$(DEB_ARCHITECTURE),;t t"		\
	    -e "/@file_list@/{ r ${GNUSTEP_FILE_LIST}" -e "d}"	\
		$$deb_infile > $@				\
	$(END_ECHO)

deb: debfile
	$(ECHO_NOTHING)echo "Generating the deb package..."$(END_ECHO)
	${DEB_BUILD} $(DEB_FILE_NAME)

