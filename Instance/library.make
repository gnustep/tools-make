 #  -*-makefile-*-
#   Instance/library.make
#
#   Instance Makefile rules to build GNUstep-based libraries.
#
#   Copyright (C) 1997, 2001 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#	     Ovidiu Predescu <ovidiu@net-community.com>
#            Nicola Pero     <nicola@brainstorm.co.uk>
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

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

include $(GNUSTEP_MAKEFILES)/Instance/Shared/headers.make

#
# The name of the library (including the 'lib' prefix) is 
# in the LIBRARY_NAME variable.
# The Objective-C files that gets included in the library are in xxx_OBJC_FILES
# The C files are in xxx_C_FILES
# The pswrap files are in xxx_PSWRAP_FILES
# The header files are in xxx_HEADER_FILES
# The directory where the header files are located is xxx_HEADER_FILES_DIR
# The directory where to install the header files inside the library
# installation directory is xxx_HEADER_FILES_INSTALL_DIR
# The DLL export file is in xxx_DLL_DEF
#
#	Where xxx is the name of the library
#

.PHONY: internal-library-all_ \
        internal-library-install_ \
        internal-library-uninstall_ \
        internal-install-lib \
        internal-install-dirs

# This is the directory where the libs get installed.  This should *not*
# include the target arch, os directory or library_combo.
ifeq ($(LIBRARY_INSTALL_DIR),)
  LIBRARY_INSTALL_DIR = $(GNUSTEP_LIBRARIES)
endif

# And this is used internally - it is the final directory where we put the 
# library - it includes target arch, os dir and library_combo - this variable
# is PRIVATE to gnustep-make
#
# Do not set this variable if it is already set ... this allows other
# makefiles (Instance/clibrary.make) to use the code in this file with
# a different FINAL_LIBRARY_INSTALL_DIR !
#
ifeq ($(FINAL_LIBRARY_INSTALL_DIR),)
  FINAL_LIBRARY_INSTALL_DIR = $(LIBRARY_INSTALL_DIR)/$(GNUSTEP_TARGET_LDIR)
endif

# 
# Manage the case that LIBRARY_NAME starts with 'lib', and the case
# that it doesn't start with 'lib'.  In both cases, we need to create
# a .so file whose name starts with 'lib'.
#
ifneq ($(filter lib%,$(GNUSTEP_INSTANCE)),)
  LIBRARY_NAME_WITH_LIB = $(GNUSTEP_INSTANCE)
else
  LIBRARY_NAME_WITH_LIB = lib$(GNUSTEP_INSTANCE)
endif

INTERNAL_LIBRARIES_DEPEND_UPON =				\
  $(shell $(WHICH_LIB_SCRIPT)					\
   $(ALL_LIB_DIRS)						\
   $(LIBRARIES_DEPEND_UPON)					\
   debug=$(debug) profile=$(profile) shared=$(shared)		\
   libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

ifeq ($(shared), yes)

ifneq ($(BUILD_DLL),yes)

LIBRARY_FILE = $(LIBRARY_NAME_WITH_LIB)$(LIBRARY_NAME_SUFFIX)$(SHARED_LIBEXT)
LIBRARY_FILE_EXT     = $(SHARED_LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE).$(VERSION)

# Allow the user GNUmakefile to define xxx_SOVERSION to replace the
# default SOVERSION for this library.

# Effect of the value of SOVERSION - 

#  suppose your library is libgnustep-base.1.0.0 - if you do nothing,
#  SOVERSION=1, and we prepare the symlink libgnustep-base.so.1 -->
#  libgnustep-base.so.1.0.0 and tell the linker that it should
#  remember that any application compiled against this library need to
#  use version .1 of the library.  So at runtime, the dynamical linker
#  will search for libgnustep-base.so.1.  This is important if you
#  install multiple versions of the same library.  The default is that
#  if you install a new version of a library with the same major
#  number, the new version replaces the old one, and all applications
#  which were using the old one now use the new one.  If you install a
#  library with a different major number, the old apps will still use
#  the old library, while newly compiled apps will use the new one.

#  If you redefine SOVERSION to be for example 1.0, then we prepare
#  the symlink libgnustep-base.so.1.0 --> libgnustep-base.so.1.0.0
#  instead, and tell the linker to remember 1.0.  So at runtime, the
#  dynamic linker will search for libgnustep-base.so.1.0.  The
#  effect of changing SOVERSION to major.minor as in this example is
#  that if you install a new version with the same major.minor
#  version, that replaces the old one also for old applications, but
#  if you install a new library with the same major version but a
#  *different* minor version, that is used in new apps, but old apps
#  still use the old version.

ifeq ($($(GNUSTEP_INSTANCE)_SOVERSION),)
  SOVERSION = $(word 1,$(subst ., ,$(VERSION)))
else
  SOVERSION = $($(GNUSTEP_INSTANCE)_SOVERSION)
endif
SONAME_LIBRARY_FILE  = $(LIBRARY_FILE).$(SOVERSION)

else # BUILD_DLL

LIBRARY_FILE     = $(LIBRARY_NAME_WITH_LIB)$(LIBRARY_NAME_SUFFIX)$(DLL_LIBEXT)
LIBRARY_FILE_EXT = $(DLL_LIBEXT)
DLL_NAME         = $(shell echo $(LIBRARY_FILE)|cut -b 4-)
DLL_EXP_LIB      = $(LIBRARY_NAME_WITH_LIB)$(LIBRARY_NAME_SUFFIX)$(SHARED_LIBEXT)
DLL_EXP_DEF      = $(LIBRARY_NAME_WITH_LIB)$(LIBRARY_NAME_SUFFIX).def

ifeq ($(DLL_INSTALLATION_DIR),)
  DLL_INSTALLATION_DIR = $(GNUSTEP_TOOLS)/$(GNUSTEP_TARGET_LDIR)
endif

endif # BUILD_DLL

else # shared

LIBRARY_FILE         = $(LIBRARY_NAME_WITH_LIB)$(LIBRARY_NAME_SUFFIX)$(LIBEXT)
LIBRARY_FILE_EXT     = $(LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE)
SONAME_LIBRARY_FILE  = $(LIBRARY_FILE)

endif # shared

#
# Now prepare the variables which are used by target-dependent commands
# defined in target.make
#
LIB_LINK_OBJ_DIR = $(GNUSTEP_OBJ_DIR)
LIB_LINK_VERSION_FILE = $(VERSION_LIBRARY_FILE)
LIB_LINK_SONAME_FILE = $(SONAME_LIBRARY_FILE)
LIB_LINK_FILE = $(LIBRARY_FILE)
LIB_LINK_INSTALL_NAME = $(SONAME_LIBRARY_FILE)
LIB_LINK_INSTALL_DIR = $(FINAL_LIBRARY_INSTALL_DIR)

#
# Internal targets
#

#
# Compilation targets
#

ifeq ($(BUILD_DLL),yes)

DLL_DEF = $($(GNUSTEP_INSTANCE)_DLL_DEF)
DLL_DEF_FILES = $(SUBPROJECT_DEF_FILES) $(DLL_DEF)

ifneq ($(strip $(DLL_DEF_FILES)),)
DLL_DEF_INP = $(DERIVED_SOURCES_DIR)/$(GNUSTEP_INSTANCE).inp

$(DLL_DEF_INP): $(DLL_DEF_FILES)
	cat $(DLL_DEF_FILES) > $@

DLL_DEF_FLAG = --input-def $(DLL_DEF_INP)
endif

# Pass -DBUILD_lib{library_name}_DLL=1 to the preprocessor.  The
# library header files can use this preprocessor define to know that
# they are included during compilation of the library itself, and can
# then use __declspec(dllexport) to export symbols
CLEAN_library_NAME = $(shell echo $(LIBRARY_NAME_WITH_LIB)|tr '-' '_')
SHARED_CFLAGS += -DBUILD_$(CLEAN_library_NAME)_DLL=1

internal-library-all_:: \
	$(GNUSTEP_OBJ_DIR)			\
	$(DERIVED_SOURCES_DIR)			\
	$(DLL_DEF_INP)				\
	$(DERIVED_SOURCES_DIR)/$(GNUSTEP_INSTANCE).def	\
	$(GNUSTEP_OBJ_DIR)/$(DLL_NAME)		\
	$(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB)

internal-library-clean::
	$(ECHO_NOTHING)rm -rf $(DERIVED_SOURCES_DIR)$(END_ECHO)

$(DERIVED_SOURCES_DIR):
	$(ECHO_CREATING)$(MKDIRS) $@$(END_ECHO)

$(DERIVED_SOURCES_DIR)/$(GNUSTEP_INSTANCE).def: $(OBJ_FILES_TO_LINK) $(DLL_DEF_INP)
	$(ECHO_NOTHING)$(DLLTOOL) $(DLL_DEF_FLAG) --output-def $@ $(OBJ_FILES_TO_LINK)$(END_ECHO)

$(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB): $(DERIVED_SOURCES_DIR)/$(GNUSTEP_INSTANCE).def
	$(ECHO_NOTHING)$(DLLTOOL) --dllname $(DLL_NAME) --def $< --output-lib $@$(END_ECHO)

$(GNUSTEP_OBJ_DIR)/$(DLL_NAME): $(OBJ_FILES_TO_LINK) \
                               $(DERIVED_SOURCES_DIR)/$(GNUSTEP_INSTANCE).def
	$(ECHO_LINKING)$(DLLWRAP) --driver-name $(CC) \
	  $(SHARED_LD_PREFLAGS) \
	  --def $(DERIVED_SOURCES_DIR)/$(GNUSTEP_INSTANCE).def \
	  -o $@ $(OBJ_FILES_TO_LINK) \
	  $(INTERNAL_LIBRARIES_DEPEND_UPON) $(TARGET_SYSTEM_LIBS) \
	  $(SHARED_LD_POSTFLAGS)$(END_ECHO)

else # BUILD_DLL

internal-library-all_:: $(GNUSTEP_OBJ_DIR) \
                        $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE)

$(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE): $(OBJ_FILES_TO_LINK)
	$(ECHO_LINKING)$(LIB_LINK_CMD)$(END_ECHO)

endif # BUILD_DLL

#
# Install and uninstall targets
#
internal-library-install_:: internal-install-dirs \
                            internal-install-lib \
                            shared-instance-headers-install

# Depend on creating all the dirs
internal-install-dirs:: $(FINAL_LIBRARY_INSTALL_DIR) \
                          $(DLL_INSTALLATION_DIR)

# Now the rule to create each dir.  NB: Nothing gets executed if the dir 
# already exists
$(FINAL_LIBRARY_INSTALL_DIR):
	$(ECHO_CREATING)$(MKINSTALLDIRS) $@$(END_ECHO)

$(DLL_INSTALLATION_DIR):
	$(ECHO_CREATING)$(MKINSTALLDIRS) $@$(END_ECHO)

ifeq ($(BUILD_DLL),yes)

internal-install-lib::
	$(ECHO_INSTALLING)if [ -f $(GNUSTEP_OBJ_DIR)/$(DLL_NAME) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(DLL_NAME) \
	                     $(DLL_INSTALLATION_DIR) ; \
	fi; \
	if [ -f $(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB) \
	                     $(FINAL_LIBRARY_INSTALL_DIR) ; \
	fi$(END_ECHO)

else

internal-install-lib::
	$(ECHO_INSTALLING)if [ -f $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) \
	                     $(FINAL_LIBRARY_INSTALL_DIR) ; \
	  $(AFTER_INSTALL_LIBRARY_CMD) \
	fi$(END_ECHO)

endif

ifeq ($(BUILD_DLL),yes)

internal-library-uninstall_:: shared-instance-headers-uninstall
	$(ECHO_UNINSTALLING)rm -f $(DLL_INSTALLATION_DIR)/$(DLL_NAME) \
	      $(FINAL_LIBRARY_INSTALL_DIR)/$(DLL_EXP_LIB)$(END_ECHO)

else

internal-library-uninstall_:: shared-instance-headers-uninstall
	$(ECHO_UNINSTALLING)rm -f $(FINAL_LIBRARY_INSTALL_DIR)/$(VERSION_LIBRARY_FILE) \
	      $(FINAL_LIBRARY_INSTALL_DIR)/$(LIBRARY_FILE) \
	      $(FINAL_LIBRARY_INSTALL_DIR)/$(SONAME_LIBRARY_FILE)$(END_ECHO)
endif

#
# Testing targets
#
internal-library-check::

include $(GNUSTEP_MAKEFILES)/Instance/Shared/strings.make
