#
#   rules.make
#
#   Makefile rules for the Instance invocation.
#
#   Copyright (C) 1997, 2001, 2002 Free Software Foundation, Inc.
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

# Prevent multiple inclusions
ifeq ($(INSTANCE_RULES_MAKE_LOADED),)
INSTANCE_RULES_MAKE_LOADED=yes

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

# If we are using Windows32 DLLs, for each library that we link
# against, pass a -Dlib{library_name}_ISDLL=1 option to the
# preprocessor (for example, -Dlibgnustep_base_ISDLL=1 or
# -Dlibobjc_ISDLL=1).  This preprocessor define might be used by the
# library header files to know they are included from external code
# needing to use the library symbols, so that the library header files
# can in this case use __declspec(dllimport) to mark symbols as
# needing to be put into the import table for the
# executable/library/whatever that is being compiled.
ifeq ($(WITH_DLL),yes)
TMP_LIBS := $(LIBRARIES_DEPEND_UPON) $(BUNDLE_LIBS) $(ADDITIONAL_GUI_LIBS) $(ADDITIONAL_OBJC_LIBS) $(ADDITIONAL_LIBRARY_LIBS)
TMP_LIBS := $(filter -l%, $(TMP_LIBS))
# filter all non-static libs (static libs are those ending in _ds, _s, _ps..)
TMP_LIBS := $(filter-out -l%_ds, $(TMP_LIBS))
TMP_LIBS := $(filter-out -l%_s,  $(TMP_LIBS))
TMP_LIBS := $(filter-out -l%_dps,$(TMP_LIBS))
TMP_LIBS := $(filter-out -l%_ps, $(TMP_LIBS))
# strip away -l, _p and _d ..
TMP_LIBS := $(TMP_LIBS:-l%=%)
TMP_LIBS := $(TMP_LIBS:%_d=%)
TMP_LIBS := $(TMP_LIBS:%_p=%)
TMP_LIBS := $(TMP_LIBS:%_dp=%)
TMP_LIBS := $(shell echo $(TMP_LIBS)|tr '-' '_')
ALL_CPPFLAGS += $(TMP_LIBS:%=-Dlib%_ISDLL=1)
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

#
# The list of Objective-C source files to be compiled
# are in the OBJC_FILES variable.
#
# The list of C source files to be compiled
# are in the C_FILES variable.
#
# The list of C++ source files to be compiled
# are in the CC_FILES variable.
#
# The list of PSWRAP source files to be compiled
# are in the PSWRAP_FILES variable.
#
# The list of JAVA source files to be compiled
# are in the JAVA_FILES variable.
#
# The list of JAVA source files from which to generate jni headers
# are in the JAVA_JNI_FILES variable.
#

#
# Please note the subtle difference:
#
# At `user' level (ie, in the user's GNUmakefile), 
# the SUBPROJECTS variable is reserved for use with aggregate.make; 
# the xxx_SUBPROJECTS variable is reserved for use with subproject.make.
#
# This separation *must* be enforced strictly, because nothing prevents 
# a GNUmakefile from including both aggregate.make and subproject.make!
#
# For this reason, when we pass xxx_SUBPROJECTS to a submake invocation,
# we call the new variable _SUBPROJECTS rather than SUBPROJECTS
#

ifneq ($(_SUBPROJECTS),)
  SUBPROJECT_OBJ_FILES = $(foreach d, $(_SUBPROJECTS), \
    $(addprefix $(d)/, $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT)))
endif

OBJC_OBJS = $(OBJC_FILES:.m=${OEXT})
OBJC_OBJ_FILES = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(OBJC_OBJS))

JAVA_OBJS = $(JAVA_FILES:.java=.class)
JAVA_OBJ_FILES = $(JAVA_OBJS)

JAVA_JNI_OBJS = $(JAVA_JNI_FILES:.java=.h)
JAVA_JNI_OBJ_FILES = $(JAVA_JNI_OBJS)

PSWRAP_C_FILES = $(PSWRAP_FILES:.psw=.c)
PSWRAP_H_FILES = $(PSWRAP_FILES:.psw=.h)
PSWRAP_OBJS = $(PSWRAP_FILES:.psw=${OEXT})
PSWRAP_OBJ_FILES = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(PSWRAP_OBJS))

C_OBJS = $(C_FILES:.c=${OEXT})
C_OBJ_FILES = $(PSWRAP_OBJ_FILES) $(addprefix $(GNUSTEP_OBJ_DIR)/,$(C_OBJS))

# C++ files might end in .C, .cc, .cpp, .cxx, .cp so we replace multiple times
CC_OBJS = $(patsubst %.cc,%${OEXT},\
           $(patsubst %.C,%${OEXT},\
            $(patsubst %.cp,%${OEXT},\
             $(patsubst %.cpp,%${OEXT},\
              $(patsubst %.cxx,%${OEXT},$(CC_FILES))))))
CC_OBJ_FILES = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(CC_OBJS))

# OBJ_FILES_TO_LINK is the set of all .o files which will be linked
# into the result - please note that you can add to OBJ_FILES_TO_LINK
# by defining manually some special xxx_OBJ_FILES for your
# tool/app/whatever
OBJ_FILES_TO_LINK = $(C_OBJ_FILES) $(OBJC_OBJ_FILES) $(CC_OBJ_FILES) \
                    $(SUBPROJECT_OBJ_FILES) $(OBJ_FILES)

ifeq ($(AUTO_DEPENDENCIES),yes)
  ifneq ($(strip $(OBJ_FILES_TO_LINK)),)
    -include $(addsuffix .d, $(basename $(OBJ_FILES_TO_LINK)))
  endif
endif

# The rule to create the objects file directory.
$(GNUSTEP_OBJ_DIR):
	@($(MKDIRS) ./$(GNUSTEP_OBJ_DIR); \
	rm -f obj; \
	$(LN_S) ./$(GNUSTEP_OBJ_DIR) obj)

endif
# Instance/rules.make loaded

## Local variables:
## mode: makefile
## End:
