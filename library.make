#
#   library.make
#
#   Makefile rules to build GNUstep-based libraries.
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

# prevent multiple inclusions
ifeq ($(LIBRARY_MAKE_LOADED),)
LIBRARY_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

#
# The name of the library is in the LIBRARY_NAME variable.
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

LIBRARY_NAME:=$(strip $(LIBRARY_NAME))

ifeq ($(INTERNAL_library_NAME),)
# This part is included the first time make is invoked.

# Short explanation of how gnustep-make works:
#
# The
#   internal-all:: $(LIBRARY_NAME:=.all.library.variables)
# eg expands to:
#   internal-all::
#     libobjc.all.library.variables libFoundation.all.library.variables
# that is,
#   $target.$operation.$type.variables
# for each target (word in the LIBRARY_NAME (list) variable)
#
# The %.variables is matched in rules.make which then kicks off a submake
# invocation; $($*_C_FILES) expands to the value of the variable
# libobjc_C_FILES which in turn is mapped in the nested invocation
# of make to the the plain C_FILES variable. In this step also
# which_lib is invoked to determine to correct library bindings.
# In other words, each target is run in it's own make process which
# has an environment only containing the variable bindings for that
# target (eg all libobjc_C_FILES, but not libFoundation_C_FILES).

internal-all:: $(LIBRARY_NAME:=.all.library.variables)

internal-install:: $(LIBRARY_NAME:=.install.library.variables)

internal-uninstall:: $(LIBRARY_NAME:=.uninstall.library.variables)

internal-clean:: $(LIBRARY_NAME:=.clean.library.subprojects)
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-distclean:: $(LIBRARY_NAME:=.distclean.library.subprojects)
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

$(LIBRARY_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going \
		$@.all.library.variables

else # This part gets included the second time make is invoked.

.PHONY: internal-library-all \
        internal-library-install \
        internal-library-uninstall \
        before-$(TARGET)-all \
        after-$(TARGET)-all \
        internal-install-lib \
        internal-install-dirs \
        internal-install-headers \
        internal-uninstall-lib \
        internal-uninstall-headers 

# This is the directory where the libs get installed. Normally this
# includes the target arch and os directory and library_combo.
ifeq ($(LIBRARY_INSTALL_DIR),)
  LIBRARY_INSTALL_DIR = $(GNUSTEP_LIBRARIES)
endif

ifeq ($(shared), yes)

ifneq ($(BUILD_DLL),yes)

LIBRARY_FILE = $(INTERNAL_library_NAME)$(LIBRARY_NAME_SUFFIX)$(SHARED_LIBEXT)
LIBRARY_FILE_EXT     = $(SHARED_LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE).$(VERSION)
SOVERSION            = $(word 1,$(subst ., ,$(VERSION)))
SONAME_LIBRARY_FILE  = $(LIBRARY_FILE).$(SOVERSION)

else # BUILD_DLL

LIBRARY_FILE     = $(INTERNAL_library_NAME)$(LIBRARY_NAME_SUFFIX)$(DLL_LIBEXT)
LIBRARY_FILE_EXT = $(DLL_LIBEXT)
DLL_NAME         = $(shell echo $(LIBRARY_FILE)|cut -b 4-)
DLL_EXP_LIB      = $(INTERNAL_library_NAME)$(LIBRARY_NAME_SUFFIX)$(SHARED_LIBEXT)
DLL_EXP_DEF      = $(INTERNAL_library_NAME)$(LIBRARY_NAME_SUFFIX).def

ifeq ($(DLL_INSTALLATION_DIR),)
  DLL_INSTALLATION_DIR = $(GNUSTEP_TOOLS)/$(GNUSTEP_TARGET_LDIR)
endif

endif # BUILD_DLL

else # shared

LIBRARY_FILE         = $(INTERNAL_library_NAME)$(LIBRARY_NAME_SUFFIX)$(LIBEXT)
LIBRARY_FILE_EXT     = $(LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE)
SONAME_LIBRARY_FILE  = $(LIBRARY_FILE)

endif # shared

ifeq ($(strip $(HEADER_FILES_DIR)),)
override HEADER_FILES_DIR = .
endif

#
# Internal targets
#

#
# Compilation targets
#

ifeq ($(BUILD_DLL),yes)

DERIVED_SOURCES = derived_src

ifneq ($(strip $(DLL_DEF)),)
DLL_DEF_FLAG = --input-def $(DLL_DEF)
endif

# Pass -DBUILD_lib{library_name}_DLL=1 to the preprocessor.  The
# library header files can use this preprocessor define to know that
# they are included during compilation of the library itself, and can
# then use __declspec(dllexport) to export symbols
CLEAN_library_NAME = $(shell echo $(INTERNAL_library_NAME)|tr '-' '_')
SHARED_CFLAGS += -DBUILD_$(CLEAN_library_NAME)_DLL=1

internal-library-all:: \
	before-$(TARGET)-all			\
	$(GNUSTEP_OBJ_DIR)			\
	$(DERIVED_SOURCES)			\
	$(DERIVED_SOURCES)/$(INTERNAL_library_NAME).def	\
	$(GNUSTEP_OBJ_DIR)/$(DLL_NAME)		\
	$(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB)	\
	after-$(TARGET)-all

internal-library-clean::
	rm -rf $(DERIVED_SOURCES)

$(DERIVED_SOURCES):
	$(MKDIRS) $@

$(DERIVED_SOURCES)/$(INTERNAL_library_NAME).def: $(OBJ_FILES_TO_LINK) $(DLL_DEF)
	$(DLLTOOL) $(DLL_DEF_FLAG) --output-def $@ $(OBJ_FILES_TO_LINK)

$(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB): $(DERIVED_SOURCES)/$(INTERNAL_library_NAME).def
	$(DLLTOOL) --dllname $(DLL_NAME) --def $< --output-lib $@

$(GNUSTEP_OBJ_DIR)/$(DLL_NAME): $(OBJ_FILES_TO_LINK) \
                               $(DERIVED_SOURCES)/$(INTERNAL_library_NAME).def
	$(DLLWRAP) --driver-name $(CC) \
	  $(SHARED_LD_PREFLAGS) \
	  --def $(DERIVED_SOURCES)/$(INTERNAL_library_NAME).def \
	  -o $@ $(OBJ_FILES_TO_LINK) \
	  $(ALL_LIB_DIRS) \
	  $(LIBRARIES_DEPEND_UPON) $(TARGET_SYSTEM_LIBS) $(SHARED_LD_POSTFLAGS) 

else # BUILD_DLL

internal-library-all:: before-$(TARGET)-all \
                       $(GNUSTEP_OBJ_DIR) \
                       $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) \
                       after-$(TARGET)-all

$(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE): $(OBJ_FILES_TO_LINK)
	$(LIB_LINK_CMD)

endif # BUILD_DLL

before-$(TARGET)-all::

after-$(TARGET)-all::

#
# Install and uninstall targets
#
internal-library-install:: internal-install-dirs \
                           internal-install-lib \
                           internal-install-headers

# Depend on creating all the dirs
internal-install-dirs:: $(LIBRARY_INSTALL_DIR) \
                          $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR) \
                          $(DLL_INSTALLATION_DIR) \
                          $(ADDITIONAL_INSTALL_DIRS)

# Now the rule to create each dir.  NB: Nothing gets executed if the dir 
# already exists
$(LIBRARY_INSTALL_DIR):
	$(MKDIRS) $@

$(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR):
	$(MKDIRS) $@

$(DLL_INSTALLATION_DIR):
	$(MKDIRS) $@

$(ADDITIONAL_INSTALL_DIRS):
	$(MKDIRS) $@


internal-install-headers::
ifneq ($(HEADER_FILES),)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $(HEADER_FILES_DIR)/$$file \
	         $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done;
endif

ifeq ($(BUILD_DLL),yes)

internal-install-lib::
	if [ -f $(GNUSTEP_OBJ_DIR)/$(DLL_NAME) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(DLL_NAME) \
	                     $(DLL_INSTALLATION_DIR) ; \
	fi
	if [ -f $(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB) \
	                     $(LIBRARY_INSTALL_DIR) ; \
	fi

else

internal-install-lib::
	if [ -f $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) \
	                     $(LIBRARY_INSTALL_DIR) ; \
	  $(AFTER_INSTALL_LIBRARY_CMD) \
	fi

endif

internal-library-uninstall:: internal-uninstall-headers \
                             internal-uninstall-lib

internal-uninstall-headers::
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    rm -f $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done

ifeq ($(BUILD_DLL),yes)

internal-uninstall-lib::
	rm -f $(DLL_INSTALLATION_DIR)/$(DLL_NAME) \
	      $(LIBRARY_INSTALL_DIR)/$(DLL_EXP_LIB)

else

internal-uninstall-lib::
	rm -f $(LIBRARY_INSTALL_DIR)/$(VERSION_LIBRARY_FILE) \
	      $(LIBRARY_INSTALL_DIR)/$(LIBRARY_FILE)         \
	      $(LIBRARY_INSTALL_DIR)/$(SONAME_LIBRARY_FILE)
endif

#
# Testing targets
#
internal-library-check::

endif

endif
# library.make loaded

## Local variables:
## mode: makefile
## End:
