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

ifndef library_combo
  ifdef LIBRARY_COMBO
    library_combo:=$(LIBRARY_COMBO)
  endif
endif
ifdef library_combo
  the_library_combo=$(library_combo)
else
  the_library_combo=$(default_library_combo)
endif

ifeq ($(library_combo),nx)
  the_library_combo=nx-nx-nx-nil
endif

ifeq ($(library_combo),gnu-xdps)
  the_library_combo=gnu-gnu-gnu-xdps
endif

ifeq ($(library_combo),fd-xdps)
  the_library_combo=gnu-fd-gnu-xdps
endif

ifeq ($(library_combo),gnu-xraw)
  the_library_combo=gnu-gnu-gnu-xraw
endif

ifeq ($(library_combo),fd-xraw)
  the_library_combo=gnu-fd-gnu-xraw
endif

ifeq ($(the_library_combo),)
  the_library_combo=$(library_combo)
endif

ifeq ($(gc), yes)
  the_library_combo := $(the_library_combo)-gc
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

ifeq ($(gc), yes)
  export LIBRARY_COMBO = $(OBJC_RUNTIME_LIB)-$(FOUNDATION_LIB)-$(GUI_LIB)-$(GUI_BACKEND_LIB)-gc
else
  export LIBRARY_COMBO = $(OBJC_RUNTIME_LIB)-$(FOUNDATION_LIB)-$(GUI_LIB)-$(GUI_BACKEND_LIB)
endif

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

#
# Third-party foundations not using make package
# Our own foundation will install a base.make file into 
# $GNUSTEP_MAKEFILES/Additional/ to set the needed flags
#
ifeq ($(FOUNDATION_LIB),nx)
  FND_LDFLAGS = -framework Foundation
  FND_LIBS   = 
  FND_DEFINE = -DNeXT_Foundation_LIBRARY=1
endif

ifeq ($(FOUNDATION_LIB), sun)
  FND_DEFINE = -DSun_Foundation_LIBRARY=1
endif

#
# FIXME - Ask Helge to move this inside his libFoundation, and have 
# it installed as a $(GNUSTEP_MAKEFILES)/Additional/libFoundation.make
#
ifeq ($(FOUNDATION_LIB),fd)
  -include $(GNUSTEP_MAKEFILES)/libFoundation.make

  FND_DEFINE = -DLIB_FOUNDATION_LIBRARY=1
  FND_LDFLAGS =
  FND_LIBS = -lFoundation

  # If gc=yes was passed and libFoundation was compiled with Boehm's
  # GC support, use the appropriate libraries

  ifeq ($(gc), yes)
    ifeq ($(LIBFOUNDATION_WITH_GC), yes)
      OBJC_LIBS = -lobjc $(LIBFOUNDATION_GC_LIBRARY)
      ifeq ($(leak), yes)
        AUXILIARY_CPPFLAGS += -DLIB_FOUNDATION_LEAK_GC=1
      else
        AUXILIARY_CPPFLAGS += -DLIB_FOUNDATION_BOEHM_GC=1
      endif
    endif
  endif

endif

#
# Set the WO library flags
#

#
# FIXME - Move these flags into gnustepweb, installing them inside 
# $(GNUSTEP_MAKEFILES)/Additional/gnustepweb.make
#
WO_LDFLAGS =
WO_LIBS    = -lNGObjWeb -lNGHttp -lNGMime -lNGZlib \
	     -lNGNet -lNGStreams -lNGExtensions
WO_DEFINE  = -DNGObjWeb_LIBRARY=1


GUI_LDFLAGS =
GUI_LIBS = 
#
# Third-party GUI libraries - our own sets its flags into 
# $(GNUSTEP_MAKEFILES)/Additional/gui.make
#
ifeq ($(GUI_LIB),nx)
  GUI_DEFINE = -DNeXT_GUI_LIBRARY=1
  ifneq ($(INTERNAL_app_NAME),)
    # If we're building an application pass the following additional flags to
    # the linker
    GUI_LDFLAGS = -sectcreate __ICON __header $(INTERNAL_app_NAME).iconheader \
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

SYSTEM_INCLUDES = $(CONFIG_SYSTEM_INCL)
SYSTEM_LDFLAGS = 
SYSTEM_LIB_DIR =
SYSTEM_LIBS =

#
# FIXME - when we have a win32 backend, move these flags inside 
# $(GNUSTEP_MAKEFILES)/Additional/win32.make and have them managed 
# by the win32 backend directly
#
ifeq ($(GUI_BACKEND_LIB),w32)
  BACKEND_LDFLAGS =
  BACKEND_LIBS = -lMBKit
endif
#
# If the backend GUI library is Win32 based
# then add Win32 headers and libraries
#
ifeq ($(GUI_BACKEND_LIB),w32)
  SYSTEM_INCLUDES = $(CONFIG_SYSTEM_INCL)
  SYSTEM_LDFLAGS = 
  SYSTEM_LIB_DIR =
  SYSTEM_LIBS = -ltiff -lwsock32 -ladvapi32 -lcomctl32 -luser32 \
   -lgdi32 -lcomdlg32
endif

## Local variables:
## mode: makefile
## End:
