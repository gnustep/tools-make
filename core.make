#
#   core.make
#
#   Determine the core libraries.
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
# The user can specify the `library_combo' variable when running make
#

ifeq ($(strip $(library_combo)),)

# The default is GNU
OBJC_RUNTIME_LIB = gnu
FOUNDATION_LIB = gnu
GUI_LIB = gnu
GUI_BACKEND_LIB = xdp

# Except on OPENSTEP systems where the default is (you guessed it) NeXT
ifeq ($(GNUSTEP_TARGET_OS),nextstep4)

OBJC_RUNTIME_LIB = nx
FOUNDATION_LIB = nx
GUI_LIB = nx
GUI_BACKEND_LIB = nil

endif

else

# Strip out the individual libraries from the combo string
combo_list = $(subst _, ,$(library_combo))
OBJC_RUNTIME_LIB = $(word 1,$(combo_list))
FOUNDATION_LIB = $(word 2,$(combo_list))
GUI_LIB = $(word 3,$(combo_list))
GUI_BACKEND_LIB = $(word 4,$(combo_list))

endif

LIBRARY_COMBO = $(OBJC_RUNTIME_LIB)_$(FOUNDATION_LIB)_$(GUI_LIB)_$(GUI_BACKEND_LIB)
