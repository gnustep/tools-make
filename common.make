#
#   common.make
#
#   Set all of the common environment variables.
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

# Default version
VERSION = 1.0.0

#
# Scripts to run for parsing canonical names
#
CONFIG_GUESS_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/config.guess
CONFIG_SUB_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/config.sub
CONFIG_CPU_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/cpu.sh
CONFIG_VENDOR_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/vendor.sh
CONFIG_OS_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/os.sh
CLEAN_CPU_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/clean_cpu.sh
CLEAN_VENDOR_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/clean_vendor.sh
CLEAN_OS_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/clean_os.sh

#
# Determine the compilation host and target
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/target.make

GNUSTEP_HOST_DIR = $(GNUSTEP_HOST_CPU)/$(GNUSTEP_HOST_OS)
GNUSTEP_TARGET_DIR = $(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)

#
# Get the config information
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/$(GNUSTEP_TARGET_DIR)/config.make

#
# Determine the core libraries
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/core.make

GNUSTEP_OBJ_DIR = objs/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)

#
# Variables specifying the installation directory paths
#
GNUSTEP_APPS = $(GNUSTEP_SYSTEM_ROOT)/Apps
GNUSTEP_TOOLS = $(GNUSTEP_SYSTEM_ROOT)/Tools
GNUSTEP_HEADERS = $(GNUSTEP_SYSTEM_ROOT)/Headers
GNUSTEP_LIBRARIES_ROOT = $(GNUSTEP_SYSTEM_ROOT)/Libraries
GNUSTEP_LIBRARIES = $(GNUSTEP_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)
GNUSTEP_RESOURCES = $(GNUSTEP_LIBRARIES_ROOT)/Resources
GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

#
# Determine Foundation header subdirectory based upon library combo
#
FND_HEADER =

ifeq ($(FOUNDATION_LIB),gnu)
FND_HEADER = /gnustep/base
endif

ifeq ($(FOUNDATION_LIB),fd)
FND_HEADER = /libFoundation
endif

GNUSTEP_HEADERS_FND = $(GNUSTEP_HEADERS)$(FND_HEADER)

#
# Determine AppKit header subdirectory based upon library combo
#
APP_HEADER =

ifeq ($(GUI_LIB),gnu)
APP_HEADER = /gnustep/gui
endif

GNUSTEP_HEADERS_GUI = $(GNUSTEP_HEADERS)$(APP_HEADER)

#
# Overridable compilation flags
#
DEBUGFLAG = -g
OPTFLAG = -O2
OBJCFLAGS = -Wno-implicit -Wno-import
CFLAGS = 

ifeq ($(OBJC_RUNTIME_LIB),gnu)
RUNTIME_FLAG = -fgnu-runtime
endif

ifeq ($(OBJC_RUNTIME_LIB),nx)
RUNTIME_FLAG = -fnext-runtime
endif

INTERNAL_OBJCFLAGS = $(DEBUGFLAG) $(OPTFLAG) $(OBJCFLAGS) $(RUNTIME_FLAG)
INTERNAL_CFLAGS = $(DEBUGFLAG) $(OPTFLAG) $(CFLAGS) $(RUNTIME_FLAG)
INTERNAL_LDFLAGS = $(LDFLAGS)
