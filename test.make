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
#
# xxx_LD_LIB_DIRS are additional directories that the dynamic loader
# should check when loading a shared library.
#

TEST_LIBRARY_LIST := $(TEST_LIBRARY_NAME:=.testlib)
CHECK_LIBRARY_LIST := $(TEST_LIBRARY_NAME:=.checklib)
TEST_LIBRARY_STAMPS := $(foreach lib,$(TEST_LIBRARY_NAME),stamp-testlib-$(lib))
TEST_LIBRARY_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(TEST_LIBRARY_STAMPS))

TEST_BUNDLE_LIST := $(TEST_BUNDLE_NAME:=.testbundle)
CHECK_BUNDLE_LIST := $(TEST_BUNDLE_NAME:=.checkbundle)
TEST_BUNDLE_STAMPS := $(foreach b,$(TEST_BUNDLE_NAME),stamp-testbundle-$(b))
TEST_BUNDLE_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(TEST_BUNDLE_STAMPS))

TEST_TOOL_LIST := $(TEST_TOOL_NAME:=.testtool)
CHECK_TOOL_LIST := $(TEST_TOOL_NAME:=.checktool)
TEST_TOOL_STAMPS := $(foreach tool,$(TEST_TOOL_NAME),stamp-testtool-$(tool))
TEST_TOOL_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(TEST_TOOL_STAMPS))

TEST_APP_LIST := $(TEST_APP_NAME:=.testapp)
CHECK_APP_LIST := $(TEST_APP_NAME:=.checkapp)
TEST_APP_STAMPS := $(foreach app,$(TEST_APP_NAME),stamp-testapp-$(app))
TEST_APP_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(TEST_APP_STAMPS))

ALL_LD_LIB_DIRS = $(ADDITIONAL_LD_LIB_DIRS)$(GNUSTEP_LD_LIB_DIRS)

ifeq ($(SCRIPTS_DIRECTORY),)
SCRIPTS_DIRECTORY = .
endif

#
# Internal targets
#

$(GNUSTEP_OBJ_DIR)/stamp-testlib-% : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(GNUSTEP_OBJ_DIR)/$(TEST_LIBRARY_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_LIBRARY_LIBS)
	touch $@

$(GNUSTEP_OBJ_DIR)/stamp-testbundle-%: $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(BUNDLE_LD) $(BUNDLE_LDFLAGS) $(ALL_LDFLAGS) \
		$(LDOUT)$(BUNDLE_FILE) $(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(BUNDLE_LIBS)
	touch $@

$(GNUSTEP_OBJ_DIR)/stamp-testtool-% : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(GNUSTEP_OBJ_DIR)/$(TEST_TOOL_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_TOOL_LIBS)
	touch $@

$(GNUSTEP_OBJ_DIR)/stamp-testapp-% : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(GNUSTEP_OBJ_DIR)/$(TEST_APP_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_APP_LIBS)
	touch $@

#
# Compilation targets
#
internal-all:: $(GNUSTEP_OBJ_DIR) internal-test-build

$(SCRIPTS_DIRECTORY)/config/unix.exp::
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs $(SCRIPTS_DIRECTORY)/config
	@echo "Creating the $@ file..."
	@echo "## Do Not Edit ##" > $@
	@echo "# Contents generated automatically by Makefile" >> $@
	@echo "#" >> $@
	@echo "" >> $@
	@echo "set OBJC_RUNTIME $(OBJC_RUNTIME)" >> $@
	@echo "set FOUNDATION_LIBRARY $(FOUNDATION_LIB)" >> $@
	@echo "" >> $@
	@echo "set OBJCTEST_DIR $(GNUSTEP_LIBRARIES_ROOT)/ObjCTest" >> $@
	@echo "set objdir `pwd`" >> $@
	@echo "source \"\$$OBJCTEST_DIR/common.exp\"" >> $@
	@echo "" >> $@
	@echo "# Maintain your own code in local.exp" >> $@
	@echo "source \"config/local.exp\"" >> $@

internal-test-build:: test-libs test-bundles test-tools test-apps

test-libs:: $(TEST_LIBRARY_LIST)

test-bundles:: $(TEST_BUNDLE_LIST)

test-tools:: $(TEST_TOOL_LIST)

test-apps:: $(TEST_APP_LIST)

internal-testlib-all:: $(GNUSTEP_OBJ_DIR)/stamp-testlib-$(TEST_LIBRARY_NAME)

internal-testbundle-all:: \
	$(GNUSTEP_OBJ_DIR)/stamp-testbundle-$(TEST_BUNDLE_NAME)

internal-testtool-all:: $(GNUSTEP_OBJ_DIR)/stamp-testtool-$(TEST_TOOL_NAME)

internal-testapp-all:: $(GNUSTEP_OBJ_DIR)/stamp-testapp-$(TEST_APP_NAME)

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
	  $(LD_LIB_PATH)=$(ALL_LD_LIB_DIRS); export $(LD_LIB_PATH); \
	  if [ "$(SCRIPTS_DIRECTORY)" != "" ]; then \
	    echo "cd $(SCRIPTS_DIRECTORY); runtest --tool $$f --srcdir . PROG=../$(GNUSTEP_OBJ_DIR)/$(TEST_$*_NAME) $(dejagnu_vars) $(ADDITIONAL_DEJAGNU_VARS)"; \
	    (cd $(SCRIPTS_DIRECTORY); runtest --tool $$f --srcdir . PROG=../$(GNUSTEP_OBJ_DIR)/$(TEST_$*_NAME) $(dejagnu_vars) $(ADDITIONAL_DEJAGNU_VARS)); \
	  else \
	    runtest --tool $$f --srcdir . PROG=./$(TEST_$*_NAME) \
		  $(dejagnu_vars) $(ADDITIONAL_DEJAGNU_VARS); \
	  fi; \
	done)
