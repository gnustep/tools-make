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
  the_library_combo=nx-nx-nx
endif

ifeq ($(library_combo),gnu)
  the_library_combo=gnu-gnu-gnu
endif

ifeq ($(library_combo),fd)
  the_library_combo=gnu-fd-gnu
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

ifeq ($(gc), yes)
  export LIBRARY_COMBO = $(OBJC_RUNTIME_LIB)-$(FOUNDATION_LIB)-$(GUI_LIB)-gc
else
  export LIBRARY_COMBO = $(OBJC_RUNTIME_LIB)-$(FOUNDATION_LIB)-$(GUI_LIB)
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
  ifeq ($(FOUNDATION_LIB),gnu)
    OBJC_LIBS=-lobjc
  endif
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

SYSTEM_INCLUDES = $(CONFIG_SYSTEM_INCL)
SYSTEM_LDFLAGS = 
SYSTEM_LIB_DIR =
SYSTEM_LIBS =

## Local variables:
## mode: makefile
## End:
