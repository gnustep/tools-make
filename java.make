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
# If you have java sources to be processed throught JAVAH to create
# JNI headers, specify the files in xxx_JAVA_JNI_FILES.  The headers
# will be placed together with the source file (example: the header of
# gnu/gnustep/base/NSObject.java will be created as
# gnu/gnustep/base/NSObject.h) These headers are not installed.
#
# If you have properties file to install, put them in the
# xxx_JAVA_PROPERTIES_FILES

JAVA_PACKAGE_NAME:=$(strip $(JAVA_PACKAGE_NAME))

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

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

.PHONY: internal-java_package-all \
        internal-java_package-clean \
        internal-java_package-distclean \
        internal-java_package-install \
        internal-java_package-uninstall \
        before-$(TARGET)-all \
        after-$(TARGET)-all \
        install-java_package \
        internal-install-java-dirs

# This is the directory where the java classses get
# installed. Normally this is /usr/GNUstep/Local/Libraries/Java/
ifeq ($(JAVA_INSTALLATION_DIR),)
  JAVA_INSTALLATION_DIR = $(GNUSTEP_JAVA)
endif

#
# Targets
#
internal-java_package-all:: before-$(TARGET)-all \
                            $(JAVA_OBJ_FILES) \
                            $(JAVA_JNI_OBJ_FILES) \
                            $(SUBPROJECT_OBJ_FILES) \
                            after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

internal-java_package-install:: install-java_package

internal-install-java-dirs:: $(JAVA_INSTALLATION_DIR)
ifneq ($(JAVA_OBJ_FILES),)
	$(MKINSTALLDIRS) \
           $(addprefix $(JAVA_INSTALLATION_DIR)/,$(dir $(JAVA_OBJ_FILES)))
endif

$(JAVA_INSTALLATION_DIR):
	$(MKINSTALLDIRS) $(JAVA_INSTALLATION_DIR)

# Say that you have a Pisa.java source file.  Here we install both
# Pisa.class (the main class) and also, if they exist, all class files
# with names beginning wih Pisa$ (such as Pisa$1$Nicola.class); these
# files are generated for nested/inner classes, and must be installed
# as well.  The fact we need to install these files is the reason why
# the following is more complicated than you would think at first
# glance.

# Build efficiently the list of possible inner/nested classes 

# We first build a list like in `Pisa[$]*.class Roma[$]*.class' by
# taking the JAVA_OBJ_FILES and replacing .class with [$]*.class, then
# we use wildcard to get the list of all files matching the pattern
UNESCAPED_ADD_JAVA_OBJ_FILES = $(wildcard $(JAVA_OBJ_FILES:.class=[$$]*.class))

# Finally we need to escape the $s before passing the filenames to the
# shell
ADDITIONAL_JAVA_OBJ_FILES = $(subst $$,\$$,$(UNESCAPED_ADD_JAVA_OBJ_FILES))

JAVA_PROPERTIES_FILES = $($(INTERNAL_java_package_NAME)_JAVA_PROPERTIES_FILES)

install-java_package:: internal-install-java-dirs
ifneq ($(JAVA_OBJ_FILES),)
	for file in $(JAVA_OBJ_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $$file $(JAVA_INSTALLATION_DIR)/$$file ; \
	  fi; \
	done
endif
ifneq ($(ADDITIONAL_JAVA_OBJ_FILES),)
	for file in $(ADDITIONAL_JAVA_OBJ_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $$file $(JAVA_INSTALLATION_DIR)/$$file ; \
	  fi;    \
	done
endif
ifneq ($(JAVA_PROPERTIES_FILES),)
	for file in $(JAVA_PROPERTIES_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $$file $(JAVA_INSTALLATION_DIR)/$$file ; \
	  fi;    \
	done
endif

#
# Cleaning targets
#
internal-java_package-clean::
	rm -f $(JAVA_OBJ_FILES) \
	      $(ADDITIONAL_JAVA_OBJ_FILES) \
	      $(JAVA_JNI_OBJ_FILES)

internal-java_package-distclean::

# TODO - uninstall rule

endif # INTERNAL_java_package_NAME

endif # java.make loaded

## Local variables:
## mode: makefile
## End:
