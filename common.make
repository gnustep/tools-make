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

SHELL = /bin/sh

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
# Scripts used for installing data and program files
#
INSTALL = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/install-sh -c
INSTALL_DATA = $(INSTALL) -m 644
INSTALL_PROGRAM = $(INSTALL)

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

#
# Variables specifying the installation directory paths
#
GNUSTEP_APPS = $(GNUSTEP_SYSTEM_ROOT)/Apps
GNUSTEP_TOOLS = $(GNUSTEP_SYSTEM_ROOT)/Tools
GNUSTEP_HEADERS = $(GNUSTEP_SYSTEM_ROOT)/Headers
GNUSTEP_TARGET_HEADERS = $(GNUSTEP_HEADERS)/$(GNUSTEP_TARGET_DIR)
GNUSTEP_LIBRARIES_ROOT = $(GNUSTEP_SYSTEM_ROOT)/Libraries
GNUSTEP_LIBRARIES = $(GNUSTEP_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)
GNUSTEP_RESOURCES = $(GNUSTEP_LIBRARIES_ROOT)/Resources
GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

#
# Determine Foundation header subdirectory based upon library combo
#
ifeq ($(FOUNDATION_LIB),gnu)
GNUSTEP_HEADERS_FND = $(GNUSTEP_HEADERS)/gnustep/base
GNUSTEP_HEADERS_FND_FLAG = -I$(GNUSTEP_HEADERS_FND)
endif

ifeq ($(FOUNDATION_LIB),fd)
GNUSTEP_HEADERS_FND = $(GNUSTEP_HEADERS)/libFoundation
GNUSTEP_HEADERS_FND_FLAG = -I$(GNUSTEP_HEADERS_FND)
endif

ifeq ($(OBJC_COMPILER), NeXT)
  ifeq ($(FOUNDATION_LIB),nx)
    GNUSTEP_HEADERS_FND =
    GNUSTEP_HEADERS_FND_FLAG = -framework Foundation
  endif
endif

#
# Determine AppKit header subdirectory based upon library combo
#
ifeq ($(GUI_LIB),gnu)
GNUSTEP_HEADERS_GUI = $(GNUSTEP_HEADERS)/gnustep/gui
GNUSTEP_HEADERS_GUI_FLAG = -I$(GNUSTEP_HEADERS_GUI)
endif

ifeq ($(OBJC_COMPILER), NeXT)
  ifeq ($(FOUNDATION_LIB),nx)
    GNUSTEP_HEADERS_GUI =
    GNUSTEP_HEADERS_GUI_FLAG = -framework AppKit
  endif
endif

#
# Overridable compilation flags
#
OBJCFLAGS = -Wno-implicit -Wno-import
CFLAGS =
OBJ_DIR_PREFIX =

ifeq ($(OBJC_RUNTIME_LIB),gnu)
RUNTIME_FLAG = -fgnu-runtime
endif

ifeq ($(OBJC_RUNTIME_LIB),nx)
RUNTIME_FLAG = -fnext-runtime
endif

OPTFLAG = -O2

# Enable building shared libraries by default. If the user wants to build a
# static library, he/she has to specify shared=no explicitly.
ifeq ($(HAVE_SHARED_LIBS), yes)
  ifeq ($(shared), no)
    shared=no
  else
    shared=yes
  endif
endif

ifeq ($(shared), yes)
  LIB_LINK_CMD = $(SHARED_LIB_LINK_CMD)
  OBJ_DIR_PREFIX += shared_
  INTERNAL_OBJCFLAGS = $(SHARED_CFLAGS)
  INTERNAL_CFLAGS = $(SHARED_CFLAGS)
  AFTER_INSTALL_LIBRARY_CMD = $(AFTER_INSTALL_SHARED_LIB_COMMAND)
else
  LIB_LINK_CMD = $(STATIC_LIB_LINK_CMD)
  OBJ_DIR_PREFIX += static_
  AFTER_INSTALL_LIBRARY_CMD = $(AFTER_INSTALL_STATIC_LIB_COMMAND)
endif

ifeq ($(profile), yes)
ADDITIONAL_FLAGS += -pg
OBJ_DIR_PREFIX += profile_
endif

ifeq ($(debug), yes)
ADDITIONAL_FLAGS += -g
OBJ_DIR_PREFIX += debug_
endif

OBJ_DIR_PREFIX += obj

INTERNAL_OBJCFLAGS += $(ADDITIONAL_FLAGS) $(OPTFLAG) $(OBJCFLAGS) \
			$(RUNTIME_FLAG)
INTERNAL_CFLAGS += $(ADDITIONAL_FLAGS) $(CFLAGS) $(OPTFLAG) $(RUNTIME_FLAG)
INTERNAL_LDFLAGS += $(LDFLAGS)

GNUSTEP_OBJ_DIR = $(shell echo $(OBJ_DIR_PREFIX) | sed 's/ //g')/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)

