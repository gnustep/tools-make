#
#   java.make
#
#   Makefile rules to build java-based (not necessarily GNUstep) packages.
#
#   Copyright (C) 2000 Free Software Foundation, Inc.
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

# prevent multiple inclusions
ifeq ($(JAVA_PACKAGE_MAKE_LOADED),)
JAVA_PACKAGE_MAKE_LOADED=yes

#
# You can compile any set of java classes, it does not need to be strictly 
# a single package in the java sense.  Please put a single class in each 
# source file.  Multiple classes in a single source file are not supported.
#
# The name of the Java package is in the JAVA_PACKAGE_NAME variable.
# The java files to be compiled are in the xxx_JAVA_FILES variable;
# they should be specified in full relative path, such as: 
# test_JAVA_FILES = gnu/gnustep/base/NSArray.java
#
# The relative path is important because things will be installed 
# in $(JAVA_INSTALLATION_DIR)/{relative_path}; for example, 
# the file above would be installed in 
# ${JAVA_INSTALLATION_DIR)/gnu/gnustep/base/NSArray.class
#
# JAVA_INSTALLATION_DIR contains the directory where you want to
# install your classes - it defaults to $(GNUSTEP_JAVA), which is
# $(GNUSTEP_LOCAL_ROOT)/Libraries/Java/.
#
# If you have all your files in a directory but want them to be
# installed with a different relative path, you can simply redefine 
# JAVA_INSTALLATION_DIR, as in the following example - 
# JAVA_INSTALLATION_DIR = $(GNUSTEP_JAVA)/gnu/gnustep/base/
#
# ((deprecated and will be removed)) The old way of managing this is
# by using another variable, called JAVA_PACKAGE_PREFIX: if non null,
# files will be installed in:
# ${JAVA_INSTALLATION_DIR)/${JAVA_PACKAGE_PREFIX}/{relative path}.
#
# If you have java sources to be processed throught JAVAH to create
# JNI headers, specify the files in xxx_JAVA_JNI_FILES.  The headers
# will be placed together with the source file (example: the header of
# gnu/gnustep/base/NSObject.java will be created as
# gnu/gnustep/base/NSObject.h) These headers are not installed.
#

JAVA_PACKAGE_NAME:=$(strip $(JAVA_PACKAGE_NAME))

#
# Include in the common makefile rules
#
include $(GNUSTEP_MAKEFILES)/rules.make

ifeq ($(INTERNAL_java_package_NAME),)

# This part gets included by the first invoked make process.
internal-all:: $(JAVA_PACKAGE_NAME:=.all.java-package.variables)

internal-install:: $(JAVA_PACKAGE_NAME:=.install.java-package.variables)

internal-uninstall:: $(JAVA_PACKAGE_NAME:=.uninstall.java-package.variables)

internal-clean:: $(JAVA_PACKAGE_NAME:=.clean.java-package.variables)

internal-distclean:: $(JAVA_PACKAGE_NAME:=.distclean.java-package.variables)

$(JAVA_PACKAGE_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.java-package.variables

else

# This is the directory where the java classses get
# installed. Normally this is /usr/GNUstep/Local/Libraries/Java/
ifeq ($(JAVA_INSTALLATION_DIR),)
  JAVA_INSTALLATION_DIR = $(GNUSTEP_JAVA)
endif

#
# Targets
#
internal-java_package-all:: before-$(TARGET)-all \
        $(JAVA_OBJ_FILES) $(JAVA_JNI_OBJ_FILES) $(SUBPROJECT_OBJ_FILES) \
        after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

internal-java_package-install:: internal-java_package-all install-java_package

# Support old unflexible way (JAVA_PACKAGE_PREFIX) to customize
# installation dir - deprecated and will be removed to keep the code clean.

# Deprecated on 25 Apr 2001.  Will be removed any time after 25 Jun 2001.

ifneq ($(JAVA_PACKAGE_PREFIX),)
  $(warning "WARNING - JAVA_PACKAGE_PREFIX is deprecated and will be removed - use JAVA_INSTALLATION_DIR instead")
  _WE_INSTALL_INTO=$(JAVA_INSTALLATION_DIR)/$(JAVA_PACKAGE_PREFIX)
else
  # When JAVA_PACKAGE_PREFIX is removed, simply replace all occurrences 
  # of _WE_INSTALL_INTO with JAVA_INSTALLATION_DIR
  _WE_INSTALL_INTO=$(JAVA_INSTALLATION_DIR)
endif

internal-install-java-dirs:: $(_WE_INSTALL_INTO)
	if [ "$(JAVA_OBJ_FILES)" != "" ]; then \
	  $(MKDIRS) $(addprefix $(_WE_INSTALL_INTO)/,$(dir $(JAVA_OBJ_FILES))); \
	fi

$(_WE_INSTALL_INTO):
	$(MKDIRS) $(_WE_INSTALL_INTO)

# Say that you have a Pisa.java source file.  Here we install both
# Pisa.class (the main class) and also, if they exist, all class files
# with names beginning wih Pisa$ (such as Pisa$1$Nicola.class); these
# files are generated for nested/inner classes, and must be installed
# as well.  The fact we need to install these files is the reason why
# the following is more complicated than you would think at first
# glance.
install-java_package:: internal-install-java-dirs
	 if [ "$(JAVA_OBJ_FILES)" != "" ]; then \
	    for file in $(JAVA_OBJ_FILES) __done; do \
	      if [ $$file != __done ]; then \
	        $(INSTALL_DATA) $$file $(_WE_INSTALL_INTO)/$$file ; \
		base=`dirname $$file`/`basename $$file .class` ; \
		for sub in $${base}[$$]*.class __done; do \
	          if [ $$sub != __done ]; then \
		    $(INSTALL_DATA) $$sub $(_WE_INSTALL_INTO)/$$sub ; \
		  fi; \
		done; \
	      fi; \
	    done; \
	  fi

#
# Cleaning targets
#
internal-java_package-clean::
	rm -f $(JAVA_OBJ_FILES)
	for file in $(JAVA_OBJ_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    base=`dirname $$file`/`basename $$file .class` ; \
	    for sub in $${base}[$$]*.class __done; do \
	      if [ $$sub != __done ]; then \
		rm -f $$sub; \
	      fi; \
	    done; \
	  fi; \
	done;
	rm -f $(JAVA_JNI_OBJ_FILES)

internal-java_package-distclean::

endif # INTERNAL_java_package_NAME

endif # java.make loaded

## Local variables:
## mode: makefile
## End:
