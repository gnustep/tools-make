#
#   rules.make
#
#   All of the common makefile rules.
#
#   Copyright (C) 1997, 2001 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
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

# prevent multiple inclusions

# NB: This file is internally protected against multiple inclusions.
# But for perfomance reasons, you might want to check the
# RULES_MAKE_LOADED variable yourself and include this file only if it
# is empty.  That allows make to skip reading the file entirely when it 
# has already been read.  We use this trick for all system makefiles.
ifeq ($(RULES_MAKE_LOADED),)
RULES_MAKE_LOADED=yes

# Include the Master rules at the beginning because the 'all' rule must be
# first on the first invocation without a specified target.
ifeq ($(GNUSTEP_INSTANCE),)
include $(GNUSTEP_MAKEFILES)/Master/rules.make
endif

#
# If INSTALL_AS_USER and/or INSTALL_AS_GROUP are defined, pass them down
# to submakes.  There are two reasons - 
#
# 1. so that if you set them in a GNUmakefile, they get passed down
#    to automatically generated sources/GNUmakefiles (such as Java wrappers)
# 2. so that if you type `make install INSTALL_AS_USER=nicola' in a directory,
#    the INSTALL_AS_USER=nicola gets automatically used in all subdirectories.
#
# Warning - if you want to hardcode a INSTALL_AS_USER in a GNUmakefile, then
# you shouldn't rely on us to pass it down to subGNUmakefiles - you should
# rather hardcode INSTALL_AS_USER in all your GNUmakefiles (or better have
# a makefile fragment defining INSTALL_AS_USER in the top-level and include
# it in all GNUmakefiles) - otherwise what happens is that if you go in a
# subdirectory and type 'make install' there, it will not get the 
# INSTALL_AS_USER from the higher level GNUmakefile, so it will install with
# the wrong user!  For this reason, if you need to hardcode INSTALL_AS_USER
# in GNUmakefiles, make sure it's hardcoded *everywhere*.
#
ifneq ($(INSTALL_AS_USER),)
  export INSTALL_AS_USER
endif

ifneq ($(INSTALL_AS_GROUP),)
  export INSTALL_AS_GROUP
endif


# FIXME - what to do with these
FRAMEWORK_NAME := $(strip $(FRAMEWORK_NAME))
FRAMEWORK_DIR_NAME := $(FRAMEWORK_NAME:=.framework)
FRAMEWORK_VERSION_DIR_NAME := $(FRAMEWORK_DIR_NAME)/Versions/$(CURRENT_VERSION_NAME)
DERIVED_SOURCES = derived_src

# Always include all the compilation flags and generic compilation
# rules, because the user, in his GNUmakefile.postamble, might want to
# add manual commands for example to after-all, which are processed
# during the Master invocation, but yet can compile or install stuff
# and need access to all compilation/installation flags and locations
# and basic rules.

#
# Manage stripping
#
ifeq ($(strip),yes)
INSTALL_PROGRAM += -s
export strip
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

#
# If this is part of the compilation of a framework,
# add -I[../../../etc]derived_src so that the code can include 
# framework headers simply using `#include <MyFramework/MyHeader.h>'
#
ifneq ($(FRAMEWORK_NAME),)
CURRENT_FRAMEWORK_HEADERS_FLAG = -I$(DERIVED_SOURCES)
endif

#
# Include rules to built the instance
#
# this fixes up ADDITIONAL_XXXFLAGS as well, which is why we include it
# before using ADDITIONAL_XXXFLAGS
#
ifneq ($(GNUSTEP_INSTANCE),)
include $(GNUSTEP_MAKEFILES)/Instance/rules.make
endif

#
# Auto dependencies
#
# -MMD -MP tells gcc to generate a .d file for each compiled file, 
# which includes makefile rules adding dependencies of the compiled
# file on all the header files the source file includes ...
#
# next time `make' is run, we include the .d files for the previous
# run (if we find them) ... this automatically adds dependencies on
# the appropriate header files 
#

# Warning - the following variable name might change
ifeq ($(AUTO_DEPENDENCIES),yes)
ifeq ($(AUTO_DEPENDENCIES_FLAGS),)
  AUTO_DEPENDENCIES_FLAGS = -MMD -MP
endif
endif

# The difference between ADDITIONAL_XXXFLAGS and AUXILIARY_XXXFLAGS is the
# following:
#
#  ADDITIONAL_XXXFLAGS are set freely by the user GNUmakefile
#
#  AUXILIARY_XXXFLAGS are set freely by makefile fragments installed by
#                     auxiliary packages.  For example, gnustep-db installs
#                     a gdl.make file.  If you want to use gnustep-db in
#                     your tool, you `include $(GNUSTEP_MAKEFILES)/gdl.make'
#                     and that will add the appropriate flags to link against
#                     gnustep-db.  Those flags are added to AUXILIARY_XXXFLAGS.
#
# Why can't ADDITIONAL_XXXFLAGS and AUXILIARY_XXXFLAGS be the same variable ?
# Good question :-) I'm not sure but I think the original reason is that 
# users tend to think they can do whatever they want with ADDITIONAL_XXXFLAGS,
# like writing 
# ADDITIONAL_XXXFLAGS = -Verbose
# (with a '=' instead of a '+=', thus discarding the previous value of
# ADDITIONAL_XXXFLAGS) without caring for the fact that other makefiles 
# might need to add something to ADDITIONAL_XXXFLAGS.
#
# So the idea is that ADDITIONAL_XXXFLAGS is reserved for the users to
# do whatever mess they like with them, while in makefile fragments
# from packages we use a different variable, which is subject to a stricter 
# control, requiring package authors to always write
#
#  AUXILIARY_XXXFLAGS += -Verbose
#
# in their auxiliary makefile fragments, to make sure they don't
# override flags from different packages, just add to them.
#
# When building up command lines inside gnustep-make, we always need
# to add both AUXILIARY_XXXFLAGS and ADDITIONAL_XXXFLAGS to all
# compilation/linking/etc command.
#

ALL_CPPFLAGS = $(AUTO_DEPENDENCIES_FLAGS) $(CPPFLAGS) $(ADDITIONAL_CPPFLAGS) \
               $(AUXILIARY_CPPFLAGS)

ALL_OBJCFLAGS = $(INTERNAL_OBJCFLAGS) $(ADDITIONAL_OBJCFLAGS) \
   $(AUXILIARY_OBJCFLAGS) $(ADDITIONAL_INCLUDE_DIRS) \
   $(AUXILIARY_INCLUDE_DIRS) \
   $(CURRENT_FRAMEWORK_HEADERS_FLAG) \
   -I. $(SYSTEM_INCLUDES) \
   $(GNUSTEP_HEADERS_FND_FLAG) $(GNUSTEP_HEADERS_GUI_FLAG) \
   $(GNUSTEP_HEADERS_FLAGS)

ALL_CFLAGS = $(INTERNAL_CFLAGS) $(ADDITIONAL_CFLAGS) \
   $(AUXILIARY_CFLAGS) $(ADDITIONAL_INCLUDE_DIRS) \
   $(AUXILIARY_INCLUDE_DIRS) \
   $(CURRENT_FRAMEWORK_HEADERS_FLAG) \
   -I. $(SYSTEM_INCLUDES) \
   $(GNUSTEP_HEADERS_FND_FLAG) $(GNUSTEP_HEADERS_GUI_FLAG) \
   $(GNUSTEP_HEADERS_FLAGS) 

# if you need, you can define ADDITIONAL_CCFLAGS to add C++ specific flags
ALL_CCFLAGS = $(ADDITIONAL_CCFLAGS) $(AUXILIARY_CCFLAGS)

INTERNAL_CLASSPATHFLAGS = -classpath ./$(subst ::,:,:$(strip $(ADDITIONAL_CLASSPATH)):)$(CLASSPATH)

ALL_JAVACFLAGS = $(INTERNAL_CLASSPATHFLAGS) $(INTERNAL_JAVACFLAGS) \
$(ADDITIONAL_JAVACFLAGS) $(AUXILIARY_JAVACFLAGS)

ALL_JAVAHFLAGS = $(INTERNAL_CLASSPATHFLAGS) $(ADDITIONAL_JAVAHFLAGS) \
$(AUXILIARY_JAVAHFLAGS)

ALL_JAVADOCFLAGS = $(INTERNAL_CLASSPATHFLAGS) $(INTERNAL_JAVADOCFLAGS) \
$(ADDITIONAL_JAVADOCFLAGS) $(AUXILIARY_JAVADOCFLAGS)

ALL_LDFLAGS = $(ADDITIONAL_LDFLAGS) $(AUXILIARY_LDFLAGS) $(GUI_LDFLAGS) \
   $(BACKEND_LDFLAGS) $(SYSTEM_LDFLAGS) $(INTERNAL_LDFLAGS)

ALL_LIB_DIRS = $(ADDITIONAL_FRAMEWORK_DIRS) $(AUXILIARY_FRAMEWORK_DIRS) \
   $(ADDITIONAL_LIB_DIRS) $(AUXILIARY_LIB_DIRS) \
   $(GNUSTEP_LIBRARIES_FLAGS) \
   $(SYSTEM_LIB_DIR)

# If we are using Windows32 DLLs, we pass -DGNUSTEP_WITH_DLL to the
# compiler.  This preprocessor define might be used by library header
# files to know they are included from external code needing to use
# the library symbols, so that the library header files can in this
# case use __declspec(dllimport) to mark symbols as needing to be put
# into the import table for the executable/library/whatever that is
# being compiled.
ifeq ($(WITH_DLL),yes)
ALL_CPPFLAGS += -DGNUSTEP_WITH_DLL
endif

# General rules
VPATH = .

.SUFFIXES: .m .c .psw .java .h .cpp .cxx .C .cc .cp

.PRECIOUS: %.c %.h $(GNUSTEP_OBJ_DIR)/%${OEXT}

#
# In exceptional conditions, you might need to want to use different compiler
# flags for a file (for example, if a file doesn't compile with optimization
# turned on, you might want to compile that single file with optimizations
# turned off).  gnustep-make allows you to do this - you can specify special 
# flags to be used when compiling a *specific* file in two ways - 
#
# xxx_FILE_FLAGS (where xxx is the file name, such as main.m) 
#                are special compilation flags to be used when compiling xxx
#
# xxx_FILE_FILTER_OUT_FLAGS (where xxx is the file name, such as mframe.m)
#                is a filter-out make pattern of flags to be filtered out 
#                from the compilation flags when compiling xxx.
#
# Typical examples:
#
# Disable optimization flags for the file NSInvocation.m:
# NSInvocation.m_FILE_FILTER_OUT_FLAGS = -O%
#
# Disable optimization flags for the same file, and also remove 
# -fomit-frame-pointer:
# NSInvocation.m_FILE_FILTER_OUT_FLAGS = -O% -fomit-frame-pointer
#
# Force the compiler to warn for #import if used in file file.m:
# file.m_FILE_FLAGS = -Wimport
# file.m_FILE_FILTER_OUT_FLAGS = -Wno-import
#

# Please don't be scared by the following rules ... In normal
# situations, $<_FILTER_OUT_FLAGS is empty, and $<_FILE_FLAGS is empty
# as well, so the following rule is simply equivalent to
# $(CC) $< -c $(ALL_CPPFLAGS) $(ALL_CFLAGS) -o $@
# and similarly all the rules below
$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.c
	$(CC) $< -c \
	      $(filter-out $($<_FILE_FILTER_OUT_FLAGS),$(ALL_CPPFLAGS) \
	                                                $(ALL_CFLAGS)) \
	      $($<_FILE_FLAGS) -o $@

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.m
	$(CC) $< -c \
	      $(filter-out $($<_FILE_FILTER_OUT_FLAGS),$(ALL_CPPFLAGS) \
	                                                $(ALL_OBJCFLAGS)) \
	      $($<_FILE_FLAGS) -o $@

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.C
	$(CC) $< -c \
	      $(filter-out $($<_FILE_FILTER_OUT_FLAGS),$(ALL_CPPFLAGS) \
	                                                $(ALL_CFLAGS)   \
	                                                $(ALL_CCFLAGS)) \
	      $($<_FILE_FLAGS) -o $@

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.cc
	$(CC) $< -c \
	      $(filter-out $($<_FILE_FILTER_OUT_FLAGS),$(ALL_CPPFLAGS) \
	                                                $(ALL_CFLAGS)   \
	                                                $(ALL_CCFLAGS)) \
	      $($<_FILE_FLAGS) -o $@

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.cpp
	$(CC) $< -c \
	      $(filter-out $($<_FILE_FILTER_OUT_FLAGS),$(ALL_CPPFLAGS) \
	                                                $(ALL_CFLAGS)   \
	                                                $(ALL_CCFLAGS)) \
	      $($<_FILE_FLAGS) -o $@

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.cxx
	$(CC) $< -c \
	      $(filter-out $($<_FILE_FILTER_OUT_FLAGS),$(ALL_CPPFLAGS) \
	                                                $(ALL_CFLAGS)   \
	                                                $(ALL_CCFLAGS)) \
	      $($<_FILE_FLAGS) -o $@

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.cp
	$(CC) $< -c \
	      $(filter-out $($<_FILE_FILTER_OUT_FLAGS),$(ALL_CPPFLAGS) \
	                                                $(ALL_CFLAGS)   \
	                                                $(ALL_CCFLAGS)) \
	      $($<_FILE_FLAGS) -o $@

%.class : %.java
	$(JAVAC) \
	         $(filter-out $($<_FILE_FILTER_OUT_FLAGS),$(ALL_JAVACFLAGS)) \
	         $($<_FILE_FLAGS) $<

# A jni header file which is created using JAVAH
# Example of how this rule will be applied: 
# gnu/gnustep/base/NSObject.h : gnu/gnustep/base/NSObject.java
#	javah -o gnu/gnustep/base/NSObject.h gnu.gnustep.base.NSObject
%.h : %.java
	$(JAVAH) \
	         $(filter-out $($<_FILE_FILTER_OUT_FLAGS),$(ALL_JAVAHFLAGS)) \
	         $($<_FILE_FLAGS) -o $@ $(subst /,.,$*) 

%.c : %.psw
	pswrap -h $*.h -o $@ $<

# The following rule is needed because in frameworks you might need
# the .h files before the .c files are compiled.
%.h : %.psw
	pswrap -h $@ -o $*.c $<

# The following dummy rules are needed for performance - we need to
# prevent make from spending time trying to compute how/if to rebuild
# the system makefiles!  the following rules tell him that these files
# are always up-to-date

$(GNUSTEP_MAKEFILES)/*.make: ;

$(GNUSTEP_MAKEFILES)/$(GNUSTEP_TARGET_DIR)/config.make: ;

$(GNUSTEP_MAKEFILES)/Additional/*.make: ;

$(GNUSTEP_MAKEFILES)/Master/*.make: ;

$(GNUSTEP_MAKEFILES)/Instance/*.make: ;

# The rule to create the objects file directory.
$(GNUSTEP_OBJ_DIR):
	@($(MKDIRS) ./$(GNUSTEP_OBJ_DIR); \
	rm -f obj; \
	$(LN_S) ./$(GNUSTEP_OBJ_DIR) obj)

endif
# rules.make loaded

## Local variables:
## mode: makefile
## End:
