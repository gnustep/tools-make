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

# Run config.guess to guess the host

GNUSTEP_HOST = $(shell $(CONFIG_GUESS_SCRIPT))
GNUSTEP_HOST_CPU = $(shell $(CONFIG_CPU_SCRIPT) $(GNUSTEP_HOST))
GNUSTEP_HOST_VENDOR = $(shell $(CONFIG_VENDOR_SCRIPT) $(GNUSTEP_HOST))
GNUSTEP_HOST_OS = $(shell $(CONFIG_OS_SCRIPT) $(GNUSTEP_HOST))

#
# The user can specify a `target' variable when running make
#

ifeq ($(strip $(target)),)

# The host is the default target
GNUSTEP_TARGET = $(GNUSTEP_HOST)
GNUSTEP_TARGET_CPU = $(GNUSTEP_HOST_CPU)
GNUSTEP_TARGET_VENDOR = $(GNUSTEP_HOST_VENDOR)
GNUSTEP_TARGET_OS = $(GNUSTEP_HOST_OS)

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
include $(GNUSTEP_ROOT)/Makefiles/clean.make

#
# Host and target specific settings
#
ifeq ($(GNUSTEP_TARGET_OS),solaris2)
X_INCLUDES := $(X_INCLUDES)/X11
endif

#
# Target specific libraries
#
ifeq ($(GNUSTEP_TARGET_OS),linux-gnu)
TARGET_SYSTEM_LIBS := -lpcthread -ldl -lm
endif