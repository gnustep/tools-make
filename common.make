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
REL_PATH_SCRIPT        = $(GNUSTEP_MAKEFILES)/relative_path.sh

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

#
# Sanity checks - only performed at the first make invocation
#
ifeq ($(MAKELEVEL),0)

# Sanity check on GNUSTEP_*_ROOT.  We want them all to be non-empty.
GNUSTEP_ERROR = 

ifeq ($(GNUSTEP_USER_ROOT),)
  GNUSTEP_ERROR=GNUSTEP_USER_ROOT
endif
ifeq ($(GNUSTEP_LOCAL_ROOT),)
  GNUSTEP_ERROR=GNUSTEP_LOCAL_ROOT
endif
ifeq ($(GNUSTEP_NETWORK_ROOT),)
  GNUSTEP_ERROR=GNUSTEP_NETWORK_ROOT
endif
ifeq ($(GNUSTEP_SYSTEM_ROOT),)
  GNUSTEP_ERROR=GNUSTEP_SYSTEM_ROOT
endif

ifneq ($(GNUSTEP_ERROR),)
  $(warning ERROR: Your $(GNUSTEP_ERROR) environment variable is empty !)
  $(error Please try again after running ". $(GNUSTEP_MAKEFILES)/GNUstep.sh")
endif

# Sanity check on $PATH - NB: if PATH is wrong, we can't do certain things
# because we can't run the tools (not even using opentool as we can't even
# run opentool if PATH is wrong) - this is particularly bad for gui stuff

# Skip the check if we are on an Apple system.  I was told that you can't
# source GNUstep.sh before running Apple's PB and that the only
# friendly solution is to disable the check.
ifneq ($(FOUNDATION_LIB),nx)

# NB - we can't trust PATH here because it's what we are trying to
# check ... but hopefully if we (common.make) have been found, we
# can trust that at least $(GNUSTEP_MAKEFILES) is set up correctly :-)

# We want to check that this path is in the PATH
SYS_TOOLS_PATH = $(GNUSTEP_SYSTEM_ROOT)/Tools

# But on cygwin we might need to first fix it up ...
ifeq ($(findstring cygwin, $(GNUSTEP_HOST_OS)), cygwin)
  ifeq ($(shell echo "$(SYS_TOOLS_PATH)" | sed 's/^\([a-zA-Z]:.*\)//'),)
    SYS_TOOLS_PATH := $(shell $(GNUSTEP_MAKEFILES)/fixpath.sh -u $(SYS_TOOLS_PATH))
  endif
endif

# Under mingw paths are so confused this warning is not worthwhile
ifneq ($(findstring mingw, $(GNUSTEP_HOST_OS)), mingw)
  ifeq ($(findstring $(SYS_TOOLS_PATH),$(PATH)),)
    $(warning WARNING: Your PATH may not be set up correctly !)
    $(warning Please try again after running ". $(GNUSTEP_MAKEFILES)/GNUstep.sh")
  endif
endif

endif # code used when FOUNDATION_LIB != nx

endif # End of sanity checks run only at makelevel 0

#
# Get standard messages
#
include $(GNUSTEP_MAKEFILES)/messages.make

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
# don't specify it defaults to GNUSTEP_LOCAL_ROOT.
#
ifeq ($(GNUSTEP_INSTALLATION_DIR),)
  GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_LOCAL_ROOT)
endif

# Make it public and available to all submakes invocations
export GNUSTEP_INSTALLATION_DIR

#
# Variables specifying the installation directory paths
#
GNUSTEP_APPS                 = $(GNUSTEP_INSTALLATION_DIR)/Applications
GNUSTEP_TOOLS                = $(GNUSTEP_INSTALLATION_DIR)/Tools
GNUSTEP_SERVICES             = $(GNUSTEP_INSTALLATION_DIR)/Library/Services
GNUSTEP_HEADERS              = $(GNUSTEP_INSTALLATION_DIR)/Headers
GNUSTEP_BUNDLES 	     = $(GNUSTEP_INSTALLATION_DIR)/Library/Bundles
GNUSTEP_FRAMEWORKS	     = $(GNUSTEP_INSTALLATION_DIR)/Library/Frameworks
GNUSTEP_PALETTES 	     = $(GNUSTEP_INSTALLATION_DIR)/Developer/Palettes
GNUSTEP_LIBRARIES            = $(GNUSTEP_INSTALLATION_DIR)/Libraries
GNUSTEP_RESOURCES            = $(GNUSTEP_INSTALLATION_DIR)/Libraries/Resources
GNUSTEP_JAVA                 = $(GNUSTEP_INSTALLATION_DIR)/Libraries/Java
GNUSTEP_DOCUMENTATION        = $(GNUSTEP_INSTALLATION_DIR)/Documentation
GNUSTEP_DOCUMENTATION_MAN    = $(GNUSTEP_DOCUMENTATION)/man
GNUSTEP_DOCUMENTATION_INFO   = $(GNUSTEP_DOCUMENTATION)/info

# The default name of the makefile to be used in recursive invocations of make
ifeq ($(MAKEFILE_NAME),)
MAKEFILE_NAME = GNUmakefile
endif

# Now prepare the library and header flags - we first prepare the list
# of directories, then optionally remove the empty ones, then prepend
# -I / -L to them.
ifeq ($(GNUSTEP_FLATTENED),)

GNUSTEP_HEADERS_DIRS = \
  $(GNUSTEP_USER_ROOT)/Headers/$(GNUSTEP_TARGET_DIR) \
  $(GNUSTEP_USER_ROOT)/Headers \
  $(GNUSTEP_LOCAL_ROOT)/Headers/$(GNUSTEP_TARGET_DIR) \
  $(GNUSTEP_LOCAL_ROOT)/Headers \
  $(GNUSTEP_NETWORK_ROOT)/Headers/$(GNUSTEP_TARGET_DIR) \
  $(GNUSTEP_NETWORK_ROOT)/Headers \
  $(GNUSTEP_SYSTEM_ROOT)/Headers/$(GNUSTEP_TARGET_DIR) \
  $(GNUSTEP_SYSTEM_ROOT)/Headers

GNUSTEP_LIBRARIES_DIRS = \
  $(GNUSTEP_USER_ROOT)/Libraries/$(GNUSTEP_TARGET_LDIR) \
  $(GNUSTEP_USER_ROOT)/Libraries/$(GNUSTEP_TARGET_DIR) \
  $(GNUSTEP_LOCAL_ROOT)/Libraries/$(GNUSTEP_TARGET_LDIR) \
  $(GNUSTEP_LOCAL_ROOT)/Libraries/$(GNUSTEP_TARGET_DIR) \
  $(GNUSTEP_NETWORK_ROOT)/Libraries/$(GNUSTEP_TARGET_LDIR) \
  $(GNUSTEP_NETWORK_ROOT)/Libraries/$(GNUSTEP_TARGET_DIR) \
  $(GNUSTEP_SYSTEM_ROOT)/Libraries/$(GNUSTEP_TARGET_LDIR) \
  $(GNUSTEP_SYSTEM_ROOT)/Libraries/$(GNUSTEP_TARGET_DIR)

else # GNUSTEP_FLATTENED

GNUSTEP_HEADERS_DIRS = \
  $(GNUSTEP_USER_ROOT)/Headers \
  $(GNUSTEP_LOCAL_ROOT)/Headers \
  $(GNUSTEP_NETWORK_ROOT)/Headers \
  $(GNUSTEP_SYSTEM_ROOT)/Headers

GNUSTEP_LIBRARIES_DIRS = \
  $(GNUSTEP_USER_ROOT)/Libraries \
  $(GNUSTEP_LOCAL_ROOT)/Libraries \
  $(GNUSTEP_NETWORK_ROOT)/Libraries \
  $(GNUSTEP_SYSTEM_ROOT)/Libraries

endif # GNUSTEP_FLATTENED

ifeq ($(REMOVE_EMPTY_DIRS),yes)
 # This variable, when evaluated, gives $(dir) if dir is non-empty, and
 # nothing if dir is empty.
 remove_if_empty = $(dir $(word 1,$(wildcard $(dir)/*)))

 # Build the GNUSTEP_HEADER_FLAGS by removing the empty dirs from
 # GNUSTEP_HEADER_DIRS, then prepending -I to each of them
 #
 # Important - because this variable is defined with = and not :=, it
 # is only evaluated when it is used.  Which is good - it means we don't 
 # scan the directories and try to remove the empty one on each make 
 # invocation (eg, on 'make clean') - we only scan the dirs when we are using
 # GNUSTEP_HEADERS_FLAGS to compile.  Please make sure to keep this
 # behaviour otherwise scanning the directories each time a makefile is
 # read might slow down the package unnecessarily for operations like
 # make clean, make distclean etc.
 #
 # Doing this filtering still gives a 5% to 10% slowdown in compilation times
 # due to directory scanning, which is why is normally turned off by
 # default - by default we put all directories in compilation commands.
 GNUSTEP_HEADERS_FLAGS = \
   $(addprefix -I,$(foreach dir,$(GNUSTEP_HEADERS_DIRS),$(remove_if_empty)))
 GNUSTEP_LIBRARIES_FLAGS = \
   $(addprefix -L,$(foreach dir,$(GNUSTEP_LIBRARIES_DIRS),$(remove_if_empty)))
else
 # Default case, just add -I / -L
 GNUSTEP_HEADERS_FLAGS = $(addprefix -I,$(GNUSTEP_HEADERS_DIRS))
 GNUSTEP_LIBRARIES_FLAGS = $(addprefix -L,$(GNUSTEP_LIBRARIES_DIRS))
endif

#
# Determine Foundation header subdirectory based upon library combo
#
GNUSTEP_HEADERS_FND_DIRS = \
  $(GNUSTEP_USER_ROOT)/Headers/$(GNUSTEP_FND_DIR) \
  $(GNUSTEP_LOCAL_ROOT)/Headers/$(GNUSTEP_FND_DIR) \
  $(GNUSTEP_NETWORK_ROOT)/Headers/$(GNUSTEP_FND_DIR) \
  $(GNUSTEP_SYSTEM_ROOT)/Headers/$(GNUSTEP_FND_DIR)

ifeq ($(FOUNDATION_LIB), fd)
  GNUSTEP_HEADERS_FND_DIRS += \
    $(GNUSTEP_USER_ROOT)/Headers/$(GNUSTEP_FND_DIR)/$(GNUSTEP_TARGET_DIR)/$(OBJC_RUNTIME) \
    $(GNUSTEP_LOCAL_ROOT)/Headers/$(GNUSTEP_FND_DIR)/$(GNUSTEP_TARGET_DIR)/$(OBJC_RUNTIME) \
    $(GNUSTEP_NETWORK_ROOT)/Headers/$(GNUSTEP_FND_DIR)/$(GNUSTEP_TARGET_DIR)/$(OBJC_RUNTIME) \
    $(GNUSTEP_SYSTEM_ROOT)/Headers/$(GNUSTEP_FND_DIR)/$(GNUSTEP_TARGET_DIR)/$(OBJC_RUNTIME)
endif

ifeq ($(REMOVE_EMPTY_DIRS),yes)
 # Build the GNUSTEP_HEADERS_FND_FLAG by removing the empty dirs
 # from GNUSTEP_HEADERS_FND_DIRS, then prepending -I to each of them
 GNUSTEP_HEADERS_FND_FLAG = \
  $(addprefix -I,$(foreach dir,$(GNUSTEP_HEADERS_FND_DIRS),$(remove_if_empty)))
else
 # default case - simply prepend -I
 GNUSTEP_HEADERS_FND_FLAG = $(addprefix -I,$(GNUSTEP_HEADERS_FND_DIRS))
endif

#
# Overridable compilation flags
#
OBJCFLAGS = $(OBJC_NO_IMPORT_FLAGS) 
CFLAGS =
OBJ_DIR_PREFIX =

#
# Now decide whether to build shared objects or not.  Nothing depending
# on the value of the shared variable is allowed before this point!
#

#
# Fixup bundles to be always built as shared even when shared=no is given
#
ifeq ($(shared), no)
  ifeq ($(GNUSTEP_TYPE), bundle)
    $(warning "Static bundles are meaningless!  I am using shared=yes!")
    override shared = yes
    export shared
  endif
endif

# Enable building shared libraries by default. If the user wants to build a
# static library, he/she has to specify shared=no explicitly.
ifeq ($(HAVE_SHARED_LIBS), yes)
  # Unless shared=no has been purposedly set ...
  ifneq ($(shared), no)
    # ... set shared = yes
    shared = yes
  endif
endif

ifeq ($(shared), yes)
  LIB_LINK_CMD              =  $(SHARED_LIB_LINK_CMD)
  OBJ_DIR_PREFIX            += shared_
  INTERNAL_OBJCFLAGS        += $(SHARED_CFLAGS)
  INTERNAL_CFLAGS           += $(SHARED_CFLAGS)
  AFTER_INSTALL_LIBRARY_CMD =  $(AFTER_INSTALL_SHARED_LIB_CMD)
else
  LIB_LINK_CMD              =  $(STATIC_LIB_LINK_CMD)
  OBJ_DIR_PREFIX            += static_
  AFTER_INSTALL_LIBRARY_CMD =  $(AFTER_INSTALL_STATIC_LIB_CMD)
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

ifeq ($(diagnose), no)
  ADDITIONAL_FLAGS += -UGSDIAGNOSE
else
  ADDITIONAL_FLAGS += -DGSDIAGNOSE
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
# The java compiler.
#
ifeq ($(JAVAC),)
  JAVAC = $(JAVA_HOME)/bin/javac
endif

#
# The java header compiler.
#
ifeq ($(JAVAH),)
  JAVAH = $(JAVA_HOME)/bin/javah
endif

#
# Common variables - default values
#
# Because this file is included at the beginning of the user's
# GNUmakefile, the user can override these variables by setting them
# in the GNUmakefile.
BUNDLE_EXTENSION = .bundle
ifeq ($(profile), yes)
  APP_EXTENSION = profile
else
  ifeq ($(debug), yes)
    APP_EXTENSION = debug
  else
    APP_EXTENSION = app
  endif
endif



# We want total control over GNUSTEP_INSTANCE.
# GNUSTEP_INSTANCE determines wheter it's a Master or an Instance
# invocation.  Whenever we run a submake, we want it to be a Master
# invocation, unless we specifically set it to run as an Instance
# invocation by adding the GNUSTEP_INSTANCE=xxx flag.  Tell make not
# to mess with our games by passing this variable to submakes himself
unexport GNUSTEP_INSTANCE
unexport GNUSTEP_TYPE

endif # COMMON_MAKE_LOADED

## Local variables:
## mode: makefile
## End:
