#
#   test.make
#
#   Makefile rules for dejagnu/GNUstep based testing
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
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
# Include in the common makefile rules
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/rules.make

#
# The three main components to perform a test in the framework
# a) code to be tested
# b) scripts which say what/how to test
# c) test driver
#
# Component A can be any (or all) of the possible build targets
# supported by the GNUstep Makefile Package:  library, tool,
# application, or bundle.  The code is assumed to be compiled
# elsewhere and just needs to be accessed to run the tests.
#
# Component B are written by the user.  The GNUstep Makefile Package
# does not interpret these scripts; it require that you specify
# a list of directories which contain the scripts for the code to be
# tested, so that this information can be passed to dejagnu.
#
# Component C is dependent upon the type of code to be tested; generally
# an interactive program is its own test driver as it can communicate
# directly with dejagnu.  Libraries, however, require a test driver which
# interactively accepts commands from dejagnu; the Objective-C Testing
# Framework is the default test driver.
#
# Test drivers for the various build targets; the names should be unique
# across all of the test drivers:
#
# TEST_LIBRARY_NAME
# TEST_TOOL_NAME
# TEST_APP_NAME
# TEST_BUNDLE_NAME
#
# xxx_OBJC_FILES, xxx_C_FILES, and xxx_PSWRAP_FILES holds the files
# to be compiled for the xxx test driver.
#
# xxx_SCRIPT_DIRS is a list of directories containing the test scripts
# which will be performed by dejagnu for the xxx test driver.
#
# xxx_SCRIPTS_DIRECTORY is the directory where the xxx_SCRIPT_DIRS
# are located for the xxx test driver.
#
# xxx_INCLUDE_DIRS are additional headers directories to be searched
#
# xxx_LIB_DIRS and xxx_LIBS are additional libraries directories and
# libraries to link against, respectively to link the xxx test driver.
# The same paths are passed to the dynamic linker.
#

TEST_LIBRARY_LIST := $(TEST_LIBRARY_NAME:=.testlib)
CHECK_LIBRARY_LIST := $(TEST_LIBRARY_NAME:=.checklib)

TEST_BUNDLE_LIST := $(TEST_BUNDLE_NAME:=.testbundle)
CHECK_BUNDLE_LIST := $(TEST_BUNDLE_NAME:=.checkbundle)
TEST_BUNDLE_DIR_NAME := $(TEST_BUNDLE_NAME:=$(BUNDLE_EXTENSION))
TEST_BUNDLE_FILE := $(TEST_BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)/$(TEST_BUNDLE_NAME)
TEST_BUNDLE_RESOURCE_DIRS = $(foreach d,$(RESOURCE_DIRS),$(TEST_BUNDLE_DIR_NAME)/$(d))

TEST_TOOL_LIST := $(TEST_TOOL_NAME:=.testtool)
CHECK_TOOL_LIST := $(TEST_TOOL_NAME:=.checktool)

TEST_APP_LIST := $(TEST_APP_NAME:=.testapp)
CHECK_APP_LIST := $(TEST_APP_NAME:=.checkapp)

ifeq ($(SCRIPTS_DIRECTORY),)
SCRIPTS_DIRECTORY = .
endif

# Determine the application directory extension
ifeq ($(profile), yes)
  APP_EXTENSION = profile
else
  ifeq ($(debug), yes)
    APP_EXTENSION=debug
  else
    APP_EXTENSION=app
  endif
endif

#
# Internal targets
#

ifneq ($(TEST_LIBRARY_NAME),)
$(GNUSTEP_OBJ_DIR)/$(TEST_LIBRARY_NAME) : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(GNUSTEP_OBJ_DIR)/$(TEST_LIBRARY_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_LIBRARY_LIBS)
endif

ifneq ($(TEST_BUNDLE_NAME),)
$(TEST_BUNDLE_NAME): $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(BUNDLE_LD) $(BUNDLE_LDFLAGS) $(ALL_LDFLAGS) \
		$(LDOUT)$(TEST_BUNDLE_FILE) $(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_BUNDLE_LIBS)
endif

ifneq ($(TEST_TOOL_NAME),)
$(TEST_TOOL_NAME) : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(TEST_TOOL_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_TOOL_LIBS)
endif

ifneq ($(INTERNAL_TEST_APP_NAME),)

APP_DIR_NAME = $(INTERNAL_TEST_APP_NAME:=.$(APP_EXTENSION))

# Support building NeXT applications
ifneq ($(OBJC_COMPILER), NeXT)
TEST_APP_FILE = \
    $(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)/$(INTERNAL_TEST_APP_NAME)$(EXEEXT)
else
TEST_APP_FILE = $(APP_DIR_NAME)/$(INTERNAL_TEST_APP_NAME)$(EXEEXT)
endif

$(TEST_APP_FILE) : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(TEST_APP_FILE) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_APP_LIBS)
	@$(TRANSFORM_PATHS_SCRIPT) `echo $(ALL_LIB_DIRS) | sed 's/-L//g'` \
		>$(APP_DIR_NAME)/library_paths.openapp
ifeq ($(OBJC_COMPILER), NeXT)
# This is a hack for OPENSTEP systems to remove the iconheader file
# automatically generated by the makefile package.
	rm -f $(INTERNAL_APP_NAME).iconheader
endif

else
$(TEST_APP_NAME):
	@$(MAKE) --no-print-directory $@.testapp
endif

#
# Compilation targets
#
internal-all:: $(GNUSTEP_OBJ_DIR) internal-test-build

$(SCRIPTS_DIRECTORY)/config/unix.exp::
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs $(SCRIPTS_DIRECTORY)/config
	@(echo "Creating the $@ file..."; \
	echo "## Do Not Edit ##" > $@; \
	(echo "# Contents generated automatically by Makefile"; \
	echo "#"; \
	echo ""; \
	echo "set OBJC_RUNTIME $(OBJC_RUNTIME)"; \
	echo "set FOUNDATION_LIBRARY $(FOUNDATION_LIB)"; \
	echo ""; \
	echo "if {[file isdirectory $(GNUSTEP_USER_LIBRARIES_ROOT)/ObjCTest]} {"; \
	echo "  set OBJCTEST_DIR $(GNUSTEP_USER_LIBRARIES_ROOT)/ObjCTest"; \
	echo "} elseif {[file isdirectory $(GNUSTEP_LOCAL_LIBRARIES_ROOT)/ObjCTest]} {"; \
	echo "  set OBJCTEST_DIR $(GNUSTEP_LOCAL_LIBRARIES_ROOT)/ObjCTest"; \
	echo "} elseif {[file isdirectory $(GNUSTEP_SYSTEM_LIBRARIES_ROOT)/ObjCTest]} {"; \
	echo "  set OBJCTEST_DIR $(GNUSTEP_SYSTEM_LIBRARIES_ROOT)/ObjCTest"; \
	echo "}"; \
	echo "set objdir `pwd`"; \
	echo "source \"\$$OBJCTEST_DIR/common.exp\""; \
	echo ""; \
	echo "# Maintain your own code in local.exp"; \
	echo "source \"config/local.exp\"") >>$@)

internal-test-build:: test-libs test-bundles test-tools test-apps

test-libs:: $(TEST_LIBRARY_LIST)

test-bundles:: $(TEST_BUNDLE_LIST)

test-tools:: $(TEST_TOOL_LIST)

test-apps:: $(TEST_APP_LIST)

internal-testlib-all:: $(GNUSTEP_OBJ_DIR)/$(TEST_LIBRARY_NAME)

internal-testbundle-all:: build-testbundle-dir build-testbundle

build-testbundle-dir::
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs \
	  $(TEST_BUNDLE_DIR_NAME) \
	  $(TEST_BUNDLE_DIR_NAME)/Resources \
	  $(TEST_BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO) \
	  $(TEST_BUNDLE_RESOURCE_DIRS)

build-testbundle:: $(TEST_BUNDLE_NAME) testbundle-resource-files

testbundle-resource-files::
	for f in $(RESOURCE_FILES); do \
	  $(INSTALL_DATA) $$f $(TEST_BUNDLE_DIR_NAME)/$$f ;\
	done

internal-testtool-all:: $(TEST_TOOL_NAME)

ifeq ($(OBJC_COMPILER), NeXT)
internal-testapp-all:: $(INTERNAL_TEST_APP_NAME).iconheader $(GNUSTEP_OBJ_DIR) \
   $(APP_DIR_NAME) $(TEST_APP_FILE) app-resource-files

$(INTERNAL_TEST_APP_NAME).iconheader:
	@(echo "F	$(INTERNAL_TEST_APP_NAME).$(APP_EXTENSION)	$(INTERNAL_TEST_APP_NAME)	$(APP_EXTENSION)"; \
	  echo "F	$(INTERNAL_TEST_APP_NAME)	$(INTERNAL_TEST_APP_NAME)	app") >$@

$(APP_DIR_NAME):
	mkdir $@
else
internal-testapp-all:: $(GNUSTEP_OBJ_DIR) \
   $(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO) $(TEST_APP_FILE) \
   app-resource-files

$(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO):
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs \
		$(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)
endif

app-resource-files::
	@(if [ "$(RESOURCE_FILES)" != "" ]; then \
	  echo "Copying resources into the application wrapper..."; \
	  cp -r $(RESOURCE_FILES) $(APP_DIR_NAME); \
	fi)

#
# Check targets (actually running the tests)
#

internal-check:: check-libs check-bundles check-tools check-apps

check-libs:: $(CHECK_LIBRARY_LIST)

check-bundles:: $(CHECK_BUNDLE_LIST)

check-tools:: $(CHECK_TOOL_LIST)

check-apps:: $(CHECK_APP_LIST)

dejagnu_vars = "FOUNDATION_LIBRARY=$(FOUNDATION_LIB)" \
		"OBJC_RUNTIME=$(OBJC_RUNTIME)"

internal-check-%:: $(SCRIPTS_DIRECTORY)/config/unix.exp
	@(for f in $(CHECK_SCRIPT_DIRS); do \
	  additional_library_paths="`echo $(ADDITIONAL_LIB_DIRS) | sed 's/-L//g'`"; \
	  additional_library_paths="`$(GNUSTEP_SYSTEM_ROOT)/Makefiles/transform_paths.sh $$additional_library_paths`" \
		. $(GNUSTEP_SYSTEM_ROOT)/Makefiles/ld_lib_path.sh; \
	  if [ "$(SCRIPTS_DIRECTORY)" != "" ]; then \
	    echo "cd $(SCRIPTS_DIRECTORY); runtest --tool $$f --srcdir . PROG=../$(GNUSTEP_OBJ_DIR)/$(TEST_$*_NAME) $(dejagnu_vars) $(ADDITIONAL_DEJAGNU_VARS)"; \
	    (cd $(SCRIPTS_DIRECTORY); runtest --tool $$f --srcdir . PROG=../$(GNUSTEP_OBJ_DIR)/$(TEST_$*_NAME) $(dejagnu_vars) $(ADDITIONAL_DEJAGNU_VARS)); \
	  else \
	    runtest --tool $$f --srcdir . PROG=./$(TEST_$*_NAME) \
		  $(dejagnu_vars) $(ADDITIONAL_DEJAGNU_VARS); \
	  fi; \
	done)

#
# Cleaning targets
#
internal-clean::
	rm -f $(TEST_LIBRARY_NAME)
	for f in $(TEST_BUNDLE_DIR_NAME); do \
	  rm -rf $$f ; \
	done
	rm -f $(TEST_TOOL_NAME)
	rm -rf $(GNUSTEP_OBJ_PREFIX)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)
ifeq ($(OBJC_COMPILER), NeXT)
	rm -f *.iconheader
	for f in *.$(APP_EXTENSION); do \
	  rm -f $$f/`basename $$f .$(APP_EXTENSION)`; \
	done
else
	rm -rf *.$(APP_EXTENSION)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)
endif
	rm -rf $(GNUSTEP_OBJ_PREFIX)

internal-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj *.app *.debug *.profile *.iconheader

