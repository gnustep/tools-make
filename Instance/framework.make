#   -*-makefile-*-
#   Instance/framework.make
#
#   Instance Makefile rules to build GNUstep-based frameworks.
#
#   Copyright (C) 2000, 2001, 2002, 2003, 2004 Free Software Foundation, Inc.
#
#   Author: Mirko Viviani <mirko.viviani@rccr.cremona.it>
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

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

# FIXME - missing .PHONY declaration

# The name of the framework is in the FRAMEWORK_NAME variable.
# The list of framework resource files are in xxx_RESOURCE_FILES
# The list of framework web server resource files are in
#    xxx_WEBSERVER_RESOURCE_FILES
# The list of localized framework resource files is in
#    xxx_LOCALIZED_RESOURCE_FILES
# The list of localized framework web server resource files is in
#    xxx_WEBSERVER_LOCALIZED_RESOURCE_FILES
# The list of framework GSWeb components are in xxx_COMPONENTS
# The list of languages the framework supports is in xxx_LANGUAGES
# The list of framework resource directories are in xxx_RESOURCE_DIRS
# The list of framework subprojects directories are in xxx_SUBPROJECTS
# The name of the principal class is xxx_PRINCIPAL_CLASS
# The header files are in xxx_HEADER_FILES
# The directory where the header files are located is xxx_HEADER_FILES_DIR
#   (defaults to ./)
# The directory where to install the header files inside the library
#   installation directory is xxx_HEADER_FILES_INSTALL_DIR
#   (defaults to the framework name [without .framework]).  Can't be `.'
# The list of framework web server resource directories are in
#    xxx_WEBSERVER_RESOURCE_DIRS
# The list of localized framework web server GSWeb components are in
#    xxx_WEBSERVER_LOCALIZED_RESOURCE_DIRS
# xxx_CURRENT_VERSION_NAME is the compiled version name (default "A")
# xxx_DEPLOY_WITH_CURRENT_VERSION deploy with current version or not (default
#       "yes") [Nicola: I'm not sure what this means :-)]
#
# where xxx is the framework name
#
#
# The HEADER_FILES_INSTALL_DIR might look somewhat weird - because in
# most if not all cases, you want it to be the framework name.  At the
# moment, it allows you to put headers for framework XXX in directory
# YYY, so that you can refer to them by using #include
# <YYY/MyHeader.h> rather than #include <XXX/MyHeader.h>.  It seems to
# be mostly used to have a framework with name XXX work as a drop-in
# replacement for another framework, which has name YYY -- and which
# might be installed at the same time :-).
#

# Warn about obsolete syntax
ifneq ($(CURRENT_VERSION_NAME),)
  $(warning CURRENT_VERSION_NAME is deprecated because it doesnt allow multiple frameworks with different versions to be built from warning the same GNUmakefile!  Please replace it with XXX_CURRENT_VERSION_NAME)
endif

# Warning - the following variable is also used in Master/rules.make
# to build the OWNING_PROJECT_HEADER_DIR for the framework's
# subprojects.  Make sure you keep them in sync if you change them.
CURRENT_VERSION_NAME = $($(GNUSTEP_INSTANCE)_CURRENT_VERSION_NAME)
ifeq ($(CURRENT_VERSION_NAME),)
  CURRENT_VERSION_NAME = A
endif

ifneq ($(DEPLOY_WITH_CURRENT_VERSION),)
  $(warning DEPLOY_WITH_CURRENT_VERSION is deprecated because it doesnt allow multiple frameworks with different DEPLOY_WITH_CURRENT_VERSION to be built from the same GNUmakefile!  Please replace it with XXX_DEPLOY_WITH_CURRENT_VERSION)
endif

DEPLOY_WITH_CURRENT_VERSION = $($(GNUSTEP_INSTANCE)_DEPLOY_WITH_CURRENT_VERSION)
ifeq ($(DEPLOY_WITH_CURRENT_VERSION),)
  DEPLOY_WITH_CURRENT_VERSION = yes
endif

# This is used on Apple to build frameworks which can be embedded into
# applications.  You usually set it to something like
# @executable_path/../Frameworks and then you can embed the framework
# in an application.
DYLIB_INSTALL_NAME_BASE = $($(GNUSTEP_INSTANCE)_DYLIB_INSTALL_NAME_BASE)

FRAMEWORK_DIR_NAME = $(GNUSTEP_INSTANCE).framework
FRAMEWORK_DIR = $(GNUSTEP_BUILD_DIR)/$(FRAMEWORK_DIR_NAME)
FRAMEWORK_VERSION_DIR_NAME = $(FRAMEWORK_DIR_NAME)/Versions/$(CURRENT_VERSION_NAME)
FRAMEWORK_VERSION_DIR = $(GNUSTEP_BUILD_DIR)/$(FRAMEWORK_VERSION_DIR_NAME)

# This is not doing much at the moment, but at least is defining
# HEADER_FILES, HEADER_FILES_DIR and HEADER_FILES_INSTALL_DIR in the
# standard way.  NB: If HEADER_FILES is empty, HEADER_FILES_DIR and
# HEADER_FILES_INSTALL_DIR are going to be undefined!
include $(GNUSTEP_MAKEFILES)/Instance/Shared/headers.make

# FIXME - do we really want to link the framework against all libs ?
# That easily makes problems when the framework is loaded as a bundle,
# doesn't it ?
ALL_FRAMEWORK_LIBS =						\
    $(shell $(WHICH_LIB_SCRIPT)					\
	    $(ALL_LIB_DIRS)					\
	$(FRAMEWORK_LIBS)					\
	debug=$(debug) profile=$(profile) shared=$(shared)	\
	libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

INTERNAL_LIBRARIES_DEPEND_UPON =				\
  $(shell $(WHICH_LIB_SCRIPT)					\
   $(ALL_LIB_DIRS)						\
   $(LIBRARIES_DEPEND_UPON)					\
   debug=$(debug) profile=$(profile) shared=$(shared)		\
   libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

ifeq ($(FOUNDATION_LIB),gnu)
  # On GNUstep, build our dummy class to store information which
  # gnustep-base can find at run time
  DUMMY_FRAMEWORK = NSFramework_$(GNUSTEP_INSTANCE)
  DUMMY_FRAMEWORK_FILE = $(DERIVED_SOURCES_DIR)/$(DUMMY_FRAMEWORK).m
  DUMMY_FRAMEWORK_OBJ_FILE = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(DUMMY_FRAMEWORK).o)

  # The following file will hold the list of classes compiled into the
  # framework, ready to be included in the .plist file.  We include the
  # list of classes twice, in the object file itself (for when the
  # framework is loaded) and in the .plist (for tools which let you
  # browse in frameworks on disk and see lists of classes).  Please note
  # that reading the class list from the .plist requires gnustep-base to
  # have properly located the framework bundle on disk, while reading
  # the list from the object file itself does not (and so it's more
  # likely to work in a portable way), which is why we still save the
  # list in the object file rather than only putting it in the .plist.
  # Maybe this point should be discarded, and we should only store the class
  # list in the .plist file.
  DUMMY_FRAMEWORK_CLASS_LIST = $(DERIVED_SOURCES_DIR)/$(GNUSTEP_INSTANCE)-class-list
endif

FRAMEWORK_HEADER_FILES := $(addprefix $(FRAMEWORK_VERSION_DIR)/Headers/,$(HEADER_FILES))

ifneq ($(BUILD_DLL),yes)

FRAMEWORK_CURRENT_DIR_NAME := $(FRAMEWORK_DIR_NAME)/Versions/Current
FRAMEWORK_CURRENT_DIR := $(GNUSTEP_BUILD_DIR)/$(FRAMEWORK_CURRENT_DIR_NAME)
FRAMEWORK_LIBRARY_DIR_NAME := $(FRAMEWORK_VERSION_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)
FRAMEWORK_LIBRARY_DIR := $(GNUSTEP_BUILD_DIR)/$(FRAMEWORK_LIBRARY_DIR_NAME)
FRAMEWORK_CURRENT_LIBRARY_DIR_NAME := $(FRAMEWORK_CURRENT_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)
FRAMEWORK_CURRENT_LIBRARY_DIR := $(GNUSTEP_BUILD_DIR)/$(FRAMEWORK_CURRENT_LIBRARY_DIR_NAME)

FRAMEWORK_LIBRARY_FILE = lib$(GNUSTEP_INSTANCE)$(SHARED_LIBEXT)
VERSION_FRAMEWORK_LIBRARY_FILE = $(FRAMEWORK_LIBRARY_FILE).$(VERSION)
SOVERSION             = $(word 1,$(subst ., ,$(VERSION)))
SONAME_FRAMEWORK_FILE = $(FRAMEWORK_LIBRARY_FILE).$(SOVERSION)

FRAMEWORK_FILE_NAME := $(FRAMEWORK_LIBRARY_DIR_NAME)/$(VERSION_FRAMEWORK_LIBRARY_FILE)
FRAMEWORK_FILE := $(GNUSTEP_BUILD_DIR)/$(FRAMEWORK_FILE_NAME)

else # BUILD_DLL

FRAMEWORK_FILE_NAME = $(GNUSTEP_INSTANCE)$(FRAMEWORK_NAME_SUFFIX)$(DLL_LIBEXT)
FRAMEWORK_FILE      = $(GNUSTEP_BUILD_DIR)/$(FRAMEWORK_FILE_NAME)
DLL_NAME         = $(shell echo $(LIBRARY_FILE)|cut -b 4-)
DLL_EXP_LIB      = $(GNUSTEP_INSTANCE)$(FRAMEWORK_NAME_SUFFIX)$(SHARED_LIBEXT)
DLL_EXP_DEF      = $(GNUSTEP_INSTANCE)$(FRAMEWORK_NAME_SUFFIX).def

ifeq ($(DLL_INSTALLATION_DIR),)
  DLL_INSTALLATION_DIR = $(GNUSTEP_TOOLS)/$(GNUSTEP_TARGET_LDIR)
endif

endif # BUILD_DLL

ifeq ($(WITH_DLL),yes)
  FRAMEWORK_OBJ_EXT = $(DLL_LIBEXT)
endif # WITH_DLL

ifneq ($($(GNUSTEP_INSTANCE)_INSTALL_DIR),)
  FRAMEWORK_INSTALL_DIR = $($(GNUSTEP_INSTANCE)_INSTALL_DIR)
endif

ifeq ($(FRAMEWORK_INSTALL_DIR),)
  FRAMEWORK_INSTALL_DIR = $(GNUSTEP_FRAMEWORKS)
endif

#
# Emit a warning for old deprecated functionality
#
ifneq ($($(GNUSTEP_INSTANCE)_TOOLS),)
  $(warning "Support for xxx_TOOLS has been removed from gnustep-make! Please rewrite your makefile code by compiling the tools separately, then add a xxx_COPY_INTO_DIR command for each of them to copy them into the framework.  Ask for help on gnustep mailing lists if you're confused.")
endif

#
# Now prepare the variables which are used by target-dependent commands
# defined in target.make
#
LIB_LINK_OBJ_DIR = $(FRAMEWORK_LIBRARY_DIR)
LIB_LINK_VERSION_FILE = $(VERSION_FRAMEWORK_LIBRARY_FILE)
LIB_LINK_SONAME_FILE = $(SONAME_FRAMEWORK_FILE)
LIB_LINK_FILE = $(FRAMEWORK_LIBRARY_FILE)
LIB_LINK_INSTALL_DIR = $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_LIBRARY_DIR_NAME)

ifneq ($(DYLIB_INSTALL_NAME_BASE),)
  LIB_LINK_INSTALL_NAME = $(DYLIB_INSTALL_NAME_BASE)/$(FRAMEWORK_FILE_NAME)
else
  # Use a relative path for easy relocation.
  LIB_LINK_INSTALL_NAME = $(GNUSTEP_INSTANCE).framework/$(GNUSTEP_INSTANCE)
endif


GNUSTEP_SHARED_BUNDLE_RESOURCE_PATH = $(FRAMEWORK_VERSION_DIR)/Resources
include $(GNUSTEP_MAKEFILES)/Instance/Shared/bundle.make

internal-framework-all_:: $(GNUSTEP_OBJ_DIR) \
                          build-framework

internal-framework-build-headers:: build-framework-dirs \
                                   $(FRAMEWORK_HEADER_FILES)

# Please note that test -h must be used instead of test -L because on old
# Sun Solaris, test -h works but test -L does not.
build-framework-dirs:: $(DERIVED_SOURCES_DIR) \
                       $(FRAMEWORK_LIBRARY_DIR) \
                       $(FRAMEWORK_VERSION_DIR)/Headers \
                       $(FRAMEWORK_VERSION_DIR)/Resources \
                       $(FRAMEWORK_RESOURCE_DIRS)
ifeq ($(DEPLOY_WITH_CURRENT_VERSION),yes)
	$(ECHO_NOTHING)rm -f $(FRAMEWORK_DIR)/Versions/Current$(END_ECHO)
endif
	$(ECHO_NOTHING)cd $(FRAMEWORK_DIR)/Versions; \
	  if [ ! -h "Current" ]; then \
	    rm -f Current; \
	    $(LN_S) $(CURRENT_VERSION_NAME) Current; \
	  fi; \
	  cd ../; \
	  if [ ! -h "Resources" ]; then \
	    rm -f Resources; \
	    $(LN_S) Versions/Current/Resources Resources; \
	  fi; \
	  if [ ! -h "Headers" ]; then \
	    rm -f Headers; \
	    $(LN_S) Versions/Current/Headers Headers; \
	  fi$(END_ECHO)
ifneq ($(HEADER_FILES),)
	$(ECHO_NOTHING)cd $(DERIVED_SOURCES_DIR); \
	  if [ ! -h "$(HEADER_FILES_INSTALL_DIR)" ]; then \
	    rm -f ./$(HEADER_FILES_INSTALL_DIR); \
	    $(LN_S) ../$(FRAMEWORK_DIR_NAME)/Headers \
                    ./$(HEADER_FILES_INSTALL_DIR); \
	  fi$(END_ECHO)
endif

$(FRAMEWORK_LIBRARY_DIR):
	$(ECHO_CREATING)$(MKDIRS) $@$(END_ECHO)

$(FRAMEWORK_VERSION_DIR)/Headers:
	$(ECHO_CREATING)$(MKDIRS) $@$(END_ECHO)

$(DERIVED_SOURCES_DIR):
	$(ECHO_CREATING)$(MKDIRS) $@$(END_ECHO)

# Need to share this code with the headers code ... but how.
$(FRAMEWORK_HEADER_FILES):: $(HEADER_FILES)
ifneq ($(HEADER_FILES),)
	$(ECHO_NOTHING)for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $(HEADER_FILES_DIR)/$$file \
	                    $(FRAMEWORK_VERSION_DIR)/Headers/$$file ; \
	  fi; \
	done$(END_ECHO)
endif

OBJC_OBJ_FILES_TO_INSPECT = $(OBJC_OBJ_FILES) $(SUBPROJECT_OBJ_FILES)

# FIXME - We should not depend on GNUmakefile - rather we should use
# Instance/Shared/stamp-string.make if we need to depend on the value
# of some make variables.  That would also detect a change in
# FRAMEWORK_INSTALL_DIR from the command line, not currently covered
# at the moment!
#
# To get the list of all classes, we run 'nm' on the object files, and
# retrieve all symbols of the form __objc_class_name_NSObject which
# are not 'U' (undefined) ... an __objc_class_name_NSObject is defined
# in the module implementing the class, and referenced by all other
# modules needing to use the class.  So if we have an
# __objc_class_name_XXX which is not 'U' (which would be a reference
# to a class implemented elsewhere), it must be a class implemented in
# this module.
#
# The 'sed' command parses a set of lines, and extracts lines starting
# with __objc_class_name_XXXX Y, where XXXX is a string of characters
# from A-Za-z_. and Y is not 'U'.  It then replaces the whole line
# with XXXX, and prints the result. '-n' disables automatic printing
# for portability, so we are sure we only print what we want on all
# platforms.
#
# The following rule will also build the DUMMY_FRAMEWORK_CLASS_LIST
# file.  This file is always created/deleted at the same time as the
# DUMMY_FRAMEWORK_FILE.
$(DUMMY_FRAMEWORK_FILE): $(DERIVED_SOURCES_DIR) $(OBJ_FILES_TO_LINK) GNUmakefile
	$(ECHO_CREATING) classes=""; \
	for f in $(OBJC_OBJ_FILES_TO_INSPECT) __dummy__; do \
	  if [ "$$f" != "__dummy__" ]; then \
	    sym=`nm -Pg $$f | sed -n -e '/^__objc_class_name_[A-Za-z_.]* [^U]/ {s/^__objc_class_name_\([A-Za-z_.]*\) [^U].*/\1/p;}'`; \
	    classes="$$classes $$sym"; \
	  fi; \
	done; \
	classlist=""; \
	classarray=""; \
	for f in $$classes __dummy__ ; do \
	  if [ "$$f" != "__dummy__" ]; then \
	    if [ "$$classlist" = "" ]; then \
	      classlist="@\"$$f\""; \
	      classarray="(\"$$f\""; \
	    else \
	      classlist="$$classlist, @\"$$f\""; \
	      classarray="$$classarray, \"$$f\""; \
	    fi; \
	  fi; \
	done; \
	if [ "$$classlist" = "" ]; then \
	  classlist="NULL"; \
	  classarray="()"; \
	else \
	  classlist="$$classlist, NULL"; \
	  classarray="$$classarray)"; \
	fi; \
	echo "$$classarray" > $(DUMMY_FRAMEWORK_CLASS_LIST); \
	if [ "`echo $(FRAMEWORK_INSTALL_DIR) | sed 's/^$(subst /,\/,$(GNUSTEP_USER_ROOT))//'`" != "$(FRAMEWORK_INSTALL_DIR)" ]; then \
	  fw_env="@\"GNUSTEP_USER_ROOT\""; \
	elif [ "`echo $(FRAMEWORK_INSTALL_DIR) | sed 's/^$(subst /,\/,$(GNUSTEP_LOCAL_ROOT))//'`" != "$(FRAMEWORK_INSTALL_DIR)" ]; then \
	  fw_env="@\"GNUSTEP_LOCAL_ROOT\""; \
	elif [ "`echo $(FRAMEWORK_INSTALL_DIR) | sed 's/^$(subst /,\/,$(GNUSTEP_SYSTEM_ROOT))//'`" != "$(FRAMEWORK_INSTALL_DIR)" ]; then \
	  fw_env="@\"GNUSTEP_SYSTEM_ROOT\""; \
	else \
	  fw_env="nil"; \
	fi; \
	fw_path=`echo $(FRAMEWORK_INSTALL_DIR) | sed 's/^$(subst /,\/,$(GNUSTEP_FRAMEWORKS))//'`; \
	if [ "$$fw_path" = "$(FRAMEWORK_INSTALL_DIR)" ]; then \
	  fw_path="nil"; \
	elif [ "$$fw_path" = "" ]; then \
	  fw_path="nil"; \
	else \
	  fw_path="@\"$$fw_path\""; \
	fi; \
	echo "#include <Foundation/NSString.h>" > $@; \
	echo "@interface $(DUMMY_FRAMEWORK)" >> $@; \
	echo "+ (NSString *)frameworkEnv;" >> $@; \
	echo "+ (NSString *)frameworkPath;" >> $@; \
	echo "+ (NSString *)frameworkVersion;" >> $@; \
	echo "+ (NSString **)frameworkClasses;" >> $@; \
	echo "@end" >> $@; \
	echo "@implementation $(DUMMY_FRAMEWORK)" >> $@; \
	echo "+ (NSString *)frameworkEnv { return $$fw_env; }" >> $@; \
	echo "+ (NSString *)frameworkPath { return $$fw_path; }" >> $@; \
	echo "+ (NSString *)frameworkVersion { return @\"$(CURRENT_VERSION_NAME)\"; }" >> $@; \
	echo "static NSString *allClasses[] = {$$classlist};" >> $@; \
	echo "+ (NSString **)frameworkClasses { return allClasses; }" >> $@;\
	echo "@end" >> $@$(END_ECHO)

ifeq ($(FOUNDATION_LIB),gnu)
$(DUMMY_FRAMEWORK_OBJ_FILE): $(DUMMY_FRAMEWORK_FILE)
	$(ECHO_COMPILING)$(CC) $< -c $(ALL_CPPFLAGS) $(ALL_OBJCFLAGS) -o $@$(END_ECHO)
endif

ifeq ($(FOUNDATION_LIB), apple)
# When building native frameworks on Apple, we need to create a
# top-level symlink xxx.framework/xxx ---> the framework shared
# library

build-framework:: $(FRAMEWORK_FILE) \
                  shared-instance-bundle-all \
                  $(FRAMEWORK_VERSION_DIR)/Resources/Info.plist \
                  $(GNUSTEP_BUILD_DIR)/$(GNUSTEP_INSTANCE).framework/$(GNUSTEP_INSTANCE)

$(GNUSTEP_BUILD_DIR)/$(GNUSTEP_INSTANCE).framework/$(GNUSTEP_INSTANCE):
	$(ECHO_NOTHING)cd $(GNUSTEP_BUILD_DIR)/$(GNUSTEP_INSTANCE).framework; \
	rm -f $(GNUSTEP_INSTANCE); \
	$(LN_S) Versions/Current/$(GNUSTEP_TARGET_LDIR)/$(GNUSTEP_INSTANCE) $(GNUSTEP_INSTANCE)$(END_ECHO)
else

build-framework:: $(FRAMEWORK_FILE) \
                  shared-instance-bundle-all \
                  $(FRAMEWORK_VERSION_DIR)/Resources/Info-gnustep.plist

endif





ifeq ($(WITH_DLL),yes)

$(FRAMEWORK_FILE) : $(DUMMY_FRAMEWORK_OBJ_FILE) $(OBJ_FILES_TO_LINK)
	$(ECHO_LINKING)$(DLLWRAP) --driver-name $(CC) \
		-o $(LDOUT)$(FRAMEWORK_FILE) \
		$(OBJ_FILES_TO_LINK) \
		$(ALL_FRAMEWORK_LIBS)$(END_ECHO)

else # without DLL

$(FRAMEWORK_FILE) : $(DUMMY_FRAMEWORK_OBJ_FILE) $(OBJ_FILES_TO_LINK)
	$(ECHO_LINKING) \
	$(LIB_LINK_CMD); \
	(cd $(LIB_LINK_OBJ_DIR); \
	  rm -f $(GNUSTEP_INSTANCE); \
	  $(LN_S) $(LIB_LINK_FILE) $(GNUSTEP_INSTANCE)) \
	$(END_ECHO)

endif # WITH_DLL

PRINCIPAL_CLASS = $(strip $($(GNUSTEP_INSTANCE)_PRINCIPAL_CLASS))

ifeq ($(PRINCIPAL_CLASS),)
  PRINCIPAL_CLASS = $(GNUSTEP_INSTANCE)
endif

MAIN_MODEL_FILE = $(strip $(subst .gmodel,,$(subst .gorm,,$(subst .nib,,$($(GNUSTEP_INSTANCE)_MAIN_MODEL_FILE)))))

# MacOSX-S frameworks
$(FRAMEWORK_VERSION_DIR)/Resources/Info.plist: $(FRAMEWORK_VERSION_DIR)/Resources
	$(ECHO_CREATING)(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_INSTANCE)${FRAMEWORK_OBJ_EXT}\";"; \
	  echo "  NSMainNibFile = \"$(MAIN_MODEL_FILE)\";"; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "}") >$@$(END_ECHO)

# GNUstep frameworks
$(FRAMEWORK_VERSION_DIR)/Resources/Info-gnustep.plist: $(FRAMEWORK_VERSION_DIR)/Resources $(DUMMY_FRAMEWORK_FILE)
	$(ECHO_CREATING)(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_INSTANCE)${FRAMEWORK_OBJ_EXT}\";"; \
	  echo "  NSMainNibFile = \"$(MAIN_MODEL_FILE)\";"; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "  Classes = "; \
	  cat $(DUMMY_FRAMEWORK_CLASS_LIST); \
	  echo "  ;"; \
	  echo "}") >$@$(END_ECHO)
	$(ECHO_NOTHING)if [ -r "$(GNUSTEP_INSTANCE)Info.plist" ]; then \
	   plmerge $@ $(GNUSTEP_INSTANCE)Info.plist; \
	 fi$(END_ECHO)

ifneq ($(WITH_DLL),yes)

ifeq ($(FOUNDATION_LIB),gnu)

internal-framework-install_:: $(FRAMEWORK_INSTALL_DIR) \
                      $(GNUSTEP_LIBRARIES)/$(GNUSTEP_TARGET_LDIR) \
                      $(GNUSTEP_HEADERS)
	$(ECHO_INSTALLING)rm -rf $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME); \
	(cd $(GNUSTEP_BUILD_DIR); $(TAR) cf - $(FRAMEWORK_DIR_NAME)) | (cd $(FRAMEWORK_INSTALL_DIR); $(TAR) xf -)$(END_ECHO)
ifneq ($(CHOWN_TO),)
	$(ECHO_CHOWNING)$(CHOWN) -R $(CHOWN_TO) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME)$(END_ECHO)
endif
ifeq ($(strip),yes)
	$(ECHO_STRIPPING)$(STRIP) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_FILE_NAME)$(END_ECHO)
endif
	$(ECHO_INSTALLING_HEADERS)cd $(GNUSTEP_HEADERS); \
	if [ "$(HEADER_FILES)" != "" ]; then \
	  rm -f $(HEADER_FILES_INSTALL_DIR); \
	  $(LN_S) `$(REL_PATH_SCRIPT) $(GNUSTEP_HEADERS) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME)/Headers` $(HEADER_FILES_INSTALL_DIR); \
	fi;$(END_ECHO)
ifneq ($(CHOWN_TO),)
	$(ECHO_CHOWNING)cd $(GNUSTEP_HEADERS); \
	if [ "$(HEADER_FILES)" != "" ]; then \
	  $(CHOWN) $(CHOWN_TO) $(HEADER_FILES_INSTALL_DIR); \
	fi$(END_ECHO)
endif
	$(ECHO_NOTHING)cd $(GNUSTEP_LIBRARIES)/$(GNUSTEP_TARGET_LDIR); \
	rm -f $(FRAMEWORK_LIBRARY_FILE); \
	rm -f $(SONAME_FRAMEWORK_FILE); \
	rm -f $(VERSION_FRAMEWORK_LIBRARY_FILE); \
	$(LN_S) `$(REL_PATH_SCRIPT) $(GNUSTEP_LIBRARIES)/$(GNUSTEP_TARGET_LDIR) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_CURRENT_LIBRARY_DIR_NAME)/$(FRAMEWORK_LIBRARY_FILE)` $(FRAMEWORK_LIBRARY_FILE); \
	if test -r "$(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_CURRENT_LIBRARY_DIR_NAME)/$(SONAME_FRAMEWORK_FILE)"; then \
	  $(LN_S) `$(REL_PATH_SCRIPT) $(GNUSTEP_LIBRARIES)/$(GNUSTEP_TARGET_LDIR) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_CURRENT_LIBRARY_DIR_NAME)/$(SONAME_FRAMEWORK_FILE)` $(SONAME_FRAMEWORK_FILE); \
	fi; \
	$(LN_S) `$(REL_PATH_SCRIPT) $(GNUSTEP_LIBRARIES)/$(GNUSTEP_TARGET_LDIR) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_CURRENT_LIBRARY_DIR_NAME)/$(VERSION_FRAMEWORK_LIBRARY_FILE)` $(VERSION_FRAMEWORK_LIBRARY_FILE)$(END_ECHO)
ifneq ($(CHOWN_TO),)
	$(ECHO_CHOWNING)cd $(GNUSTEP_LIBRARIES)/$(GNUSTEP_TARGET_LDIR); \
	$(CHOWN) $(CHOWN_TO) $(FRAMEWORK_LIBRARY_FILE); \
	if test -r "$(SONAME_FRAMEWORK_FILE)"; then \
	  $(CHOWN) $(CHOWN_TO) $(SONAME_FRAMEWORK_FILE); \
	fi; \
	$(CHOWN) $(CHOWN_TO) $(VERSION_FRAMEWORK_LIBRARY_FILE)$(END_ECHO)
endif

else

# This code for Apple OSX

internal-framework-install_:: $(FRAMEWORK_INSTALL_DIR)
	$(ECHO_INSTALLING)rm -rf $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME); \
	(cd $(GNUSTEP_BUILD_DIR); $(TAR) cf - $(FRAMEWORK_DIR_NAME)) | (cd $(FRAMEWORK_INSTALL_DIR); $(TAR) xf -)$(END_ECHO)
ifneq ($(CHOWN_TO),)
	$(ECHO_CHOWNING)$(CHOWN) -R $(CHOWN_TO) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME)$(END_ECHO)
endif
ifeq ($(strip),yes)
	$(ECHO_STRIPPING)$(STRIP) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_FILE_NAME)$(END_ECHO)
endif

endif

else # install DLL

internal-framework-install_:: $(FRAMEWORK_INSTALL_DIR) \
                      $(GNUSTEP_LIBRARIES)/$(GNUSTEP_TARGET_LDIR) \
                      $(GNUSTEP_HEADERS) \
                      $(DLL_INSTALLATION_DIR)
	$(ECHO_INSTALLING)rm -rf $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME); \
	(cd $(GNUSTEP_BUILD_DIR); $(TAR) cf - $(FRAMEWORK_DIR_NAME)) | (cd $(FRAMEWORK_INSTALL_DIR); $(TAR) xf -)$(END_ECHO)
ifneq ($(CHOWN_TO),)
	$(ECHO_CHOWNING)$(CHOWN) -R $(CHOWN_TO) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME)$(END_ECHO)
endif
ifeq ($(strip),yes)
	$(ECHO_STRIPPING)$(STRIP) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_FILE_NAME)$(END_ECHO)
endif
	$(ECHO_INSTALLING_HEADERS)cd $(GNUSTEP_HEADERS); \
	if [ "$(HEADER_FILES)" != "" ]; then \
	  if test -d "$(HEADER_FILES_INSTALL_DIR)"; then \
	    rm -Rf $(HEADER_FILES_INSTALL_DIR); \
	  fi; \
          $(MKINSTALLDIRS) $(HEADER_FILES_INSTALL_DIR); \
	  cd $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_VERSION_DIR_NAME)/Headers ; \
            $(TAR) cf - . | (cd  $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR); \
            $(TAR) xf - ); \
	fi;$(END_ECHO)
ifneq ($(CHOWN_TO),)
	$(ECHO_CHOWNING)cd $(GNUSTEP_HEADERS); \
	if [ "$(HEADER_FILES)" != "" ]; then \
	  $(CHOWN) -R $(CHOWN_TO) $(HEADER_FILES_INSTALL_DIR); \
	fi$(END_ECHO)
endif
	$(ECHO_NOTHING)cd $(DLL_INSTALLATION_DIR); \
	if test -r "$(FRAMEWORK_FILE_NAME)"; then \
	  rm -f $(FRAMEWORK_FILE_NAME); \
	fi$(END_ECHO)
	$(ECHO_NOTHING)$(INSTALL_PROGRAM) -m 0755 $(FRAMEWORK_FILE) \
          $(DLL_INSTALLATION_DIR)/$(FRAMEWORK_FILE_NAME)$(END_ECHO)

endif

$(DLL_INSTALLATION_DIR)::
	$(ECHO_CREATING)$(MKINSTALLDIRS) $@$(END_ECHO)

$(FRAMEWORK_DIR)/Resources::
	$(ECHO_CREATING)$(MKDIRS) $@$(END_ECHO)

$(FRAMEWORK_INSTALL_DIR)::
	$(ECHO_CREATING)$(MKINSTALLDIRS) $@$(END_ECHO)

$(GNUSTEP_LIBRARIES)/$(GNUSTEP_TARGET_LDIR) :
	$(ECHO_CREATING)$(MKINSTALLDIRS) $@$(END_ECHO)

$(GNUSTEP_HEADERS) :
	$(ECHO_CREATING)$(MKINSTALLDIRS) $@$(END_ECHO)

# NB: We use 'rm -f' to remove the symlinks to insure
#     that we do not remove customized real directories.  
internal-framework-uninstall_::
	$(ECHO_UNINSTALLING)if [ "$(HEADER_FILES)" != "" ]; then \
	  for file in $(HEADER_FILES) __done; do \
	    if [ $$file != __done ]; then \
	      rm -rf $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	    fi; \
	  done; \
	fi; \
	if [ -n "$(HEADER_FILES)" ]; then \
	  rm -f $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR) ; \
	fi; \
	rm -rf $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME) ; \
	cd $(GNUSTEP_LIBRARIES)/$(GNUSTEP_TARGET_LDIR); \
	rm -f $(FRAMEWORK_LIBRARY_FILE); \
	rm -f $(SONAME_FRAMEWORK_FILE); \
	rm -f $(VERSION_FRAMEWORK_LIBRARY_FILE); \
	$(END_ECHO)

#
# Cleaning targets
#
internal-framework-clean::
	$(ECHO_NOTHING)rm -rf $(GNUSTEP_OBJ_DIR) \
	       $(PSWRAP_C_FILES) $(PSWRAP_H_FILES) \
	       $(FRAMEWORK_DIR) $(DERIVED_SOURCES_DIR)$(END_ECHO)

internal-framework-distclean::
	$(ECHO_NOTHING)cd $(GNUSTEP_BUILD_DIR); \
	  rm -rf shared_obj static_obj shared_debug_obj \
	  shared_profile_obj static_debug_obj static_profile_obj \
	  shared_profile_debug_obj static_profile_debug_obj$(END_ECHO)

include $(GNUSTEP_MAKEFILES)/Instance/Shared/strings.make
