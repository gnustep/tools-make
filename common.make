#
#   common.make
#
#   Set all of the common environment variables.
#
#   Copyright (C) 1997, 2001 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
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

ifeq ($(COMMON_MAKE_LOADED),)
COMMON_MAKE_LOADED = yes

SHELL = /bin/sh

# Default version
MAJOR_VERSION    = 1
MINOR_VERSION    = 0
SUBMINOR_VERSION = 0
VERSION          = ${MAJOR_VERSION}.${MINOR_VERSION}.${SUBMINOR_VERSION}

# GNUSTEP_BASE_INSTALL by default is `' - this is correct

#
# Scripts to run for parsing canonical names
#
CONFIG_GUESS_SCRIPT    = $(GNUSTEP_MAKEFILES)/config.guess
CONFIG_SUB_SCRIPT      = $(GNUSTEP_MAKEFILES)/config.sub
CONFIG_CPU_SCRIPT      = $(GNUSTEP_MAKEFILES)/cpu.sh
CONFIG_VENDOR_SCRIPT   = $(GNUSTEP_MAKEFILES)/vendor.sh
CONFIG_OS_SCRIPT       = $(GNUSTEP_MAKEFILES)/os.sh
CLEAN_CPU_SCRIPT       = $(GNUSTEP_MAKEFILES)/clean_cpu.sh
CLEAN_VENDOR_SCRIPT    = $(GNUSTEP_MAKEFILES)/clean_vendor.sh
CLEAN_OS_SCRIPT        = $(GNUSTEP_MAKEFILES)/clean_os.sh
ifeq ($(GNUSTEP_FLATTENED),)
  WHICH_LIB_SCRIPT \
	= $(GNUSTEP_MAKEFILES)/$(GNUSTEP_HOST_CPU)/$(GNUSTEP_HOST_OS)/which_lib
else
  WHICH_LIB_SCRIPT = $(GNUSTEP_MAKEFILES)/which_lib
endif
LD_LIB_PATH_SCRIPT     = $(GNUSTEP_MAKEFILES)/ld_lib_path.sh
TRANSFORM_PATHS_SCRIPT = $(GNUSTEP_MAKEFILES)/transform_paths.sh

# Take the makefiles from the system root
ifeq ($(GNUSTEP_MAKEFILES),)
  GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles
endif

#
# Determine the compilation host and target
#
include $(GNUSTEP_MAKEFILES)/names.make

ifeq ($(GNUSTEP_FLATTENED),)
  GNUSTEP_HOST_DIR = $(GNUSTEP_HOST_CPU)/$(GNUSTEP_HOST_OS)
  GNUSTEP_TARGET_DIR = $(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)
  GNUSTEP_HOST_LDIR = $(GNUSTEP_HOST_DIR)/$(LIBRARY_COMBO)
  GNUSTEP_TARGET_LDIR = $(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)
else
  GNUSTEP_HOST_DIR = .
  GNUSTEP_TARGET_DIR = .
  GNUSTEP_HOST_LDIR = .
  GNUSTEP_TARGET_LDIR = .
endif

#
# Get the config information
#
include $(GNUSTEP_MAKEFILES)/$(GNUSTEP_TARGET_DIR)/config.make

# Sanity check on $PATH - NB: if PATH is wrong, we can't do certain things
# because we can't run the tools (not even using opentool as we can't even
# run opentool if PATH is wrong)
ifeq ($(MAKELEVEL),0)

  # NB - we can't trust PATH here because it's what we are trying to
  # check ... but hopefully if we (common.make) have been found, we
  # can trust that at least $(GNUSTEP_MAKEFILES) is set up correctly :-)

  # We want to check that this path is in the PATH
  SYS_TOOLS_PATH = $(GNUSTEP_SYSTEM_ROOT)/Tools

  # But on windows we might need to first fix it up ...
  ifeq ($(findstring mingw, $(GNUSTEP_TARGET_OS)), mingw)
    ifeq ($(shell echo "$(SYS_TOOLS_PATH)" | sed 's/^\([a-zA-Z]:.*\)//'),)
      SYS_TOOLS_PATH := $(shell cygpath -u $(SYS_TOOLS_PATH))
    endif
  endif

  ifeq ($(findstring $(SYS_TOOLS_PATH),$(PATH)),)
    $(warning WARNING - Your PATH is not set up correctly !)
    $(warning You need to run the GNUstep configuration script to fix this)
    $(warning try running ". $(GNUSTEP_MAKEFILES)/GNUstep.sh")
  endif

endif



#
# Get flags/config options for core libraries
#

# First, work out precisely library combos etc
include $(GNUSTEP_MAKEFILES)/library-combo.make
# Then include custom makefiles with flags/config options
# This is meant to be used by the core libraries to override loading
# of the system makefiles from $(GNUSTEP_MAKEFILES)/Additional/*.make
# with their local copy (presumably more up-to-date)
ifneq ($(GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES),)
include $(GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES)
endif
# Then include makefiles with flags/config options installed by the 
# libraries themselves
-include $(GNUSTEP_MAKEFILES)/Additional/*.make

#
# Determine target specific settings
#
include $(GNUSTEP_MAKEFILES)/target.make

#
# GNUSTEP_INSTALLATION_DIR is the directory where all the things go. If you
# don't specify it defaults to GNUSTEP_LOCAL_ROOT, unless GNUSTEP_LOCAL_ROOT
# is empty in which case it defaults to GNUSTEP_SYSTEM_ROOT
#
ifeq ($(GNUSTEP_INSTALLATION_DIR),)
  ifeq ($(GNUSTEP_LOCAL_ROOT),)
    GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)
  else
    GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_LOCAL_ROOT)
  endif
endif

#
# Variables specifying the installation directory paths
#
GNUSTEP_APPS                 = $(GNUSTEP_INSTALLATION_DIR)/Apps
GNUSTEP_TOOLS                = $(GNUSTEP_INSTALLATION_DIR)/Tools
GNUSTEP_SERVICES             = $(GNUSTEP_INSTALLATION_DIR)/Library/Services
GNUSTEP_WOAPPS               = $(GNUSTEP_INSTALLATION_DIR)/WOApps
GNUSTEP_HEADERS              = $(GNUSTEP_INSTALLATION_DIR)/Headers
GNUSTEP_BUNDLES 	     = $(GNUSTEP_INSTALLATION_DIR)/Library/Bundles
GNUSTEP_FRAMEWORKS	     = $(GNUSTEP_INSTALLATION_DIR)/Library/Frameworks
GNUSTEP_FRAMEWORKS_HEADERS   = $(GNUSTEP_INSTALLATION_DIR)/Library/Headers
GNUSTEP_FRAMEWORKS_LIBRARIES = $(GNUSTEP_INSTALLATION_DIR)/Library/Libraries
GNUSTEP_PALETTES 	     = $(GNUSTEP_INSTALLATION_DIR)/Developer/Palettes
GNUSTEP_LIBRARIES            = $(GNUSTEP_INSTALLATION_DIR)/Libraries
GNUSTEP_RESOURCES            = $(GNUSTEP_INSTALLATION_DIR)/Libraries/Resources
GNUSTEP_JAVA                 = $(GNUSTEP_INSTALLATION_DIR)/Libraries/Java
GNUSTEP_DOCUMENTATION        = $(GNUSTEP_INSTALLATION_DIR)/Documentation
GNUSTEP_DOCUMENTATION_MAN    = $(GNUSTEP_DOCUMENTATION)/man
GNUSTEP_DOCUMENTATION_INFO   = $(GNUSTEP_DOCUMENTATION)/info

#
# Variables defined only for backward compatibility with older gnustep-makes
#
# Will be removed any time after 31 December 2001.
#
# DEPRECATED - use GNUSTEP_FRAMEWORKS_LIBRARIES instead
GNUSTEP_FRAMEWORKS_LIBRARIES_ROOT = $(GNUSTEP_FRAMEWORKS_LIBRARIES)
# DEPRECATED - use GNUSTEP_LIBRARIES instead
GNUSTEP_LIBRARIES_ROOT = $(GNUSTEP_LIBRARIES)

# The default name of the makefile to be used in recursive invocations of make
ifeq ($(MAKEFILE_NAME),)
MAKEFILE_NAME = GNUmakefile
endif

#
# Now prepare the library and header flags
#

#
# SYSTEM
#
GNUSTEP_SYSTEM_HEADERS = $(GNUSTEP_SYSTEM_ROOT)/Headers

ifeq ($(GNUSTEP_FLATTENED),)
  GNUSTEP_SYSTEM_FRAMEWORKS_LIBRARIES_FLAGS = \
        -L$(GNUSTEP_SYSTEM_ROOT)/Library/Libraries/$(GNUSTEP_TARGET_LDIR)

  GNUSTEP_SYSTEM_LIBRARIES_FLAGS = \
    -L$(GNUSTEP_SYSTEM_ROOT)/Libraries/$(GNUSTEP_TARGET_LDIR) \
    -L$(GNUSTEP_SYSTEM_ROOT)/Libraries/$(GNUSTEP_TARGET_DIR)

else
  GNUSTEP_SYSTEM_FRAMEWORKS_LIBRARIES_FLAGS = \
    -L$(GNUSTEP_SYSTEM_ROOT)/Library/Libraries

  GNUSTEP_SYSTEM_LIBRARIES_FLAGS = -L$(GNUSTEP_SYSTEM_ROOT)/Libraries
endif

GNUSTEP_SYSTEM_HEADERS_FLAGS = -I$(GNUSTEP_SYSTEM_HEADERS)
# FIXME: parse -framework keyword
GNUSTEP_SYSTEM_FRAMEWORKS_HEADERS_FLAGS = \
  -I$(GNUSTEP_SYSTEM_ROOT)/Library/Headers

#
# LOCAL
#
ifneq ($(GNUSTEP_LOCAL_ROOT),)

  GNUSTEP_LOCAL_HEADERS = $(GNUSTEP_LOCAL_ROOT)/Headers

  ifeq ($(GNUSTEP_FLATTENED),)
    GNUSTEP_LOCAL_FRAMEWORKS_LIBRARIES_FLAGS = \
	-L$(GNUSTEP_LOCAL_ROOT)/Library/Libraries/$(GNUSTEP_TARGET_LDIR)

    GNUSTEP_LOCAL_LIBRARIES_FLAGS = \
      -L$(GNUSTEP_LOCAL_ROOT)/Libraries/$(GNUSTEP_TARGET_LDIR) \
      -L$(GNUSTEP_LOCAL_ROOT)/Libraries/$(GNUSTEP_TARGET_DIR)
  else
    GNUSTEP_LOCAL_FRAMEWORKS_LIBRARIES_FLAGS = \
	-L$(GNUSTEP_LOCAL_ROOT)/Library/Libraries

    GNUSTEP_LOCAL_LIBRARIES_FLAGS = -L$(GNUSTEP_LOCAL_ROOT)/Libraries
  endif

  GNUSTEP_LOCAL_HEADERS_FLAGS = -I$(GNUSTEP_LOCAL_HEADERS)
  # FIXME: parse -framework keyword
  GNUSTEP_LOCAL_FRAMEWORKS_HEADERS_FLAGS = \
    -I$(GNUSTEP_LOCAL_ROOT)/Library/Headers
endif

#
# USER
#
ifneq ($(GNUSTEP_USER_ROOT),)

  GNUSTEP_USER_HEADERS = $(GNUSTEP_USER_ROOT)/Headers

  ifeq ($(GNUSTEP_FLATTENED),)
    GNUSTEP_USER_FRAMEWORKS_LIBRARIES_FLAGS = \
	-L$(GNUSTEP_USER_ROOT)/Library/Libraries/$(GNUSTEP_TARGET_LDIR)

    GNUSTEP_USER_LIBRARIES_FLAGS   = \
      -L$(GNUSTEP_USER_ROOT)/Libraries/$(GNUSTEP_TARGET_LDIR) \
      -L$(GNUSTEP_USER_ROOT)/Libraries/$(GNUSTEP_TARGET_DIR)
  else
    GNUSTEP_USER_FRAMEWORKS_LIBRARIES_FLAGS = \
	-L$(GNUSTEP_USER_ROOT)/Library/Libraries
    GNUSTEP_USER_LIBRARIES_FLAGS   = -L$(GNUSTEP_USER_ROOT)/Libraries
  endif

  GNUSTEP_USER_HEADERS_FLAGS     = -I$(GNUSTEP_USER_HEADERS)
  # FIXME: parse -framework keyword
  GNUSTEP_USER_FRAMEWORKS_HEADERS_FLAGS \
	= -I$(GNUSTEP_USER_ROOT)/Library/Headers
endif


#
# NETWORK
#
ifneq ($(GNUSTEP_NETWORK_ROOT),)

  GNUSTEP_NETWORK_HEADERS = $(GNUSTEP_NETWORK_ROOT)/Headers

  ifeq ($(GNUSTEP_FLATTENED),)
    GNUSTEP_NETWORK_LIBRARIES_FLAGS = \
      -L$(GNUSTEP_NETWORK_ROOT)/Libraries/$(GNUSTEP_TARGET_LDIR) \
      -L$(GNUSTEP_NETWORK_ROOT)/Libraries/$(GNUSTEP_TARGET_DIR)

    GNUSTEP_NETWORK_FRAMEWORKS_LIBRARIES_FLAGS = \
	-L$(GNUSTEP_NETWORK_ROOT)/Library/Libraries/$(GNUSTEP_TARGET_LDIR)
  else
    GNUSTEP_NETWORK_LIBRARIES_FLAGS = -L$(GNUSTEP_NETWORK_ROOT)/Libraries

    GNUSTEP_NETWORK_FRAMEWORKS_LIBRARIES_FLAGS = \
	-L$(GNUSTEP_NETWORK_ROOT)/Library/Libraries
  endif

  GNUSTEP_NETWORK_HEADERS_FLAGS = -I$(GNUSTEP_NETWORK_HEADERS)
  # FIXME: parse -framework keyword
  GNUSTEP_NETWORK_FRAMEWORKS_HEADERS_FLAGS \
	= -I$(GNUSTEP_NETWORK_ROOT)/Library/Headers

endif

ifeq ($(GNUSTEP_FLATTENED),)
  #
  # Target specific header include directories
  #
  ifneq ($(GNUSTEP_NETWORK_ROOT),)
    GNUSTEP_HEADERS_TARGET_FLAGS += \
		-I$(GNUSTEP_NETWORK_HEADERS)/$(GNUSTEP_TARGET_DIR)
  endif
  ifneq ($(GNUSTEP_USER_ROOT),)
    GNUSTEP_HEADERS_TARGET_FLAGS \
	+= -I$(GNUSTEP_USER_HEADERS)/$(GNUSTEP_TARGET_DIR)
  endif
  ifneq ($(GNUSTEP_LOCAL_ROOT),)
    GNUSTEP_HEADERS_TARGET_FLAGS \
	+= -I$(GNUSTEP_LOCAL_HEADERS)/$(GNUSTEP_TARGET_DIR)
  endif
  GNUSTEP_HEADERS_TARGET_FLAGS \
	+= -I$(GNUSTEP_SYSTEM_HEADERS)/$(GNUSTEP_TARGET_DIR)
endif

#
# Determine Foundation header subdirectory based upon library combo
#
ifeq ($(FOUNDATION_LIB),gnu)
  GNUSTEP_FND_DIR           = gnustep
  FOUNDATION_LIBRARY_NAME   = gnustep-base
  FOUNDATION_LIBRARY_DEFINE = -DGNUSTEP_BASE_LIBRARY=1
endif

ifeq ($(FOUNDATION_LIB),fd)
  GNUSTEP_FND_DIR           = libFoundation
  FOUNDATION_LIBRARY_NAME   = Foundation
  FOUNDATION_LIBRARY_DEFINE = -DLIB_FOUNDATION_LIBRARY=1
  ifeq ($(gc),yes)
    ifneq ($(leak),yes)
      FOUNDATION_LIBRARY_DEFINE += -DLIB_FOUNDATION_BOEHM_GC=1
    else
      FOUNDATION_LIBRARY_DEFINE += -DLIB_FOUNDATION_LEAK_GC=1
    endif
  endif
endif

ifeq ($(FOUNDATION_LIB),nx)
  GNUSTEP_FND_DIR           = NeXT
  FOUNDATION_LIBRARY_NAME   =
  FOUNDATION_LIBRARY_DEFINE = -DNeXT_Foundation_LIBRARY=1
endif

ifeq ($(FOUNDATION_LIB),sun)
  GNUSTEP_FND_DIR           = sun
  FOUNDATION_LIBRARY_DEFINE = -DSun_Foundation_LIBRARY=1
endif

ifneq ($(GNUSTEP_NETWORK_ROOT),)
  GNUSTEP_HEADERS_FND_FLAG += -I$(GNUSTEP_NETWORK_HEADERS)/$(GNUSTEP_FND_DIR)
endif
ifneq ($(GNUSTEP_USER_ROOT),)
  GNUSTEP_HEADERS_FND_FLAG += -I$(GNUSTEP_USER_HEADERS)/$(GNUSTEP_FND_DIR)
endif
ifneq ($(GNUSTEP_LOCAL_ROOT),)
  GNUSTEP_HEADERS_FND_FLAG += -I$(GNUSTEP_LOCAL_HEADERS)/$(GNUSTEP_FND_DIR)
endif
GNUSTEP_HEADERS_FND_FLAG += -I$(GNUSTEP_SYSTEM_HEADERS)/$(GNUSTEP_FND_DIR)

ifeq ($(FOUNDATION_LIB), fd)
  GNUSTEP_HEADERS_FND_FLAG += -I$(GNUSTEP_USER_HEADERS)/$(GNUSTEP_FND_DIR)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(OBJC_RUNTIME) \
	-I$(GNUSTEP_LOCAL_HEADERS)/$(GNUSTEP_FND_DIR)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(OBJC_RUNTIME) \
	-I$(GNUSTEP_SYSTEM_HEADERS)/$(GNUSTEP_FND_DIR)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(OBJC_RUNTIME)
endif

#
# Overridable compilation flags
#
OBJCFLAGS = -Wno-import
CFLAGS =
OBJ_DIR_PREFIX =

ifeq ($(OBJC_RUNTIME_LIB),gnu)
  RUNTIME_FLAG   = -fgnu-runtime
  RUNTIME_DEFINE = -DGNU_RUNTIME=1
endif

# GNU runtime compiled with Boehm GC
ifeq ($(OBJC_RUNTIME_LIB),gnugc)
  RUNTIME_FLAG   = -fgnu-runtime
  RUNTIME_DEFINE = -DGNU_RUNTIME=1 -DOBJC_WITH_GC=1
  ifeq ($(debug),yes)
    RUNTIME_DEFINE += -DGC_DEBUG
  endif
endif

ifeq ($(OBJC_RUNTIME_LIB),nx)
  ifneq ($(OBJC_COMPILER), NeXT)
    RUNTIME_FLAG = -fnext-runtime
  endif
  RUNTIME_DEFINE = -DNeXT_RUNTIME=1
endif

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
  LIB_LINK_CMD              =  $(SHARED_LIB_LINK_CMD)
  FRAMEWORK_LINK_CMD        =  $(SHARED_FRAMEWORK_LINK_CMD)
  OBJ_DIR_PREFIX            += shared_
  INTERNAL_OBJCFLAGS        += $(SHARED_CFLAGS)
  INTERNAL_CFLAGS           += $(SHARED_CFLAGS)
  AFTER_INSTALL_LIBRARY_CMD =  $(AFTER_INSTALL_SHARED_LIB_COMMAND)
else
  LIB_LINK_CMD              =  $(STATIC_LIB_LINK_CMD)
  FRAMEWORK_LINK_CMD        =  $(STATIC_FRAMEWORK_LINK_CMD)
  OBJ_DIR_PREFIX            += static_
  AFTER_INSTALL_LIBRARY_CMD =  $(AFTER_INSTALL_STATIC_LIB_COMMAND)
  LIBRARY_NAME_SUFFIX       := s$(LIBRARY_NAME_SUFFIX)
endif

ifeq ($(profile), yes)
  ADDITIONAL_FLAGS += -pg
  ifeq ($(LD), $(CC))
    LDFLAGS += -pg
  endif
  OBJ_DIR_PREFIX += profile_
  LIBRARY_NAME_SUFFIX := p$(LIBRARY_NAME_SUFFIX)
endif

ifeq ($(debug), yes)
  OPTFLAG := $(filter-out -O%, $(OPTFLAG))
  ADDITIONAL_FLAGS += -g -Wall -DDEBUG -fno-omit-frame-pointer
  INTERNAL_JAVACFLAGS += -g -deprecation
  OBJ_DIR_PREFIX += debug_
  LIBRARY_NAME_SUFFIX := d$(LIBRARY_NAME_SUFFIX)
else
  INTERNAL_JAVACFLAGS += -O
endif

OBJ_DIR_PREFIX += obj

ifeq ($(warn), no)
  ADDITIONAL_FLAGS += -UGSWARN
else
  ADDITIONAL_FLAGS += -DGSWARN
endif

ifneq ($(LIBRARY_NAME_SUFFIX),)
  LIBRARY_NAME_SUFFIX := _$(LIBRARY_NAME_SUFFIX)
endif

AUXILIARY_CPPFLAGS += $(GNUSTEP_DEFINE) \
		$(FND_DEFINE) $(GUI_DEFINE) $(BACKEND_DEFINE) \
		$(RUNTIME_DEFINE) $(FOUNDATION_LIBRARY_DEFINE)

INTERNAL_OBJCFLAGS += $(ADDITIONAL_FLAGS) $(OPTFLAG) $(OBJCFLAGS) \
			$(RUNTIME_FLAG)
INTERNAL_CFLAGS += $(ADDITIONAL_FLAGS) $(CFLAGS) $(OPTFLAG) $(RUNTIME_FLAG)
INTERNAL_LDFLAGS += $(LDFLAGS)

# trick needed to replace a space with nothing
empty:=
space:= $(empty) $(empty)
GNUSTEP_OBJ_PREFIX = $(subst $(space),,$(OBJ_DIR_PREFIX))

#
# Support building of Multiple Architecture Binaries (MAB). The object files
# directory will be something like shared_obj/ix86_m68k_sun/
#
ifeq ($(arch),)
  ARCH_OBJ_DIR = $(GNUSTEP_TARGET_DIR)
else
  ARCH_OBJ_DIR = \
      $(shell echo $(CLEANED_ARCH) | sed -e 's/ /_/g')/$(GNUSTEP_TARGET_OS)
endif

ifeq ($(GNUSTEP_FLATTENED),)
  GNUSTEP_OBJ_DIR = $(GNUSTEP_OBJ_PREFIX)/$(ARCH_OBJ_DIR)/$(LIBRARY_COMBO)
else
  GNUSTEP_OBJ_DIR = $(GNUSTEP_OBJ_PREFIX)
endif

#
# Common variables for building documentation
#
GNUSTEP_MAKEINFO        = makeinfo
GNUSTEP_MAKEINFO_FLAGS  = -D NO-TEXI2HTML --no-header
GNUSTEP_MAKETEXT        = makeinfo
GNUSTEP_MAKETEXT_FLAGS  = -D NO-TEXI2HTML -D TEXT-ONLY --no-header --no-split
GNUSTEP_TEXI2DVI        = texi2dvi
GNUSTEP_TEXI2DVI_FLAGS  =
GNUSTEP_TEXI2HTML       = texi2html
GNUSTEP_TEXI2HTML_FLAGS = -split_chapter -expandinfo
GNUSTEP_DVIPS           = dvips
GNUSTEP_DVIPS_FLAGS     = 

#
# Common variables for subprojects
#
SUBPROJECT_PRODUCT = subproject$(OEXT)

#
# Set JAVA_HOME if not set.
#
ifeq ($(JAVA_HOME),)
  # Else, try JDK_HOME
  ifeq ($(JDK_HOME),)
    # Else, try by finding the path of javac and removing 'bin/javac' from it
    ifeq ($(JAVAC),)
      JAVA_HOME = $(shell which javac | sed "s/bin\/javac//g")
    else # $(JAVAC) != "" 
      JAVA_HOME = $(shell which $(JAVAC) | sed "s/bin\/javac//g")
    endif  
  else # $(JDK_HOME) != ""
    JAVA_HOME = $(JDK_HOME) 
  endif
endif

#
# The Java Compiler.
#
ifeq ($(JAVAC),)
  JAVAC = $(JAVA_HOME)/bin/javac
endif

#
# The Java Header Compiler.
#
ifeq ($(JAVAH),)
  JAVAH = $(JAVA_HOME)/bin/javah
endif

#
# The Java Doc Tool.
#
ifeq ($(JAVADOC),)
  JAVADOC = $(JAVA_HOME)/bin/javadoc
endif

#
# Prepare the arguments to install to set user/group of installed files
#
INSTALL_AS = 

ifneq ($(INSTALL_AS_USER),)
INSTALL_AS += -o $(INSTALL_AS_USER)
endif

ifneq ($(INSTALL_AS_GROUP),)
INSTALL_AS += -g $(INSTALL_AS_GROUP)
endif

# Redefine INSTALL to include these flags.  This automatically
# redefines INSTALL_DATA and INSTALL_PROGRAM as well, because they are
# define in terms of INSTALL.
INSTALL += $(INSTALL_AS)

# Sometimes, we install without using INSTALL - typically using tar.
# In those cases, we run chown after having installed, in order to
# fixup the user/group.

#
# Prepare the arguments to chown to set user/group of installed files.
#
ifneq ($(INSTALL_AS_GROUP),)
CHOWN_TO = $(strip $(INSTALL_AS_USER)).$(strip $(INSTALL_AS_GROUP))
else 
CHOWN_TO = $(strip $(INSTALL_AS_USER))
endif

# You need to run CHOWN manually, but only if CHOWN_TO is non-empty.

#
# Pass the CHOWN_TO argument to MKINSTALLDIRS
# All installation directories should be created using MKINSTALLDIRS
# to make sure we set the correct user/group.  Local directories should
# be created using MKDIRS instead because we don't want to set user/group.
#
ifneq ($(CHOWN_TO),)
 MKINSTALLDIRS = $(MKDIRS) -c $(CHOWN_TO)
 # Fixup the library installation commands if needed so that we change
 # ownership of the links as well
 ifeq ($(shared),yes)
  AFTER_INSTALL_LIBRARY_CMD += ; $(AFTER_INSTALL_SHARED_LIB_CHOWN)
 endif
else
 MKINSTALLDIRS = $(MKDIRS)
endif

endif # COMMON_MAKE_LOADED

## Local variables:
## mode: makefile
## End:
