#
#   brain.make
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

# Handle abbreviations for library combinations
ifeq ($(library_combo),nx)
  the_library_combo=nx-nx-nx-nil
endif

ifeq ($(library_combo),gnu-xdps)
  the_library_combo=gnu-gnu-gnu-xdps
endif

ifeq ($(library_combo),fd-xdps)
  the_library_combo=gnu-fd-gnu-xdps
endif

ifeq ($(the_library_combo),)
  the_library_combo=$(library_combo)
endif


# Strip out the individual libraries from the combo string
combo_list = $(subst -, ,$(the_library_combo))
OBJC_RUNTIME_LIB = $(word 1,$(combo_list))
FOUNDATION_LIB = $(word 2,$(combo_list))
GUI_LIB = $(word 3,$(combo_list))
GUI_BACKEND_LIB = $(word 4,$(combo_list))

#
# Allow user specify the runtime, foundation, gui and backend libraries in
# separate variables.
#
ifneq ($(runtime),)
OBJC_RUNTIME_LIB = $(runtime)
endif

ifneq ($(foundation),)
FOUNDATION_LIB = $(foundation)
endif

ifneq ($(gui),)
GUI_LIB = $(gui)
endif

ifneq ($(backend),)
GUI_BACKEND_LIB = $(backend)
endif

export LIBRARY_COMBO = $(OBJC_RUNTIME_LIB)-$(FOUNDATION_LIB)-$(GUI_LIB)-$(GUI_BACKEND_LIB)

OBJC_LDFLAGS =
OBJC_LIBS =
#
# Set the appropriate ObjC runtime library and other information
#
ifeq ($(OBJC_RUNTIME_LIB), gnu)
OBJC_LDFLAGS =
OBJC_LIB_DIR =
OBJC_LIBS = -lobjc
OBJC_RUNTIME = GNU
RUNTIME_DEFINE = -DGNU_RUNTIME=1
endif

ifeq ($(OBJC_RUNTIME_LIB), nx)
OBJC_RUNTIME = NeXT
RUNTIME_DEFINE = -DNeXT_RUNTIME=1
endif

ifeq ($(OBJC_RUNTIME_LIB), sun)
OBJC_RUNTIME = Sun
RUNTIME_DEFINE = -DSun_RUNTIME=1
endif

FND_LDFLAGS =
FND_LIBS =
#
# Set the appropriate Foundation library
#
ifeq ($(FOUNDATION_LIB),gnu)
FND_LDFLAGS =
FND_LIBS = -lgnustep-base
FND_DEFINE = -DGNUSTEP_BASE_LIBRARY=1
endif

ifeq ($(FOUNDATION_LIB),fd)
FND_LDFLAGS =
FND_LIBS = -lFoundation
FND_DEFINE = -DLIB_FOUNDATION_LIBRARY=1
endif

ifeq ($(FOUNDATION_LIB),nx)
FND_LDFLAGS = -framework Foundation
FND_LIBS =
endif

ifeq ($(FOUNDATION_LIB), nx)
FND_DEFINE = -DNeXT_Foundation_LIBRARY=1
endif

ifeq ($(FOUNDATION_LIB), sun)
FND_DEFINE = -DSun_Foundation_LIBRARY=1
endif

GUI_LDFLAGS =
GUI_LIBS = 
#
# Set the GUI library
#
ifeq ($(GUI_LIB),gnu)
GUI_LDFLAGS =
GUI_LIBS = -lgnustep-gui
endif

ifeq ($(GUI_LIB),nx)
  ifneq ($(INTERNAL_APP_NAME),)
    # If we're building an application pass the following additional flags to
    # the linker
    GUI_LDFLAGS = -sectcreate __ICON __header $(INTERNAL_APP_NAME).iconheader \
		  -segprot __ICON r r -sectcreate __ICON app /NextLibrary/Frameworks/AppKit.framework/Resources/NSDefaultApplicationIcon.tiff \
		-framework AppKit
    GUI_LIBS =

  endif
endif

BACKEND_LDFLAGS =
BACKEND_LIBS =
#
# Set the GUI Backend library
#
ifeq ($(GUI_BACKEND_LIB),xdps)
BACKEND_LDFLAGS =
BACKEND_LIBS = -lgnustep-xdps
endif

ifeq ($(GUI_BACKEND_LIB),w32)
BACKEND_LDFLAGS =
BACKEND_LIBS = -lMBKit
endif

SYSTEM_INCLUDES =
SYSTEM_LDFLAGS = 
SYSTEM_LIB_DIR =
SYSTEM_LIBS =
#
# If the backend GUI library is X based
# then add X headers and libraries
#
ifeq ($(GUI_BACKEND_LIB),xdps)
SYSTEM_INCLUDES = $(X_INCLUDE)
SYSTEM_LDFLAGS =
SYSTEM_LIB_DIR = $(X_LIBS)
SYSTEM_LIBS = -ltiff -ldpstk -ldps -lpsres -lX11
endif

#
# If the backend GUI library is Win32 based
# then add Win32 headers and libraries
#
ifeq ($(GUI_BACKEND_LIB),w32)
SYSTEM_INCLUDES =
SYSTEM_LDFLAGS = 
SYSTEM_LIB_DIR =
SYSTEM_LIBS = -ltiff -lwsock32 -ladvapi32 -lcomctl32 -luser32 \
   -lgdi32 -lcomdlg32
endif
