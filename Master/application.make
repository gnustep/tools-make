#
#   application.make
#
#   Master makefile rules to build GNUstep-based applications.
#
#   Copyright (C) 1997, 2001, 2002 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola@brainstorm.co.uk>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#   Based on the original version by Scott Christley.
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

APP_NAME := $(strip $(APP_NAME))

internal-all:: $(APP_NAME:=.all.app.variables)

internal-install:: $(APP_NAME:=.install.app.variables)

internal-uninstall:: $(APP_NAME:=.uninstall.app.variables)

# Compute them manually to avoid having to do an Instance make
# invocation just to remove them.
_PSWRAP_C_FILES = $(foreach app,$(APP_NAME),$($(app)_PSWRAP_FILES:.psw=.c))
_PSWRAP_H_FILES = $(foreach app,$(APP_NAME),$($(app)_PSWRAP_FILES:.psw=.h))

internal-clean:: $(APP_NAME:=.clean.app.subprojects)
	rm -rf $(GNUSTEP_OBJ_DIR) $(_PSWRAP_C_FILES) $(_PSWRAP_H_FILES)
ifeq ($(OBJC_COMPILER), NeXT)
	rm -f *.iconheader
	for f in *.$(APP_EXTENSION); do \
	  rm -f $$f/`basename $$f .$(APP_EXTENSION)`; \
	done
else
ifeq ($(GNUSTEP_FLATTENED),)
	rm -rf *.$(APP_EXTENSION)/$(GNUSTEP_TARGET_LDIR)
else
	rm -rf *.$(APP_EXTENSION)
endif
endif

internal-distclean:: $(APP_NAME:=.distclean.app.subprojects)
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj *.app *.debug *.profile *.iconheader

$(APP_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory $@.all.app.variables


## Local variables:
## mode: makefile
## End:
