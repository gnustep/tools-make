#
#   target.make
#
#   Determine the compilation target.
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
# The user can specify a `target' variable when running make
#

ifeq ($(strip $(target)),)

# The default target
GNUSTEP_TARGET = $(CONFIG_TARGET)
GNUSTEP_TARGET_CPU = $(CONFIG_TARGET_CPU)
GNUSTEP_TARGET_VENDOR = $(CONFIG_TARGET_VENDOR)
GNUSTEP_TARGET_OS = $(CONFIG_TARGET_OS)

else

#
# Parse the target variable
#

GNUSTEP_TARGET = $(shell $(CONFIG_SUB_SCRIPT) $(target))
GNUSTEP_TARGET_CPU = $(shell $(CONFIG_CPU_SCRIPT) $(GNUSTEP_TARGET))
GNUSTEP_TARGET_VENDOR = $(shell $(CONFIG_VENDOR_SCRIPT) $(GNUSTEP_TARGET))
GNUSTEP_TARGET_OS = $(shell $(CONFIG_OS_SCRIPT) $(GNUSTEP_TARGET))

endif

#
# Clean up the target names
#

