#
#   jni.make
#
#   Makefile to include to compile JNI code.
#
#   Copyright (C) 2000 Free Software Foundation, Inc.
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

#
# Include this file if you need to compile JNI code. 
# This files simply adds automatically the compiler flags to find the
# jni headers.
#

# prevent multiple inclusions
ifeq ($(JNI_MAKE_LOADED),)
JNI_MAKE_LOADED=yes

# Default
JAVA_OS = linux

# Solaris
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
  JAVA_OS = solaris
endif

# Windows
ifeq ($(findstring mingw32, $(GNUSTEP_TARGET_OS)), mingw32)
  JAVA_OS = win32
endif

# Add more platforms here

#
# This should be where your jni.h and jni_md.h are located.
#
JNI_INCLUDE_HEADERS = -I$(JAVA_HOME)/include/ \
                      -I$(JAVA_HOME)/include/$(JAVA_OS) 

ADDITIONAL_INCLUDE_DIRS += $(JNI_INCLUDE_HEADERS)

endif # jni.make loaded
