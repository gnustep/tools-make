#
#   common.make
#
#   Set all of the common environment variables.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
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
WHICH_LIB_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/$(GNUSTEP_HOST_CPU)/$(GNUSTEP_HOST_OS)/which_lib
LD_LIB_PATH_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/ld_lib_path.sh

#
# Scripts used for installing data and program files
#
INSTALL = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/install-sh -c
INSTALL_DATA = $(INSTALL) -m 644
INSTALL_PROGRAM = $(INSTALL)

#
# Get the config information
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/$(GNUSTEP_TARGET_DIR)/config.make

#
# Determine the core libraries
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/core.make

#
# Determine the compilation host and target
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/target.make

GNUSTEP_HOST_DIR = $(GNUSTEP_HOST_CPU)/$(GNUSTEP_HOST_OS)
GNUSTEP_TARGET_DIR = $(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)

#
# Variables specifying the installation directory paths
#
GNUSTEP_APPS = $(GNUSTEP_SYSTEM_ROOT)/Apps
GNUSTEP_TOOLS = $(GNUSTEP_SYSTEM_ROOT)/Tools
GNUSTEP_HEADERS = $(GNUSTEP_SYSTEM_ROOT)/Headers
GNUSTEP_TARGET_HEADERS = $(GNUSTEP_HEADERS)/$(GNUSTEP_TARGET_DIR)
GNUSTEP_LIBRARIES_ROOT = $(GNUSTEP_SYSTEM_ROOT)/Libraries
GNUSTEP_TARGET_LIBRARIES = $(GNUSTEP_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)
GNUSTEP_LIBRARIES = $(GNUSTEP_TARGET_LIBRARIES)/$(LIBRARY_COMBO)
GNUSTEP_RESOURCES = $(GNUSTEP_LIBRARIES_ROOT)/Resources
GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

# In case we need to explicitly reference
# the system, local, and user library directories
GNUSTEP_SYSTEM_LIBRARIES_ROOT = $(GNUSTEP_SYSTEM_ROOT)/Libraries
GNUSTEP_SYSTEM_TARGET_LIBRARIES = $(GNUSTEP_SYSTEM_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)
GNUSTEP_SYSTEM_LIBRARIES = $(GNUSTEP_SYSTEM_TARGET_LIBRARIES)/$(LIBRARY_COMBO)

GNUSTEP_LOCAL_LIBRARIES_ROOT = $(GNUSTEP_LOCAL_ROOT)/Libraries
GNUSTEP_LOCAL_TARGET_LIBRARIES = $(GNUSTEP_LOCAL_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)
GNUSTEP_LOCAL_LIBRARIES = $(GNUSTEP_LOCAL_TARGET_LIBRARIES)/$(LIBRARY_COMBO)

GNUSTEP_USER_LIBRARIES_ROOT = $(GNUSTEP_USER_ROOT)/Libraries
GNUSTEP_USER_TARGET_LIBRARIES = $(GNUSTEP_USER_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)
GNUSTEP_USER_LIBRARIES = $(GNUSTEP_USER_TARGET_LIBRARIES)/$(LIBRARY_COMBO)

#
# Determine Foundation header subdirectory based upon library combo
#
ifeq ($(FOUNDATION_LIB),gnu)
GNUSTEP_FND_DIR = gnustep/base
FOUNDATION_LIBRARY_NAME = gnustep-base
FOUNDATION_LIBRARY_DEFINE = -DGNUSTEP_BASE_LIBRARY=1
GNUSTEP_HEADERS_FND = $(GNUSTEP_HEADERS)/$(GNUSTEP_FND_DIR)
GNUSTEP_HEADERS_FND_FLAG = -I$(GNUSTEP_HEADERS_FND) \
	-I$(GNUSTEP_HEADERS_FND)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(OBJC_RUNTIME)
endif

ifeq ($(FOUNDATION_LIB),fd)
GNUSTEP_FND_DIR = libFoundation
FOUNDATION_LIBRARY_NAME = Foundation
FOUNDATION_LIBRARY_DEFINE = -DLIB_FOUNDATION_LIBRARY=1
GNUSTEP_HEADERS_FND = $(GNUSTEP_HEADERS)/$(GNUSTEP_FND_DIR)
GNUSTEP_HEADERS_FND_FLAG = -I$(GNUSTEP_HEADERS_FND) \
	-I$(GNUSTEP_HEADERS_FND)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(OBJC_RUNTIME)
endif

ifeq ($(FOUNDATION_LIB),nx)
GNUSTEP_HEADERS_FND =
#GNUSTEP_HEADERS_FND_FLAG = -framework Foundation
FOUNDATION_LIBRARY_DEFINE = -DNeXT_Foundation_LIBRARY=1
endif

ifeq ($(FOUNDATION_LIB),sun)
GNUSTEP_FND_DIR = sun
GNUSTEP_HEADERS_FND = $(GNUSTEP_HEADERS)/$(GNUSTEP_FND_DIR)
FOUNDATION_LIBRARY_DEFINE = -DSun_Foundation_LIBRARY=1
GNUSTEP_HEADERS_FND_FLAG = -I$(GNUSTEP_HEADERS_FND)
endif

#
# Determine AppKit header subdirectory based upon library combo
#
ifeq ($(GUI_LIB),gnu)
GNUSTEP_HEADERS_GUI = $(GNUSTEP_HEADERS)/gnustep/gui
GNUSTEP_HEADERS_GUI_FLAG = -I$(GNUSTEP_HEADERS_GUI)
endif

ifeq ($(GUI_LIB),nx)
GNUSTEP_HEADERS_GUI =
#GNUSTEP_HEADERS_GUI_FLAG = -framework AppKit
endif

#
# Overridable compilation flags
#
OBJCFLAGS = -Wno-implicit -Wno-import
CFLAGS =
OBJ_DIR_PREFIX =

ifeq ($(OBJC_RUNTIME_LIB),gnu)
RUNTIME_FLAG = -fgnu-runtime
RUNTIME_DEFINE = -DGNU_RUNTIME=1
endif

ifeq ($(OBJC_RUNTIME_LIB),nx)
  ifneq ($(OBJC_COMPILER), NeXT)
    RUNTIME_FLAG = -fnext-runtime
  endif
RUNTIME_DEFINE = -DNeXT_RUNTIME=1
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
  LIBRARY_NAME_SUFFIX := s$(LIBRARY_NAME_SUFFIX)
endif

ifeq ($(profile), yes)
ADDITIONAL_FLAGS += -pg
OBJ_DIR_PREFIX += profile_
  LIBRARY_NAME_SUFFIX := p$(LIBRARY_NAME_SUFFIX)
endif

ifeq ($(debug), yes)
ADDITIONAL_FLAGS += -g
OBJ_DIR_PREFIX += debug_
  LIBRARY_NAME_SUFFIX := d$(LIBRARY_NAME_SUFFIX)
endif

OBJ_DIR_PREFIX += obj

ifneq ($(LIBRARY_NAME_SUFFIX),)
LIBRARY_NAME_SUFFIX := _$(LIBRARY_NAME_SUFFIX)
endif

INTERNAL_OBJCFLAGS += $(ADDITIONAL_FLAGS) $(OPTFLAG) $(OBJCFLAGS) \
			$(RUNTIME_FLAG)
INTERNAL_CFLAGS += $(ADDITIONAL_FLAGS) $(CFLAGS) $(OPTFLAG) $(RUNTIME_FLAG)
INTERNAL_LDFLAGS += $(LDFLAGS)

GNUSTEP_OBJ_PREFIX = $(shell echo $(OBJ_DIR_PREFIX) | sed 's/ //g')
GNUSTEP_OBJ_DIR = $(GNUSTEP_OBJ_PREFIX)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)

# The standard GNUstep directories for finding shared libraries
GNUSTEP_LD_LIB_DIRS=$(GNUSTEP_USER_LIBRARIES):$(GNUSTEP_LOCAL_LIBRARIES):$(GNUSTEP_SYSTEM_LIBRARIES)
