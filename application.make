#
#   application.make
#
#   Makefile rules to build GNUstep-based applications.
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

LINK_CMD = $(CC) $(ALL_CFLAGS) $@$(OEXT) -o $@ $(ALL_LDFLAGS)

#
# The name of the library is in the APP_NAME variable.
#

APP_DIR_NAME := $(foreach app,$(APP_NAME),$(app).app)
APP_FILE = $(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)/$(APP_NAME)$(EXEEXT)
APP_STAMPS := $(foreach app,$(APP_NAME),stamp-app-$(app))
APP_STAMPS := $(addprefix $(GNUSTEP_OBJ_DIR)/,$(APP_STAMPS))

#
# Internal targets
#

$(GNUSTEP_OBJ_DIR)/stamp-app-% : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(APP_FILE) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_GUI_LIBS)
	touch $@

#
# Compilation targets
#
internal-all:: $(GNUSTEP_OBJ_DIR) $(APP_DIR_NAME)

internal-app-all:: $(GNUSTEP_OBJ_DIR) build-app-dir build-app

build-app-dir::
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs \
		$(APP_DIR_NAME) \
		$(APP_DIR_NAME)/$(GNUSTEP_TARGET_CPU) \
		$(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR) \
		$(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)

build-app:: $(GNUSTEP_OBJ_DIR)/stamp-app-$(APP_NAME)

#
# Cleaning targets
#
internal-clean::
	for f in $(APP_DIR_NAME); do \
	  rm -rf $$f ; \
	done
	rm -f $(APP_STAMPS)

internal-distclean:: clean
	rm -rf objs
