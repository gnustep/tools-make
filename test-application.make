#
#   test-application.make
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

# prevent multiple inclusions
ifeq ($(TEST_APPLICATION_MAKE_LOADED),)
TEST_APPLICATION_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/rules.make

# building of test applications calls the application.make rules
ifeq ($(INTERNAL_app_NAME),)

internal-all:: $(TEST_APP_NAME:=.all.app.variables)

internal-clean:: $(TEST_APP_NAME:=.clean.app.variables)

internal-distclean:: $(TEST_APP_NAME:=.distclean.app.variables)

$(TEST_APP_NAME):
	@$(MAKE) --no-print-directory $@.all.app.variables

else

# We use the application.make rules for building
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/application.make

endif

# However we do not install test applications
ifeq ($(INTERNAL_testapp_NAME),)

internal-install:: $(TEST_APP_NAME:=.install.testapp.variables)

internal-uninstall:: $(TEST_APP_NAME:=.uninstall.testapp.variables)

internal-check:: $(TEST_APP_NAME:=.check.testapp.variables)

else

internal-install:: $(TEST_APP_NAME:=.install.testapp.variables)

internal-uninstall:: $(TEST_APP_NAME:=.uninstall.testapp.variables)

endif

endif
# test-application.make loaded
