#
#   target.make
#
#   Determine target specific settings
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

#
# Determine the environment variable name used by the dynamic loader
#
LD_LIB_PATH := $(shell $(LD_LIB_PATH_SCRIPT) $(GNUSTEP_HOST_OS))

#
# Host and target specific settings
#
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
X_INCLUDES := $(X_INCLUDES)/X11
endif

#
# Target specific libraries
#
ifeq ($(GNUSTEP_TARGET_OS),linux-gnu)
ifeq ($(GNUSTEP_TARGET_CPU),ix86)
TARGET_SYSTEM_LIBS := -lpcthread -ldl -lm
endif
ifeq ($(GNUSTEP_TARGET_CPU),alpha)
TARGET_SYSTEM_LIBS := -ldl -lm
endif
endif
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
TARGET_SYSTEM_LIBS := -lsocket -lnsl -ldl -lm
endif

#
# Specific settings for building shared libraries, static libraries,
# and bundles on various systems
#
HAVE_SHARED_LIBS = no
STATIC_LIB_LINK_CMD = \
	$(AR) $(ARFLAGS) $(AROUT)$(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^;\
	$(RANLIB) $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE); \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
AFTER_INSTALL_STATIC_LIB_COMMAND = \
	(cd $(GNUSTEP_LIBRARIES); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE); \
	  $(RANLIB) $(GNUSTEP_LIBRARIES)/$(VERSION_LIBRARY_FILE))
SHARED_LIB_LINK_CMD =
SHARED_CFLAGS =
SHARE_LIBEXT =
AFTER_INSTALL_SHARED_LIB_COMMAND = \
	(cd $(GNUSTEP_LIBRARIES); \
	 rm -f $(LIBRARY_FILE); \
	 $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
HAVE_BUNDLES = no


#
# OpenStep 4.x
#
ifeq ($(GNUSTEP_TARGET_OS), nextstep4)
HAVE_BUNDLES            = yes
HAVE_SHARED_LIBS        = yes

ifeq ($(FOUNDATION_LIB),nx)
# Use the NeXT compiler
CC = cc
OBJC_COMPILER = NeXT
endif

TARGET_LIB_DIR = \
    Libraries/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)

ifneq ($(OBJC_COMPILER), NeXT)
SHARED_LIB_LINK_CMD     = \
        /bin/libtool -dynamic -read_only_relocs suppress -o $@ \
		-framework System \
                -L$(GNUSTEP_USER_ROOT)/$(TARGET_LIB_DIR) \
		-L$(GNUSTEP_LOCAL_ROOT)/$(TARGET_LIB_DIR) \
		-L$(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR) \
		$(LIBRARIES_DEPEND_UPON) -lobjc -lgcc $^; \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
else
SHARED_LIB_LINK_CMD     = \
        /bin/libtool -dynamic -read_only_relocs suppress -o $@ \
		-framework System \
                -L$(GNUSTEP_USER_ROOT)/$(TARGET_LIB_DIR) \
		-L$(GNUSTEP_LOCAL_ROOT)/$(TARGET_LIB_DIR) \
		-L$(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR); \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
endif

STATIC_LIB_LINK_CMD	= \
	/bin/libtool -static -o $@ $^; \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

ADDITIONAL_LDFLAGS += -Wl,-read_only_relocs,suppress

AFTER_INSTALL_STATIC_LIB_COMMAND =

SHARED_CFLAGS   += -dynamic
SHARED_LIBEXT   = .a

ifneq ($(OBJC_COMPILER), NeXT)
TARGET_SYSTEM_LIBS += -lgcc
endif

HAVE_BUNDLES    = yes
BUNDLE_CFLAGS   =
endif

#
# Linux ELF
#
ifeq ($(GNUSTEP_TARGET_OS), linux-gnu)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        $(CC) -shared -W,l,soname=$(LIBRARY_FILE) \
           -o $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^ ;\
        (cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS   += -fPIC
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_CFLAGS   += -fPIC
BUNDLE_LDFLAGS  += -shared
endif


#
# Solaris
#
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        $(CC) -G -o $(VERSION_LIBRARY_FILE) $^ ;\
        mv $(VERSION_LIBRARY_FILE) $(GNUSTEP_OBJ_DIR) ;\
        (cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS     += -fpic -fPIC
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_CFLAGS   += -fPIC
BUNDLE_LDFLAGS  += -shared
endif
