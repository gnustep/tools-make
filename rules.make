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

ALL_OBJCFLAGS = $(OBJCFLAGS) $(ADDITIONAL_OBJCFLAGS) \
   $(ADDITIONAL_INCLUDE_DIRS) \
   -I$(GNUSTEP_HEADER) -I$(GNUSTEP_HEADERS_ROOT)

ALL_CFLAGS = $(CFLAGS) $(ADDITIONAL_CFLAGS) \
   $(ADDITIONAL_INCLUDE_DIRS) \
   -I$(GNUSTEP_HEADER) -I$(GNUSTEP_HEADERS_ROOT)

.SUFFIXES: .m .c

%${OEXT} : %.m
	$(CC) -c $(ALL_CPPFLAGS) $(ALL_OBJCFLAGS) -o $@ $<

%${OEXT} : %.c
	$(CC) -c $(ALL_CPPFLAGS) $(ALL_CFLAGS) -o $@ $<

%_pic${OEXT}: %.m
	$(CC) -c $(ALL_CPPFLAGS) -fPIC -DPIC \
		$(ALL_OBJCFLAGS) -o $@ $<

%_pic${OEXT}: %.c
	$(CC) -c $(ALL_CPPFLAGS) -fPIC -DPIC \
		$(ALL_CFLAGS) -o $@ $<

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
