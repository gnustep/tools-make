#
#   Instance/test-application.make
#
#   Copyright (C) 2002 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola@brainstorm.co.uk>
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

# Just inherit the build rule from application.make

include $(GNUSTEP_MAKEFILES)/Instance/application.make

internal-test_app-all:: internal-app-all

