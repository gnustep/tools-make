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

ifeq ($(INTERNAL_testlib_NAME),)

internal-all:: $(TEST_LIBRARY_NAME:=.all.testlib.variables)

internal-install:: $(TEST_LIBRARY_NAME:=.install.testlib.variables)

internal-uninstall:: $(TEST_LIBRARY_NAME:=.uninstall.testlib.variables)

internal-clean:: $(TEST_LIBRARY_NAME:=.clean.testlib.variables)

internal-distclean:: $(TEST_LIBRARY_NAME:=.distclean.testlib.variables)

internal-check:: $(TEST_LIBRARY_NAME:=.check.testlib.variables)

$(TEST_LIBRARY_NAME):
	@$(MAKE) --no-print-directory $@.all.testlib.variables

else

ifeq ($(SCRIPTS_DIRECTORY),)
SCRIPTS_DIRECTORY = .
endif

ALL_TEST_LIBRARY_LIBS = $(ADDITIONAL_LIBRARY_LIBS) $(AUXILIARY_LIBS) \
    -lobjc-test \
    $(AUXILIARY_TOOL_LIBS) $(FND_LIBS) $(OBJC_LIBS) $(TARGET_SYSTEM_LIBS)

ALL_TEST_LIBRARY_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_TEST_LIBRARY_LIBS)\
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

internal-testlib-all:: before-$(TARGET)-all $(GNUSTEP_OBJ_DIR) \
	$(GNUSTEP_OBJ_DIR)/$(INTERNAL_testlib_NAME) after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

$(GNUSTEP_OBJ_DIR)/$(INTERNAL_testlib_NAME): $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$@ \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_LIBRARY_LIBS)

dejagnu_vars = "FOUNDATION_LIBRARY=$(FOUNDATION_LIB)" \
		"OBJC_RUNTIME=$(OBJC_RUNTIME)"

internal-testlib-check:: $(SCRIPTS_DIRECTORY)/config/unix.exp \
	really-testlib-check

really-testlib-check:
	@(additional_library_paths="`echo $(ADDITIONAL_LIB_DIRS) | sed 's/-L//g'`"; \
	  additional_library_paths="`$(GNUSTEP_SYSTEM_ROOT)/Makefiles/transform_paths.sh $$additional_library_paths`"; \
		. $(GNUSTEP_SYSTEM_ROOT)/Makefiles/ld_lib_path.sh; \
	for f in $(CHECK_SCRIPT_DIRS); do \
	  if [ "$(SCRIPTS_DIRECTORY)" != "" ]; then \
	    echo "cd $(SCRIPTS_DIRECTORY); runtest --tool $$f --srcdir . PROG=../$(GNUSTEP_OBJ_DIR)/$(INTERNAL_testlib_NAME) $(dejagnu_vars) $(ADDITIONAL_DEJAGNU_VARS)"; \
	    (cd $(SCRIPTS_DIRECTORY); runtest --tool $$f --srcdir . PROG=../$(GNUSTEP_OBJ_DIR)/$(INTERNAL_testlib_NAME) $(dejagnu_vars) $(ADDITIONAL_DEJAGNU_VARS)); \
	  else \
	    runtest --tool $$f --srcdir . PROG=./$(INTERNAL_testlib_NAME) \
		  $(dejagnu_vars) $(ADDITIONAL_DEJAGNU_VARS); \
	  fi; \
	done)

$(SCRIPTS_DIRECTORY)/config/unix.exp:
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

internal-testlib-install::

internal-testlib-uninstall::

#
# Cleaning targets
#
internal-testlib-clean::
	rm -rf $(GNUSTEP_OBJ_DIR)

internal-testlib-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

endif
