#
#   rules.make
#
#   All of the common makefile rules.
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

ALL_CPPFLAGS = $(CPPFLAGS) $(ADDITIONAL_CPPFLAGS)

ALL_OBJCFLAGS = $(INTERNAL_OBJCFLAGS) $(ADDITIONAL_OBJCFLAGS) \
   $(ADDITIONAL_INCLUDE_DIRS) -I. $(SYSTEM_INCLUDES) \
   -I$(GNUSTEP_HEADERS_FND) -I$(GNUSTEP_HEADERS_GUI) -I$(GNUSTEP_HEADERS)

ALL_CFLAGS = $(INTERNAL_CFLAGS) $(ADDITIONAL_CFLAGS) \
   $(ADDITIONAL_INCLUDE_DIRS) -I. $(SYSTEM_INCLUDES) \
   -I$(GNUSTEP_HEADERS_FND) -I$(GNUSTEP_HEADERS_GUI) -I$(GNUSTEP_HEADERS) 

ALL_LDFLAGS = $(INTERNAL_LDFLAGS) $(ADDITIONAL_LDFLAGS) \
   $(FND_LDFLAGS) $(GUI_LDFLAGS) $(BACKEND_LDFLAGS) \
   $(SYSTEM_LDFLAGS)

ALL_LIB_DIRS = $(ADDITIONAL_LIB_DIRS) -L$(GNUSTEP_LIBRARIES) $(SYSTEM_LIB_DIR)

ALL_TOOL_LIBS = $(ADDITIONAL_TOOL_LIBS) $(FND_LIBS) $(OBJC_LIBS) \
   $(TARGET_SYSTEM_LIBS)

ALL_GUI_LIBS = $(ADDITIONAL_GUI_LIBS) $(BACKEND_LIBS) $(GUI_LIBS) \
   $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)

.SUFFIXES: .m .c .psw

%${OEXT} : %.m
	$(CC) -c $(ALL_CPPFLAGS) $(ALL_OBJCFLAGS) -o $@ $<

%${OEXT} : %.c
	$(CC) -c $(ALL_CPPFLAGS) $(ALL_CFLAGS) -o $@ $<

%.c : %.psw
	pswrap -h $*.h -o $@ $<

%_pic${OEXT}: %.m
	$(CC) -c $(ALL_CPPFLAGS) -fPIC -DPIC \
		$(ALL_OBJCFLAGS) -o $@ $<

%_pic${OEXT}: %.c
	$(CC) -c $(ALL_CPPFLAGS) -fPIC -DPIC \
		$(ALL_CFLAGS) -o $@ $<

# The magical app rule, thank you GNU make!
%.app : FORCE
	@echo Making $*...
	@$(MAKE) internal-app-all \
	APP_NAME=$* \
	OBJC_FILES="$($*_OBJC_FILES)" \
	C_FILES="$($*_C_FILES)" \
	PSWRAP_FILES="$($*_PSWRAP_FILES)"

%.tool : FORCE
	@echo Making $*...
	@$(MAKE) internal-tool-all \
	TOOL_NAME=$* \
	OBJC_FILES="$($*_OBJC_FILES)" \
	C_FILES="$($*_C_FILES)" \
	PSWRAP_FILES="$($*_PSWRAP_FILES)"

#
# The list of Objective-C source files to be compiled
# are in the OBJC_FILES variable.
#
# The list of C source files to be compiled
# are in the C_FILES variable.
#
# The list of PSWRAP source files to be compiled
# are in the PSWRAP_FILES variable.

OBJC_OBJ_FILES = $(OBJC_FILES:.m=${OEXT})

PSWRAP_C_FILES = $(PSWRAP_FILES:.psw=.c)
PSWRAP_H_FILES = $(PSWRAP_FILES:.psw=.h)
PSWRAP_OBJ_FILES = $(PSWRAP_FILES:.psw=${OEXT})

C_OBJ_FILES = $(C_FILES:.c=${OEXT}) $(PSWRAP_OBJ_FILES)

#
# Global targets
#
all:: before-all internal-all after-all

install:: before-install internal-install after-install

uninstall:: before-uninstall internal-uninstall after-uninstall

clean:: before-clean internal-clean after-clean

distclean:: before-distclean internal-distclean after-distclean

check:: before-check internal-check after-check

#
# Placeholders for internal targets
#

before-all::

internal-all::

after-all::

before-install::

internal-install::

after-install::

before-uninstall::

internal-uninstall::

after-uninstall::

before-clean::

internal-clean::

after-clean::

before-distclean::

internal-distclean::

after-distclean::

before-check::

internal-check::

after-check::

FORCE: