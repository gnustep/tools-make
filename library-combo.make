#
#   library-combo.make
#
#   Determine which runtime, foundation and gui library to use.
#
#   Copyright (C) 1997, 2001 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Nicola Pero <n.pero@mi.flashnet.it>
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

# Get library_combo from LIBRARY_COMBO or default_library_combo (or
# from the command line if the user defined it on the command line by
# invoking `make library_combo=gnu-gnu-gnu'; command line
# automatically takes the precedence over makefile definitions, so
# setting library_combo here has no effect if the user already defined
# it on the command line).
ifdef LIBRARY_COMBO
  library_combo := $(LIBRARY_COMBO)
else
  library_combo := $(default_library_combo)
endif

# Handle abbreviations for library combinations.
the_library_combo = $(library_combo)

ifeq ($(the_library_combo), nx)
  the_library_combo = nx-nx-nx
endif

ifeq ($(the_library_combo), gnu)
  the_library_combo = gnu-gnu-gnu
endif

ifeq ($(the_library_combo), fd)
  the_library_combo = gnu-fd-gnu
endif

# Strip out the individual libraries from the library_combo string
combo_list = $(subst -, ,$(the_library_combo))

# NB: The user can always specify any of the OBJC_RUNTIME_LIB, the
# FOUNDATION_LIB and the GUI_LIB variable manually overriding our
# determination.

ifeq ($(OBJC_RUNTIME_LIB),)
  OBJC_RUNTIME_LIB = $(word 1,$(combo_list))
endif

ifeq ($(FOUNDATION_LIB),)
  FOUNDATION_LIB = $(word 2,$(combo_list))
endif

ifeq ($(GUI_LIB),)
  GUI_LIB = $(word 3,$(combo_list))
endif

# Now build and export the final LIBRARY_COMBO variable, which is the
# only variable (together with OBJC_RUNTIME_LIB, FOUNDATION_LIB and
# GUI_LIB) the other makefiles need to know about.  This LIBRARY_COMBO
# might be different from the original one, because we might have
# replaced it with a library_combo provided on the command line, or we
# might have fixed up parts of it in accordance to some custom
# OBJC_RUNTIME_LIB, FOUNDATION_LIB and/or GUI_LIB !
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
