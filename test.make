#
#   test.make
#
#   Makefile rules for dejagnu/GNUstep based testing
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
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
# xxx_INCLUDE_DIRS are additional headers directories to be searched
#
# xxx_LIB_DIRS and xxx_LIBS are additional libraries directories and
# libraries to link against, respectively to link the xxx test driver.
#
# xxx_LD_LIB_DIRS are additional directories that the dynamic loader
# should check when loading a shared library.
#

TEST_LIBRARY_LIST := $(foreach lib,$(TEST_LIBRARY_NAME),$(lib).testlib)
CHECK_LIBRARY_LIST := $(foreach lib,$(TEST_LIBRARY_NAME),$(lib).checklib)
TEST_LIBRARY_STAMPS := $(foreach lib,$(TEST_LIBRARY_NAME),stamp-testlib-$(lib))
TEST_LIBRARY_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(TEST_LIBRARY_STAMPS))

TEST_BUNDLE_LIST := $(foreach b,$(TEST_BUNDLE_NAME),$(b).testbundle)
CHECK_BUNDLE_LIST := $(foreach b,$(TEST_BUNDLE_NAME),$(b).checkbundle)
TEST_BUNDLE_STAMPS := $(foreach b,$(TEST_BUNDLE_NAME),stamp-testbundle-$(b))
TEST_BUNDLE_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(TEST_BUNDLE_STAMPS))

TEST_TOOL_LIST := $(foreach tool,$(TEST_TOOL_NAME),$(tool).testtool)
CHECK_TOOL_LIST := $(foreach tool,$(TEST_TOOL_NAME),$(tool).checktool)
TEST_TOOL_STAMPS := $(foreach tool,$(TEST_TOOL_NAME),stamp-testtool-$(tool))
TEST_TOOL_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(TEST_TOOL_STAMPS))

TEST_APP_LIST := $(foreach app,$(TEST_APP_NAME),$(app).testapp)
CHECK_APP_LIST := $(foreach app,$(TEST_APP_NAME),$(app).checkapp)
TEST_APP_STAMPS := $(foreach app,$(TEST_APP_NAME),stamp-testapp-$(app))
TEST_APP_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(TEST_APP_STAMPS))

#
# Internal targets
#

$(GNUSTEP_OBJ_DIR)/stamp-testlib-% : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(TEST_LIBRARY_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_LIBRARY_LIBS)
	touch $@

$(GNUSTEP_OBJ_DIR)/stamp-testbundle-% : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(TEST_BUNDLE_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_BUNDLE_LIBS)
	touch $@

$(GNUSTEP_OBJ_DIR)/stamp-testtool-% : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(TEST_TOOL_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_TOOL_LIBS)
	touch $@

$(GNUSTEP_OBJ_DIR)/stamp-testapp-% : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(TEST_APP_NAME) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_TEST_APP_LIBS)
	touch $@

#
# Compilation targets
#
internal-all:: config/unix.exp $(GNUSTEP_OBJ_DIR) internal-test-build

config/unix.exp::
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs config
	@echo "Creating the config/unix.exp file..."
	@echo "## Do Not Edit ##" > config/unix.exp
	@echo "# Contents generated automatically by Makefile" >> config/unix.exp
	@echo "#" >> config/unix.exp
	@echo "" >> config/unix.exp
	@echo "set OBJC_RUNTIME $(OBJC_RUNTIME)" >> config/unix.exp
	@echo "set FOUNDATION_LIB $(FOUNDATION_LIB)" >> config/unix.exp
	@echo "" >> config/unix.exp
	@echo "set OBJCTEST_DIR $(GNUSTEP_LIBRARIES_ROOT)/ObjCTest" >> config/unix.exp
	@echo "set objdir `pwd`" >> config/unix.exp
	@echo "source \"\$$OBJCTEST_DIR/common.exp\"" >> config/unix.exp
	@echo "" >> config/unix.exp
	@echo "# Maintain your own code in local.exp" >> config/unix.exp
	@echo "source \"config/local.exp\"" >> config/unix.exp

internal-test-build:: test-libs test-bundles test-tools test-apps

test-libs:: $(TEST_LIBRARY_LIST)

test-bundles:: $(TEST_BUNDLE_LIST)

test-tools:: $(TEST_TOOL_LIST)

test-apps:: $(TEST_APP_LIST)

internal-testlib-all:: $(GNUSTEP_OBJ_DIR)/stamp-testlib-$(TEST_LIBRARY_NAME)

internal-testbundle-all:: $(GNUSTEP_OBJ_DIR)/stamp-testbundle-$(TEST_BUNDLE_NAME)

internal-testtool-all:: $(GNUSTEP_OBJ_DIR)/stamp-testtool-$(TEST_TOOL_NAME)

internal-testapp-all:: $(GNUSTEP_OBJ_DIR)/stamp-testapp-$(TEST_APP_NAME)

#
# Check targets (actually running the tests)
#

internal-check:: config/unix.exp check-libs check-bundles check-tools check-apps

check-libs:: $(CHECK_LIBRARY_LIST)

check-bundles:: $(CHECK_BUNDLE_LIST)

check-tools:: $(CHECK_TOOL_LIST)

check-apps:: $(CHECK_APP_LIST)

internal-check-lib::
	for f in $(CHECK_SCRIPT_DIRS); do \
	  ($(LD_LIB_PATH)=$(ALL_LD_LIB_DIRS); export $(LD_LIB_PATH); \
	   runtest --tool $$f --srcdir . PROG=./$(TEST_LIBRARY_NAME)) ; \
	done

internal-check-bundle::
	for f in $(CHECK_SCRIPT_DIRS); do \
	  ($(LD_LIB_PATH)=$(ALL_LD_LIB_DIRS); export $(LD_LIB_PATH); \
	   runtest --tool $$f --srcdir . PROG=./$(TEST_BUNDLE_NAME) ; \
	done

internal-check-tool::
	for f in $(CHECK_SCRIPT_DIRS); do \
	  ($(LD_LIB_PATH)=$(ALL_LD_LIB_DIRS); export $(LD_LIB_PATH); \
	   runtest --tool $$f --srcdir . PROG=./$(TEST_TOOL_NAME) ; \
	done

internal-check-app::
	for f in $(CHECK_SCRIPT_DIRS); do \	
	  ($(LD_LIB_PATH)=$(ALL_LD_LIB_DIRS); export $(LD_LIB_PATH); \
	   runtest --tool $$f --srcdir . PROG=./$(TEST_APP_NAME) ; \
	done
