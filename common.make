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

#
# Get the config information
#
include $(GNUSTEP_ROOT)/Makefiles/config.make

#
# Determine the compilation target
#
include $(GNUSTEP_ROOT)/Makefiles/target.make

#
# Determine the core libraries
#
include $(GNUSTEP_ROOT)/Makefiles/core.make

#
# Variables specifying the installation directory paths
#
GNUSTEP_HOST_DIR = $(GNUSTEP_HOST_CPU)/$(GNUSTEP_HOST_OS)
GNUSTEP_TARGET_DIR = $(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)
GNUSTEP_APPS = $(GNUSTEP_ROOT)/Apps
GNUSTEP_TOOLS = $(GNUSTEP_ROOT)/Tools
GNUSTEP_HEADERS_ROOT = $(GNUSTEP_ROOT)/Headers
GNUSTEP_LIBRARIES_ROOT = $(GNUSTEP_ROOT)/Libraries
GNUSTEP_LIBRARIES = $(GNUSTEP_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)
GNUSTEP_MAKEFILES = $(GNUSTEP_ROOT)/Makefiles

#
# Determine header subdirectory based upon library combo
#
SUB_HEADER =

ifeq ($(FOUNDATION_LIB),gnu)

SUB_HEADER = /gnustep

endif

ifeq ($(FOUNDATION_LIB),fd)

SUB_HEADER = /libFoundation

endif

GNUSTEP_HEADERS = $(GNUSTEP_HEADERS_ROOT)$(SUB_HEADER)
