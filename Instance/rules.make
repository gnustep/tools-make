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

ifneq ($($(GNUSTEP_INSTANCE)_SUBPROJECTS),)
SUBPROJECT_OBJ_FILES = $(foreach d, $($(GNUSTEP_INSTANCE)_SUBPROJECTS), \
    $(addprefix $(d)/, $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT)))
endif

OBJC_OBJS = $(patsubst %.m,%$(OEXT),$($(GNUSTEP_INSTANCE)_OBJC_FILES))
OBJC_OBJ_FILES = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(OBJC_OBJS))

JAVA_OBJS = $(patsubst %.java,%.class,$($(GNUSTEP_INSTANCE)_JAVA_FILES))
JAVA_OBJ_FILES = $(JAVA_OBJS)

JAVA_JNI_OBJS = $(patsubst %.java,%.h,$($(GNUSTEP_INSTANCE)_JAVA_JNI_FILES))
JAVA_JNI_OBJ_FILES = $(JAVA_JNI_OBJS)

PSWRAP_C_FILES = $(patsubst %.psw,%.c,$($(GNUSTEP_INSTANCE)_PSWRAP_FILES))
PSWRAP_H_FILES = $(patsubst %.psw,%.h,$($(GNUSTEP_INSTANCE)_PSWRAP_FILES))
PSWRAP_OBJS = $(patsubst %.psw,%$(OEXT),$($(GNUSTEP_INSTANCE)_PSWRAP_FILES))
PSWRAP_OBJ_FILES = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(PSWRAP_OBJS))

C_OBJS = $(patsubst %.c,%$(OEXT),$($(GNUSTEP_INSTANCE)_C_FILES))
C_OBJ_FILES = $(PSWRAP_OBJ_FILES) $(addprefix $(GNUSTEP_OBJ_DIR)/,$(C_OBJS))

# C++ files might end in .C, .cc, .cpp, .cxx, .cp so we replace multiple times
CC_OBJS = $(patsubst %.cc,%$(OEXT),\
           $(patsubst %.C,%$(OEXT),\
            $(patsubst %.cp,%$(OEXT),\
             $(patsubst %.cpp,%$(OEXT),\
              $(patsubst %.cxx,%$(OEXT),$($(GNUSTEP_INSTANCE)_CC_FILES))))))
CC_OBJ_FILES = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(CC_OBJS))

OBJ_FILES = $($(GNUSTEP_INSTANCE)_OBJ_FILES)

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

endif
# Instance/rules.make loaded

## Local variables:
## mode: makefile
## End:
