#
#   clean.make
#
#   Clean up the host and target names
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


ifneq ($(internal_names_clean), yes)
# Clean up the host names
export GNUSTEP_HOST_CPU := $(shell $(CLEAN_CPU_SCRIPT) $(GNUSTEP_HOST_CPU))
export GNUSTEP_HOST_VENDOR := $(shell $(CLEAN_VENDOR_SCRIPT) $(GNUSTEP_HOST_VENDOR))
export GNUSTEP_HOST_OS := $(shell $(CLEAN_OS_SCRIPT) $(GNUSTEP_HOST_OS))

# Clean up the target names
export GNUSTEP_TARGET_CPU := $(shell $(CLEAN_CPU_SCRIPT) $(GNUSTEP_TARGET_CPU))
export GNUSTEP_TARGET_VENDOR := $(shell $(CLEAN_VENDOR_SCRIPT) $(GNUSTEP_TARGET_VENDOR))
export GNUSTEP_TARGET_OS := $(shell $(CLEAN_OS_SCRIPT) $(GNUSTEP_TARGET_OS))

ifneq ($(arch),)
export CLEANED_ARCH = $(foreach a, $(arch), $(shell $(CLEAN_CPU_SCRIPT) $(a)))
endif

export internal_names_clean=yes

endif
