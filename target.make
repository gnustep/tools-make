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
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -ldl -lm
endif
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
  ifeq ($(objc_threaded),1)
    INTERNAL_CFLAGS = -D_REENTRANT
    INTERNAL_OBJCFLAGS = -D_REENTRANT
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lthread -lsocket -lnsl -ldl -lm
  else
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lsocket -lnsl -ldl -lm
  endif
endif
ifeq ($(findstring irix, $(GNUSTEP_TARGET_OS)), irix)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring hpux, $(GNUSTEP_TARGET_OS)), hpux)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif

#
# Specific settings for building shared libraries, static libraries,
# and bundles on various systems
#
HAVE_SHARED_LIBS = no
STATIC_LIB_LINK_CMD = \
	$(AR) $(ARFLAGS) $(AROUT)$(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^;\
	$(RANLIB) $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE)
AFTER_INSTALL_STATIC_LIB_COMMAND = \
	(cd $(GNUSTEP_LIBRARIES); $(RANLIB) $(VERSION_LIBRARY_FILE))
SHARED_LIB_LINK_CMD =
SHARED_CFLAGS =
SHARE_LIBEXT =
AFTER_INSTALL_SHARED_LIB_COMMAND = \
	(cd $(GNUSTEP_LIBRARIES); \
	 rm -f $(LIBRARY_FILE); \
	 $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
HAVE_BUNDLES = no

####################################################
#
# Start of system specific settings
#
####################################################

####################################################
#
# OpenStep 4.x
#
ifeq ($(GNUSTEP_TARGET_OS), nextstep4)
ifeq ($(OBJC_RUNTIME), NeXT)
HAVE_BUNDLES            = yes
endif

HAVE_SHARED_LIBS        = yes

ifeq ($(FOUNDATION_LIB),nx)
  # Use the NeXT compiler
  CC = cc
  OBJC_COMPILER = NeXT
  ifneq ($(arch),)
    ARCH_FLAGS = $(foreach a, $(arch), -arch $(a))
    INTERNAL_OBJCFLAGS += $(ARCH_FLAGS)
    INTERNAL_CFLAGS += $(ARCH_FLAGS)
    INTERNAL_LDFLAGS += $(ARCH_FLAGS)
  endif
endif

TARGET_LIB_DIR = \
    Libraries/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)

ifneq ($(OBJC_COMPILER), NeXT)
SHARED_LIB_LINK_CMD     = \
	/bin/libtool -dynamic -read_only_relocs suppress $(ARCH_FLAGS) \
		-install_name $(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIBRARY_FILE) -o $@ \
		-framework System \
		$(ALL_LIB_DIRS) \
		$(LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		-lobjc -lgcc $^; \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
else
SHARED_LIB_LINK_CMD     = \
        /bin/libtool -dynamic -read_only_relocs suppress $(ARCH_FLAGS) \
		-install_name $(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIBRARY_FILE) $(ALL_LDFLAGS) $@ \
		-framework System \
		$(ALL_LIB_DIRS) $(LIBRARIES_DEPEND_UPON) \
		$(LIBRARIES_FOUNDATION_DEPEND_UPON) $^; \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
endif

STATIC_LIB_LINK_CMD	= \
	/bin/libtool -static $(ARCH_FLAGS) -o $@ $^

# This doesn't work with 4.1, what about others?
#ADDITIONAL_LDFLAGS += -Wl,-read_only_relocs,suppress

AFTER_INSTALL_STATIC_LIB_COMMAND =

SHARED_CFLAGS   += -dynamic
SHARED_LIBEXT   = .a

ifneq ($(OBJC_COMPILER), NeXT)
TARGET_SYSTEM_LIBS += $(CONFIG_SYSTEM_LIBS) -lgcc
endif

BUNDLE_LD	= ld
BUNDLE_CFLAGS   +=
BUNDLE_LDFLAGS  += -r $(ARCH_FLAGS)
endif
#
# end OpenStep 4.x
#
####################################################

####################################################
#
# NEXTSTEP 3.x
#
ifeq ($(GNUSTEP_TARGET_OS), nextstep3)
ifeq ($(OBJC_RUNTIME), NeXT)
HAVE_BUNDLES            = yes
endif

HAVE_SHARED_LIBS        = yes

ifeq ($(FOUNDATION_LIB),nx)
  # Use the NeXT compiler
  CC = cc
  OBJC_COMPILER = NeXT
  ifneq ($(arch),)
    ARCH_FLAGS = $(foreach a, $(arch), -arch $(a))
    INTERNAL_OBJCFLAGS += $(ARCH_FLAGS)
    INTERNAL_CFLAGS += $(ARCH_FLAGS)
    INTERNAL_LDFLAGS += $(ARCH_FLAGS)
  endif
endif

TARGET_LIB_DIR = \
    Libraries/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)

ifneq ($(OBJC_COMPILER), NeXT)
SHARED_LIB_LINK_CMD     = \
        /bin/libtool -dynamic -read_only_relocs suppress
		 $(ARCH_FLAGS) -o $@ -framework System \
		$(GNUSTEP_USER_TARGET_LIBRARIES_FLAG) \
		$(GNUSTEP_LOCAL_TARGET_LIBRARIES_FLAG) \
		-L$(GNUSTEP_SYSTEM_TARGET_LIBRARIES) \
		$(ADDITIONAL_LIB_DIRS) \
		$(LIBRARIES_DEPEND_UPON) -lobjc -lgcc -undefined warning $^; \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
else
SHARED_LIB_LINK_CMD     = \
        /bin/libtool -dynamic -read_only_relocs suppress $(ARCH_FLAGS) -o $@ \
		-framework System \
		$(GNUSTEP_USER_TARGET_LIBRARIES_FLAG) \
		$(GNUSTEP_LOCAL_TARGET_LIBRARIES_FLAG) \
		-L$(GNUSTEP_SYSTEM_TARGET_LIBRARIES) \
		$(ADDITIONAL_LIB_DIRS) $(LIBRARIES_DEPEND_UPON) $^; \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
endif

STATIC_LIB_LINK_CMD	= \
	/bin/libtool -static $(ARCH_FLAGS) -o $@ $^

ADDITIONAL_LDFLAGS += -Wl,-read_only_relocs,suppress

AFTER_INSTALL_STATIC_LIB_COMMAND =

SHARED_CFLAGS   += -dynamic
SHARED_LIBEXT   = .a

ifneq ($(OBJC_COMPILER), NeXT)
TARGET_SYSTEM_LIBS += $(CONFIG_SYSTEM_LIBS) -lgcc
endif

BUNDLE_LD	= ld
BUNDLE_CFLAGS   +=
BUNDLE_LDFLAGS  += -r $(ARCH_FLAGS)
endif
#
# end NEXTSTEP 3.x
#
####################################################

####################################################
#
# Linux ELF
#
ifeq ($(GNUSTEP_TARGET_OS), linux-gnu)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        $(CC) -shared -Wl,-soname,$(VERSION_LIBRARY_FILE) \
           -o $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^ ;\
        (cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS   += -fPIC
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_LD	= gcc
BUNDLE_CFLAGS   += -fPIC
BUNDLE_LDFLAGS  += -shared
endif
#
# end Linux ELF
#
####################################################


####################################################
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
BUNDLE_LD	= gcc
BUNDLE_CFLAGS   += -fPIC
#BUNDLE_LDFLAGS  += -shared -mimpure-text
BUNDLE_LDFLAGS  += -nodefaultlibs -Xlinker -r
endif

# end Solaris
#
####################################################


####################################################
#
# Unixware
#
ifeq ($(findstring sysv4.2, $(GNUSTEP_TARGET_OS)), sysv4.2)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        $(CC) -shared -o $(VERSION_LIBRARY_FILE) $^ ;\
        mv $(VERSION_LIBRARY_FILE) $(GNUSTEP_OBJ_DIR) ;\
        (cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS     += -fpic -fPIC
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_LD       = gcc
BUNDLE_CFLAGS   += -fPIC
#BUNDLE_LDFLAGS  += -shared -mimpure-text
BUNDLE_LDFLAGS  += -nodefaultlibs -Xlinker -r
endif

# end Unixware
#
####################################################


####################################################
#
# HP-UX 
#
ifeq ($(findstring hpux, $(GNUSTEP_TARGET_OS)), hpux)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        (cd $(GNUSTEP_OBJ_DIR); $(CC) -v $(SHARED_CFLAGS) -shared -o $(VERSION_LIBRARY_FILE) `ls -1 *\.o */*\.o` ;\
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS     += -fPIC
SHARED_LIBEXT   = .sl

HAVE_BUNDLES    = yes
BUNDLE_LD	= gcc
BUNDLE_CFLAGS   += -fPIC
BUNDLE_LDFLAGS  += -nodefaultlibs -Xlinker -r
endif

# end HP-UX
#
####################################################


## Local variables:
## mode: makefile
## End:

