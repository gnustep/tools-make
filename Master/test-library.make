#
#   Master/test-library.make
#
#   Master Makefile rules for dejagnu/GNUstep based testing
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


TEST_LIBRARY_NAME := $(strip $(TEST_LIBRARY_NAME))

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

internal-all:: $(TEST_LIBRARY_NAME:=.all.test-lib.variables)

internal-install:: $(TEST_LIBRARY_NAME:=.install.test-lib.variables)

internal-uninstall:: $(TEST_LIBRARY_NAME:=.uninstall.test-lib.variables)

_PSWRAP_C_FILES = $(foreach lib,$(TEST_LIBRARY_NAME),$($(lib)_PSWRAP_FILES:.psw=.c))
_PSWRAP_H_FILES = $(foreach lib,$(TEST_LIBRARY_NAME),$($(lib)_PSWRAP_FILES:.psw=.h))

internal-clean::
	rm -rf $(GNUSTEP_OBJ_DIR) $(_PSWRAP_C_FILES) $(_PSWRAP_H_FILES)

internal-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj

TEST_LIBRARIES_WITH_SUBPROJECTS = $(strip $(foreach test-library,$(TEST_LIBRARY_NAME),$(patsubst %,$(test-library),$($(test-library)_SUBPROJECTS))))
ifneq ($(TEST_LIBRARIES_WITH_SUBPROJECTS),)
internal-clean:: $(TEST_LIBRARIES_WITH_SUBPROJECTS:=.clean.test-library.subprojects)
internal-distclean:: $(TEST_LIBRARIES_WITH_SUBPROJECTS:=.distclean.test-library.subprojects)
endif

internal-check:: $(TEST_LIBRARY_NAME:=.check.test-lib.variables)

$(TEST_LIBRARY_NAME)::
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.test-lib.variables

## Local variables:
## mode: makefile
## End:
