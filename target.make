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

# This file should not contain any conditional based on the value of
# the 'shared' variable, because we have not set it up yet when this
# file is processed!

#
# Host and target specific settings
#
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
X_INCLUDES := $(X_INCLUDES)/X11
endif

#
# Target specific libraries
#
TARGET_SYSTEM_LIBS = $(CONFIG_SYSTEM_LIBS)

ifeq ($(findstring mingw32, $(GNUSTEP_TARGET_OS)), mingw32)
  TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) \
	-lws2_32 -ladvapi32 -lcomctl32 -luser32 -lcomdlg32 \
	-lmpr -lnetapi32 -lm -I. # the -I is a dummy to avoid -lm^M
endif
ifeq ($(findstring cygwin, $(GNUSTEP_TARGET_OS)), cygwin)
  TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm -I. 
endif
ifeq ($(GNUSTEP_TARGET_OS),linux-gnu)
  ifeq ("$(objc_threaded)","")
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -ldl -lm
  else
    INTERNAL_CFLAGS = -D_REENTRANT
    INTERNAL_OBJCFLAGS = -D_REENTRANT
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) $(objc_threaded) -ldl -lm
  endif
endif
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
  ifeq ("$(objc_threaded)","")
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lsocket -lnsl -ldl -lm
  else
    INTERNAL_CFLAGS    = -D_REENTRANT
    INTERNAL_OBJCFLAGS = -D_REENTRANT
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) $(objc_threaded) -lsocket -lnsl -ldl -lm
  endif
endif
ifeq ($(findstring irix, $(GNUSTEP_TARGET_OS)), irix)
  ifeq ("$(objc_threaded)","")
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
  else
    INTERNAL_CFLAGS = -D_REENTRANT
    INTERNAL_OBJCFLAGS = -D_REENTRANT
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) $(objc_threaded) -lm
  endif
endif
ifeq ($(findstring hpux, $(GNUSTEP_TARGET_OS)), hpux)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring sysv4.2, $(GNUSTEP_TARGET_OS)), sysv4.2)
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lsocket -lnsl -ldl -lm
endif
ifeq ($(findstring aix4.1, $(GNUSTEP_TARGET_OS)), aix4.1)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring freebsd, $(GNUSTEP_TARGET_OS)), freebsd)
  ifeq ("$(objc_threaded)","")
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
  else
    INTERNAL_CFLAGS = -D_REENTRANT
    INTERNAL_OBJCFLAGS = -D_REENTRANT
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) $(objc_threaded) -lm
  endif
endif
ifeq ($(findstring netbsd, $(GNUSTEP_TARGET_OS)), netbsd)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring openbsd, $(GNUSTEP_TARGET_OS)), openbsd)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring osf, $(GNUSTEP_TARGET_OS)), osf)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif

#
# Specific settings for building shared libraries, static libraries,
# and bundles on various systems
#

#
# For each target, a few target-specific variables need to be set.
#
# The first one is SHARED_LIB_LINK_CMD - which should be set to the
# command(s) to use to link a shared library on that platform.  Please
# note that the variables (stuff like $(CC)) in it are not expanded
# until SHARED_LIB_LINK_CMD is actually used (STATIC_LIB_LINK_CMD is
# the equivalent variable, used for static libraries).
#
# SHARED_LIB_LINK_CMD will be used to link standard shared libraries,
# and frameworks.  It should use the following variables (which are set
# by library.make or framework.make before executing
# SHARED_LIB_LINK_CMD) to refer to what it needs to link (please note
# that STATIC_LIB_LINK_CMD will also use these variables with similar
# meanings; but not all of them, as noted):
#
#  LIB_LINK_OBJ_DIR: where the newly created library should be. 
#    Usually GNUSTEP_OBJ_DIR for libraries, and FRAMEWORK_LIBRARY_DIR_NAME 
#    for frameworks.
#  LIB_LINK_VERSION_FILE: the final file to create, having full
#     version information: typically `libgnustep-base.so.1.5.3' for shared
#     libraries, and `libgnustep-base.a' for static libraries.
#  LIB_LINK_SONAME_FILE: this is only used for shared libraries; it 
#    should be passed in the -Wl,-soname argument of most linkers when 
#    building the LIB_LINK_VERSION_FILE. Typically `libgnustep-base.so.1' 
#    (but might also be `libgnustep-base.so.1.0' if SOVERSION has been 
#    manually changed when using library.make).  On many platforms, 
#    it's appropriate/standard to also create this file as a symlink to 
#    LIB_LINK_VERSION_FILE.
#  LIB_LINK_FILE: this is only used for shared libraries; it should
#    be created as a symlink to LIB_LINK_VERSION_FILE (or to 
#    LIB_LINK_SONAME_FILE if it's created on that platform).
#    Typically `libgnustep-base.so'.
#
# AFTER_INSTALL_SHARED_LIB_CMD provides commands to be executed after
# installation (at least for libraries, not for frameworks at the
# moment), and is supposed to setup symlinks properly in the
# installation directory.  It uses the same variables, except for
# LIB_LINK_INSTALL_DIR which is the full final path to where the
# library (and symlinks) is going to be installed.
#
# AFTER_INSTALL_STATIC_LIB_CMD is similar.
#

#
# This is the generic version - if the target is not in the following list,
# this setup will be used.  It the target does not override variables here
# with its own version, these generic definitions will be used.
#
HAVE_SHARED_LIBS = no
STATIC_LIB_LINK_CMD = \
	$(AR) $(ARFLAGS) $(AROUT)$(LIB_LINK_OBJ_DIR)/$(LIB_LINK_VERSION_FILE) $^;\
	$(RANLIB) $(LIB_LINK_OBJ_DIR)/$(LIB_LINK_VERSION_FILE)
AFTER_INSTALL_STATIC_LIB_CMD = \
	(cd $(LIB_LINK_INSTALL_DIR); \
	$(RANLIB) $(LIB_LINK_VERSION_FILE))
SHARED_LIB_LINK_CMD =
SHARED_CFLAGS =
SHARED_LIBEXT =
AFTER_INSTALL_SHARED_LIB_CMD = \
	(cd $(LIB_LINK_INSTALL_DIR); \
	 rm -f $(LIB_LINK_FILE); \
	 $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))
AFTER_INSTALL_SHARED_LIB_CHOWN = \
	(cd $(LIB_LINK_INSTALL_DIR); \
	chown $(CHOWN_TO) $(LIB_LINK_FILE))
HAVE_BUNDLES = no

####################################################
#
# Start of system specific settings
#
####################################################

####################################################
#
# MacOSX-Server 1.0
#
ifeq ($(findstring rhapsody5, $(GNUSTEP_TARGET_OS)), rhapsody5)
ifeq ($(OBJC_RUNTIME), NeXT)
HAVE_BUNDLES     = yes
endif

HAVE_SHARED_LIBS = yes
SHARED_LIBEXT    = .dylib

ifeq ($(FOUNDATION_LIB),nx)
  # Use the NeXT compiler
  CC = cc
  OBJC_COMPILER = NeXT
  ifneq ($(arch),)
    ARCH_FLAGS = $(foreach a, $(arch), -arch $(a))
    INTERNAL_OBJCFLAGS += $(ARCH_FLAGS)
    INTERNAL_CFLAGS    += $(ARCH_FLAGS)
    INTERNAL_LDFLAGS   += $(ARCH_FLAGS)
  endif
endif

TARGET_LIB_DIR = \
    Libraries/$(GNUSTEP_TARGET_LDIR)

ifneq ($(OBJC_COMPILER), NeXT)
SHARED_LIB_LINK_CMD     = \
	$(CC) $(SHARED_LD_PREFLAGS) \
		-dynamiclib $(ARCH_FLAGS) -dynamic \
		-compatibility_version 1 -current_version 1 \
		-install_name $(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIB_LINK_FILE) \
		-o $@ \
		-framework Foundation \
		-framework System \
		$(INTERNAL_LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		-lobjc -lgcc $^ $(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))
else # OBJC_COMPILER=NeXT
SHARED_LIB_LINK_CMD     = \
	$(CC) $(SHARED_LD_PREFLAGS) \
		-dynamiclib $(ARCH_FLAGS) -dynamic \
		-compatibility_version 1 -current_version 1 \
		-read_only_relocs warning -undefined warning \
		-install_name $(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIB_LINK_FILE) \
		-o $@ \
		$(INTERNAL_LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		-framework Foundation \
		$^ $(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))
endif # OBJC_COMPILER

OBJ_MERGE_CMD = \
	$(CC) -nostdlib -r -d -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

STATIC_LIB_LINK_CMD	= \
	/usr/bin/libtool $(STATIC_LD_PREFLAGS) -static $(ARCH_FLAGS) -o $@ $^ \
	$(STATIC_LD_POSTFLAGS)

# This doesn't work with 4.1, what about others?
#ADDITIONAL_LDFLAGS += -Wl,-read_only_relocs,suppress

AFTER_INSTALL_STATIC_LIB_CMD =

SHARED_CFLAGS   += -dynamic
SHARED_LIBEXT   = .dylib

BUNDLE_LD	=  $(CC)
BUNDLE_LDFLAGS  += -bundle -undefined suppress $(ARCH_FLAGS)
endif
#
# end MacOSX-Server 1.0
#
####################################################

####################################################
#
# MacOSX public beta, darwin1.x
#
ifeq ($(findstring darwin1, $(GNUSTEP_TARGET_OS)), darwin1)
ifeq ($(OBJC_RUNTIME), NeXT)
  HAVE_BUNDLES     = yes
  # Use the NeXT compiler
  INTERNAL_OBJCFLAGS += -traditional-cpp
  OBJC_COMPILER = NeXT
endif

HAVE_SHARED_LIBS = yes
SHARED_LIBEXT    = .dylib

ifeq ($(FOUNDATION_LIB),nx)
  ifneq ($(arch),)
    ARCH_FLAGS = $(foreach a, $(arch), -arch $(a))
    INTERNAL_OBJCFLAGS += $(ARCH_FLAGS)
    INTERNAL_CFLAGS    += $(ARCH_FLAGS)
    INTERNAL_LDFLAGS   += $(ARCH_FLAGS)
  endif
endif

TARGET_LIB_DIR = \
Libraries/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)

DYLIB_COMPATIBILITY_VERSION = -compatibility_version 1
DYLIB_CURRENT_VERSION       = -current_version 1
DYLIB_INSTALL_NAME = \
$(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIB_LINK_FILE)

ifeq ($(FOUNDATION_LIB),nx)
DYLIB_DEF_FRAMEWORKS += -framework Foundation
endif

ifneq ($(OBJC_COMPILER), NeXT)
# GNU compiler

DYLIB_DEF_FRAMEWORKS += -framework System

SHARED_LIB_LINK_CMD     = \
	$(CC) $(SHARED_LD_PREFLAGS) \
		-dynamiclib $(ARCH_FLAGS) -dynamic	\
		$(DYLIB_COMPATIBILITY_VERSION)		\
		$(DYLIB_CURRENT_VERSION)		\
		-install_name $(DYLIB_INSTALL_NAME)	\
		-o $@					\
		$(DYLIB_DEF_FRAMEWORKS)			\
		$(INTERNAL_LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		-lobjc $^ $(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))

else # OBJC_COMPILER=NeXT

DYLIB_EXTRA_FLAGS    = -read_only_relocs warning -undefined warning -fno-common
DYLIB_DEF_FRAMEWORKS += #-framework Foundation
DYLIB_DEF_LIBS	     = -lobjc

SHARED_LIB_LINK_CMD     = \
	$(CC) $(SHARED_LD_PREFLAGS) \
		-dynamiclib $(ARCH_FLAGS) -dynamic	\
		$(DYLIB_COMPATIBILITY_VERSION)		\
		$(DYLIB_CURRENT_VERSION)		\
		$(DYLIB_EXTRA_FLAGS)			\
		-install_name $(DYLIB_INSTALL_NAME)	\
		-o $@					\
		$(INTERNAL_LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		$(DYLIB_DEF_FRAMEWORKS)			\
		$(DYLIB_DEF_LIBS)			\
		$^ $(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))
endif # OBJC_COMPILER

OBJ_MERGE_CMD = \
	$(CC) -nostdlib -r -d -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

STATIC_LIB_LINK_CMD	= \
	/usr/bin/libtool $(STATIC_LD_PREFLAGS) -static $(ARCH_FLAGS) -o $@ $^ \
	$(STATIC_LD_POSTFLAGS)

# This doesn't work with 4.1, what about others?
#ADDITIONAL_LDFLAGS += -Wl,-read_only_relocs,suppress

AFTER_INSTALL_STATIC_LIB_CMD =

SHARED_CFLAGS   += -dynamic -fno-common
SHARED_LIBEXT   = .dylib

BUNDLE_LD	=  $(CC)
BUNDLE_LDFLAGS  += -bundle -undefined suppress $(ARCH_FLAGS)
endif
#
# end MacOSX public beta, darwin1.2
#
####################################################

####################################################
#
# MacOSX 10.1.1, darwin5.1
#
ifeq ($(findstring darwin5, $(GNUSTEP_TARGET_OS)), darwin5)
ifeq ($(OBJC_RUNTIME), NeXT)
  HAVE_BUNDLES     = yes
  OBJC_COMPILER    = NeXT
  # Set flags to ignore the MacOSX headers
  ifneq ($(FOUNDATION_LIB),nx)
    INTERNAL_OBJCFLAGS += -no-cpp-precomp -nostdinc -I/usr/include
  endif
endif

HAVE_SHARED_LIBS = yes
SHARED_LIBEXT    = .dylib

ifeq ($(FOUNDATION_LIB),nx)
  # Use the NeXT compiler
  CC = cc
  INTERNAL_OBJCFLAGS += -traditional-cpp
  ifneq ($(arch),)
    ARCH_FLAGS = $(foreach a, $(arch), -arch $(a))
    INTERNAL_OBJCFLAGS += $(ARCH_FLAGS)
    INTERNAL_CFLAGS    += $(ARCH_FLAGS)
    INTERNAL_LDFLAGS   += $(ARCH_FLAGS)
  endif
endif

TARGET_LIB_DIR = \
Libraries/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)

DYLIB_COMPATIBILITY_VERSION = -compatibility_version 1
DYLIB_CURRENT_VERSION       = -current_version 1
DYLIB_INSTALL_NAME = \
$(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIB_LINK_FILE)

# Remove empty dirs from the compiler/linker flags (ie, remove -Idir and 
# -Ldir flags where dir is empty).
REMOVE_EMPTY_DIRS = yes

ifeq ($(FOUNDATION_LIB),nx)
DYLIB_DEF_FRAMEWORKS += -framework Foundation
endif

ifneq ($(OBJC_COMPILER), NeXT)
# GNU compiler
SHARED_LD_PREFLAGS += -arch_only ppc -noall_load
SHARED_LIB_LINK_CMD     = \
	/usr/bin/libtool -flat_namespace -undefined warning \
		$(SHARED_LD_PREFLAGS) \
		$(ARCH_FLAGS) -dynamic	\
		$(DYLIB_COMPATIBILITY_VERSION)		\
		$(DYLIB_CURRENT_VERSION)		\
		-install_name $(DYLIB_INSTALL_NAME)	\
		-o $@					\
		$(DYLIB_DEF_FRAMEWORKS)			\
		$(INTERNAL_LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		$^ $(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))

HAVE_BUNDLES = no
BUNDLE_LD	=  /usr/bin/ld
BUNDLE_LDFLAGS  += -dynamic -flat_namespace -undefined warning $(ARCH_FLAGS)

else 
# NeXT Compiler

#DYLIB_EXTRA_FLAGS    = -read_only_relocs warning -undefined warning -fno-common

SHARED_LIB_LINK_CMD     = \
	$(CC) $(SHARED_LD_PREFLAGS) \
		-dynamiclib $(ARCH_FLAGS) -dynamic	\
		$(DYLIB_COMPATIBILITY_VERSION)		\
		$(DYLIB_CURRENT_VERSION)		\
		$(DYLIB_EXTRA_FLAGS)			\
		-install_name $(DYLIB_INSTALL_NAME)	\
		-o $@					\
		$(INTERNAL_LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		$^ $(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))

SHARED_CFLAGS   += -dynamic

BUNDLE_LD	=  $(CC)
BUNDLE_LDFLAGS  += -bundle -undefined error $(ARCH_FLAGS)

endif # OBJC_COMPILER

OBJ_MERGE_CMD = \
	$(CC) -nostdlib -r -d -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

STATIC_LIB_LINK_CMD	= \
	/usr/bin/libtool $(STATIC_LD_PREFLAGS) -static $(ARCH_FLAGS) -o $@ $^ \
	$(STATIC_LD_POSTFLAGS)

AFTER_INSTALL_STATIC_LIB_CMD = \
	(cd $(LIB_LINK_INSTALL_DIR); \
	$(RANLIB) $(LIB_LINK_VERSION_FILE))

SHARED_CFLAGS   += -fno-common

endif
#
# end MacOSX 10.1.1, darwin5.1
#
####################################################

####################################################
#
# OpenStep 4.x
#
ifeq ($(GNUSTEP_TARGET_OS), nextstep4)
ifeq ($(OBJC_RUNTIME), NeXT)
  HAVE_BUNDLES            = yes
  OBJC_COMPILER = NeXT
endif

HAVE_SHARED_LIBS        = yes

ifeq ($(FOUNDATION_LIB),nx)
  # Use the NeXT compiler
  CC = cc
  ifneq ($(arch),)
    ARCH_FLAGS = $(foreach a, $(arch), -arch $(a))
    INTERNAL_OBJCFLAGS += $(ARCH_FLAGS)
    INTERNAL_CFLAGS += $(ARCH_FLAGS)
    INTERNAL_LDFLAGS += $(ARCH_FLAGS)
  endif
endif

TARGET_LIB_DIR = \
    Libraries/$(GNUSTEP_TARGET_LDIR)

ifneq ($(OBJC_COMPILER), NeXT)
SHARED_LIB_LINK_CMD     = \
	/bin/libtool $(SHARED_LD_PREFLAGS) \
		-dynamic -read_only_relocs suppress $(ARCH_FLAGS) \
		-install_name $(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIB_LINK_FILE) \
		-o $@ \
		-framework System \
		$(INTERNAL_LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		-lobjc -lgcc $^ $(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))
else
SHARED_LIB_LINK_CMD     = \
        /bin/libtool $(SHARED_LD_PREFLAGS) \
		-dynamic -read_only_relocs suppress $(ARCH_FLAGS) \
		-install_name $(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIB_LINK_FILE) $(ALL_LDFLAGS) $@ \
		-framework System \
		$(INTERNAL_LIBRARIES_DEPEND_UPON) \
		$(LIBRARIES_FOUNDATION_DEPEND_UPON) $^ \
		$(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))
endif

STATIC_LIB_LINK_CMD	= \
	/bin/libtool $(STATIC_LD_PREFLAGS) -static $(ARCH_FLAGS) -o $@ $^ \
	$(STATIC_LD_POSTFLAGS)

# This doesn't work with 4.1, what about others?
#ADDITIONAL_LDFLAGS += -Wl,-read_only_relocs,suppress

AFTER_INSTALL_STATIC_LIB_CMD =

SHARED_CFLAGS   += -dynamic
SHARED_LIBEXT   = .a

BUNDLE_LD	= ld
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
  OBJC_COMPILER = NeXT
endif

HAVE_SHARED_LIBS        = yes

ifeq ($(FOUNDATION_LIB),nx)
  # Use the NeXT compiler
  CC = cc
  ifneq ($(arch),)
    ARCH_FLAGS = $(foreach a, $(arch), -arch $(a))
    INTERNAL_OBJCFLAGS += $(ARCH_FLAGS)
    INTERNAL_CFLAGS += $(ARCH_FLAGS)
    INTERNAL_LDFLAGS += $(ARCH_FLAGS)
  endif
endif

TARGET_LIB_DIR = \
    Libraries/$(GNUSTEP_TARGET_LDIR)

ifneq ($(OBJC_COMPILER), NeXT)
SHARED_LIB_LINK_CMD     = \
        /bin/libtool $(SHARED_LD_PREFLAGS) -dynamic -read_only_relocs suppress \
		 $(ARCH_FLAGS) -o $@ -framework System \
		$(INTERNAL_LIBRARIES_DEPEND_UPON) -lobjc -lgcc -undefined warning $^ \
		$(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))
else
SHARED_LIB_LINK_CMD     = \
        /bin/libtool $(SHARED_LD_PREFLAGS) \
		-dynamic -read_only_relocs suppress $(ARCH_FLAGS) -o $@ \
		-framework System \
		$(INTERNAL_LIBRARIES_DEPEND_UPON) $^ \
		$(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))
endif

STATIC_LIB_LINK_CMD	= \
	/bin/libtool $(STATIC_LD_PREFLAGS) \
	-static $(ARCH_FLAGS) -o $@ $^ $(STATIC_LD_POSTFLAGS)

ADDITIONAL_LDFLAGS += -Wl,-read_only_relocs,suppress

AFTER_INSTALL_STATIC_LIB_CMD =

SHARED_CFLAGS   += -dynamic
SHARED_LIBEXT   = .a

BUNDLE_LD	= ld
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
        $(CC) $(SHARED_LD_PREFLAGS) -shared -Wl,-soname,$(LIB_LINK_SONAME_FILE) \
           -o $(LIB_LINK_OBJ_DIR)/$(LIB_LINK_VERSION_FILE) $^ \
	   $(INTERNAL_LIBRARIES_DEPEND_UPON) \
	   $(SHARED_LD_POSTFLAGS);\
	(cd $(LIB_LINK_OBJ_DIR); \
          rm -f $(LIB_LINK_FILE) $(LIB_LINK_SONAME_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_SONAME_FILE); \
          $(LN_S) $(LIB_LINK_SONAME_FILE) $(LIB_LINK_FILE); \
	)
AFTER_INSTALL_SHARED_LIB_CMD = \
	(cd $(LIB_LINK_INSTALL_DIR); \
          rm -f $(LIB_LINK_FILE) $(LIB_LINK_SONAME_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_SONAME_FILE); \
          $(LN_S) $(LIB_LINK_SONAME_FILE) $(LIB_LINK_FILE); \
	)
AFTER_INSTALL_SHARED_LIB_CHOWN = \
	(cd $(LIB_LINK_INSTALL_DIR); \
	chown $(CHOWN_TO) $(LIB_LINK_SONAME_FILE); \
	chown $(CHOWN_TO) $(LIB_LINK_FILE))

OBJ_MERGE_CMD		= \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

SHARED_CFLAGS      += -fPIC
SHARED_LIBEXT      =  .so

HAVE_BUNDLES       =  yes
BUNDLE_LD	   =  $(CC)
BUNDLE_LDFLAGS     += -shared
ADDITIONAL_LDFLAGS += -rdynamic
STATIC_LDFLAGS += -static

endif
#
# end Linux ELF
#
####################################################

####################################################
#
# FreeBSD a.out (2.2.x)
#
ifeq ($(findstring freebsdaout, $(GNUSTEP_TARGET_OS)), freebsdaout)
freebsdaout = yes

HAVE_SHARED_LIBS	= no
SHARED_LIB_LINK_CMD = \
	$(CC) -shared -Wl,-soname,$(LIB_LINK_VERSION_FILE) \
	   -o $(LIB_LINK_OBJ_DIR)/$(LIB_LINK_VERSION_FILE) $^ /usr/lib/c++rt0.o;\
	(cd $(LIB_LINK_OBJ_DIR); \
	  rm -f $(LIB_LINK_FILE); \
	  $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))

SHARED_CFLAGS	+= -fPIC
SHARED_LIBEXT	= .so

HAVE_BUNDLES	= yes
BUNDLE_LD	= $(CC)
BUNDLE_LDFLAGS	+= -shared
ADDITIONAL_LDFLAGS += -rdynamic
STATIC_LDFLAGS += -static
endif
#
# end FreeBSD A.out
#
####################################################

####################################################
#
# FreeBSD ELF
#
ifeq ($(findstring freebsd, $(GNUSTEP_TARGET_OS)), freebsd)
ifneq ($(freebsdaout), yes)
HAVE_SHARED_LIBS	= yes
SHARED_LIB_LINK_CMD = \
	$(CC) -shared -Wl,-soname,$(LIB_LINK_SONAME_FILE) \
	   -o $(LIB_LINK_OBJ_DIR)/$(LIB_LINK_VERSION_FILE) $^ \
	   $(INTERNAL_LIBRARIES_DEPEND_UPON) \
	   $(SHARED_LD_POSTFLAGS);\
	(cd $(LIB_LINK_OBJ_DIR); \
	  rm -f $(LIB_LINK_FILE) $(LIB_LINK_SONAME_FILE); \
	  $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_SONAME_FILE); \
	  $(LN_S) $(LIB_LINK_SONAME_FILE) $(LIB_LINK_FILE))
AFTER_INSTALL_SHARED_LIB_CMD = \
	(cd $(LIB_LINK_INSTALL_DIR); \
	  rm -f $(LIB_LINK_FILE) $(LIB_LINK_SONAME_FILE); \
	  $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_SONAME_FILE); \
	  $(LN_S) $(LIB_LINK_SONAME_FILE) $(LIB_LINK_FILE); \
	)
AFTER_INSTALL_SHARED_LIB_CHOWN = \
	(cd $(LIB_LINK_INSTALL_DIR); \
	chown $(CHOWN_TO) $(LIB_LINK_SONAME_FILE); \
	chown $(CHOWN_TO) $(LIB_LINK_FILE))
OBJ_MERGE_CMD		= \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

SHARED_CFLAGS	+= -fPIC
SHARED_LIBEXT	= .so

HAVE_BUNDLES	= yes
BUNDLE_LD	= $(CC)
BUNDLE_LDFLAGS	+= -shared
ADDITIONAL_LDFLAGS += -rdynamic
STATIC_LDFLAGS += -static
endif
endif
#
# end FreeBSD
#
####################################################

####################################################
#
# NetBSD
#
ifeq ($(findstring netbsd, $(GNUSTEP_TARGET_OS)), netbsd)
# This is disabled temporarily, because I don't know exactly how
# to link shared libs. Everything seems to link correctly now but
# constructor functions in the shared lib failed to get called
# when the lib is loaded in. I don't know why. ASF.
HAVE_SHARED_LIBS        = no
SHARED_LD		= ld
SHARED_LIB_LINK_CMD     = \
        $(SHARED_LD) -x -Bshareable -Bforcearchive \
           -o $(LIB_LINK_OBJ_DIR)/$(LIB_LINK_VERSION_FILE) $^ /usr/lib/c++rt0.o;\
        (cd $(LIB_LINK_OBJ_DIR); \
          rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))

SHARED_CFLAGS   += -shared -fpic
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_LD	= $(CC)
BUNDLE_LDFLAGS  += -shared -fpic
#ADDITIONAL_LDFLAGS += -rdynamic
STATIC_LDFLAGS += -static
endif
#
# end NetBSD
#
####################################################

####################################################
#
# NetBSD ELF
#
ifeq ($(findstring netbsdelf, $(GNUSTEP_TARGET_OS)), netbsdelf)
HAVE_SHARED_LIBS    = yes
SHARED_LD_POSTFLAGS = -Wl,-R/usr/pkg/lib -L/usr/pkg/lib
SHARED_LIB_LINK_CMD = \
	$(CC) -shared -Wl,-soname,$(LIB_LINK_VERSION_FILE) \
              -o $(LIB_LINK_OBJ_DIR)/$(LIB_LINK_VERSION_FILE) \
                 $^ $(INTERNAL_LIBRARIES_DEPEND_UPON) \
                 $(SHARED_LD_POSTFLAGS); \
	(cd $(LIB_LINK_OBJ_DIR); \
	  rm -f $(LIB_LINK_FILE); \
	  $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))
OBJ_MERGE_CMD		= \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

SHARED_CFLAGS	+= -fPIC
SHARED_LIBEXT	= .so

HAVE_BUNDLES	= yes
BUNDLE_LD	= $(CC)
BUNDLE_LDFLAGS	+= -shared
ADDITIONAL_LDFLAGS += -rdynamic -Wl,-R/usr/pkg/lib -L/usr/pkg/lib
ADDITIONAL_INCLUDE_DIRS += -I/usr/pkg/include
STATIC_LDFLAGS += -static
endif
#
# end NetBSD
#
####################################################

####################################################
#
# OpenBSD 2.x (though set for 2.4)
#
ifeq ($(findstring openbsd, $(GNUSTEP_TARGET_OS)), openbsd)
# This is disabled temporarily, because I don't know exactly how
# to link shared libs. Everything seems to link correctly now but
# constructor functions in the shared lib failed to get called
# when the lib is loaded in. I don't know why. ASF.
HAVE_SHARED_LIBS        = no
SHARED_LD		= ld
SHARED_LIB_LINK_CMD     = \
        $(SHARED_LD) $(SHARED_LD_PREFLAGS) -x -Bshareable -Bforcearchive \
           -o $(LIB_LINK_OBJ_DIR)/$(LIB_LINK_VERSION_FILE) $^ /usr/lib/c++rt0.o \
	   $(SHARED_LD_POSTFLAGS); \
        (cd $(LIB_LINK_OBJ_DIR); \
          rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))

SHARED_CFLAGS   += -shared -fpic
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = no
BUNDLE_LD	= $(CC)
BUNDLE_LDFLAGS  += -shared -fpic
#ADDITIONAL_LDFLAGS += -rdynamic
STATIC_LDFLAGS += -static
endif
#
# end OpenBSD 2.x
#
####################################################

####################################################
#
# OSF
#
ifeq ($(findstring osf, $(GNUSTEP_TARGET_OS)), osf)
HAVE_SHARED_LIBS	= yes
SHARED_LIB_LINK_CMD = \
	$(CC) -shared -Wl,-soname,$(LIB_LINK_VERSION_FILE) \
	   -o $(LIB_LINK_OBJ_DIR)/$(LIB_LINK_VERSION_FILE) $^ ;\
	(cd $(LIB_LINK_OBJ_DIR); \
	  rm -f $(LIB_LINK_FILE); \
	  $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))
OBJ_MERGE_CMD		= \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

SHARED_CFLAGS	+= -fPIC
SHARED_LIBEXT	= .so

HAVE_BUNDLES	= yes
BUNDLE_LD	= $(CC)
BUNDLE_LDFLAGS	+= -shared
ADDITIONAL_LDFLAGS += -rdynamic
STATIC_LDFLAGS += -static
# Newer gcc's don't define this in Objective-C programs:
AUXILIARY_CPPFLAGS += -D__LANGUAGES_C__
endif
#
# end OSF
#
####################################################

####################################################
#
# IRIX
#
ifeq ($(findstring irix, $(GNUSTEP_TARGET_OS)), irix)
HAVE_SHARED_LIBS        = yes
STATIC_LIB_LINK_CMD = \
        (cd $(LIB_LINK_OBJ_DIR); $(AR) $(ARFLAGS) \
        $(LIB_LINK_VERSION_FILE) `ls -1 *\.o */*\.o`);\
        $(RANLIB) $(LIB_LINK_VERSION_FILE)
SHARED_LIB_LINK_CMD     = \
        (cd $(LIB_LINK_OBJ_DIR); $(CC) -v $(SHARED_LD_PREFLAGS) \
	$(SHARED_CFLAGS) -shared -o $(LIB_LINK_VERSION_FILE) `ls -1 *\.o` \
	$(INTERNAL_LIBRARIES_DEPEND_UPON) $(SHARED_LD_POSTFLAGS);\
          rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))

SHARED_CFLAGS     += -fPIC
SHARED_LIBEXT   = .so

OBJ_MERGE_CMD		= \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

HAVE_BUNDLES    = yes
BUNDLE_LD       = $(CC)
BUNDLE_LDFLAGS  += -shared
endif

# end IRIX
#
####################################################

####################################################
#
# Mingw32
#
ifeq ($(findstring mingw32, $(GNUSTEP_TARGET_OS)), mingw32)
shared = yes
HAVE_SHARED_LIBS = yes
BUILD_DLL	 = yes
WITH_DLL	 = yes
SHARED_LIBEXT	 = .a
DLL_LIBEXT	 = .dll
DLLTOOL		 = dlltool
DLLWRAP		 = dllwrap
#SHARED_CFLAGS	 += 

OBJ_MERGE_CMD = \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

HAVE_BUNDLES   = yes
BUNDLE_LD      = $(CC)
BUNDLE_LDFLAGS += -nodefaultlibs -Xlinker -r
endif

# end Mingw32
#
####################################################

####################################################
#
# Cygwin
#
ifeq ($(findstring cygwin, $(GNUSTEP_TARGET_OS)), cygwin)
shared = yes
HAVE_SHARED_LIBS = yes
BUILD_DLL	 = yes
WITH_DLL	 = yes
SHARED_LIBEXT	 = .a
DLL_LIBEXT	 = .dll
DLLTOOL		 = dlltool
DLLWRAP		 = dllwrap
#SHARED_CFLAGS	 += 

OBJ_MERGE_CMD = \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

HAVE_BUNDLES   = yes
BUNDLE_LD      = $(CC)
BUNDLE_LDFLAGS += -nodefaultlibs -Xlinker -r
endif

# end Cygwin
#
####################################################


####################################################
#
# Solaris
#
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
	$(CC) $(SHARED_LD_PREFLAGS) -G -Wl,-h,$(LIB_LINK_SONAME_FILE) \
	   -o $(LIB_LINK_OBJ_DIR)/$(LIB_LINK_VERSION_FILE) $^ \
	   $(INTERNAL_LIBRARIES_DEPEND_UPON) \
	   $(SHARED_LD_POSTFLAGS);\
	(cd $(LIB_LINK_OBJ_DIR); \
          rm -f $(LIB_LINK_FILE) $(LIB_LINK_SONAME_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_SONAME_FILE); \
          $(LN_S) $(LIB_LINK_SONAME_FILE) $(LIB_LINK_FILE); \
	)
AFTER_INSTALL_SHARED_LIB_CMD = \
	(cd $(LIB_LINK_INSTALL_DIR); \
          rm -f $(LIB_LINK_FILE) $(LIB_LINK_SONAME_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_SONAME_FILE); \
          $(LN_S) $(LIB_LINK_SONAME_FILE) $(LIB_LINK_FILE); \
	)
AFTER_INSTALL_SHARED_LIB_CHOWN = \
	(cd $(LIB_LINK_INSTALL_DIR); \
	chown $(CHOWN_TO) $(LIB_LINK_SONAME_FILE); \
	chown $(CHOWN_TO) $(LIB_LINK_FILE))

OBJ_MERGE_CMD		= \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

SHARED_CFLAGS     += -fpic -fPIC
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_LD	= $(CC)
BUNDLE_LDFLAGS  = -shared -mimpure-text
#BUNDLE_LDFLAGS  = -nodefaultlibs -Xlinker -r
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
        $(CC) $(SHARED_LD_PREFLAGS) -shared -o $(LIB_LINK_VERSION_FILE) $^ \
	  $(SHARED_LD_POSTFLAGS);\
        mv $(LIB_LINK_VERSION_FILE) $(LIB_LINK_OBJ_DIR);\
        (cd $(LIB_LINK_OBJ_DIR); \
          rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))

SHARED_CFLAGS     += -fpic -fPIC
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_LD       = $(CC)
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
        (cd $(LIB_LINK_OBJ_DIR); \
	  $(CC) $(SHARED_LD_PREFLAGS) \
	    -v $(SHARED_CFLAGS) -shared \
	    -o $(LIB_LINK_VERSION_FILE) `ls -1 *\.o */*\.o` \
	    $(SHARED_LD_POSTFLAGS) ;\
          rm -f $(LIB_LINK_FILE); \
          $(LN_S) $(LIB_LINK_VERSION_FILE) $(LIB_LINK_FILE))

ifeq ($(CC), cc)
SHARED_CFLAGS   += +z
else
SHARED_CFLAGS   += -fPIC
endif

ifeq ($(GNUSTEP_HOST_CPU), ia64)
SHARED_LIBEXT   = .so
else
SHARED_LIBEXT   = .sl
endif

HAVE_BUNDLES    = yes
BUNDLE_LD	= $(CC)
BUNDLE_LDFLAGS  += -nodefaultlibs -Xlinker -r
ADDITIONAL_LDFLAGS += -Xlinker +s
STATIC_LDFLAGS += -static
endif

# end HP-UX
#
####################################################

## Local variables:
## mode: makefile
## End:
