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
SUBPROJECT_ROOT_DIR := "."

ifeq ($(GNUSTEP_MAKE_INSTANCE_INVOCATION),)
include $(GNUSTEP_MAKEFILES)/Master/rules.make
endif

# Always include the Instance rules.  The reason is that the user, in
# his GNUmakefile.postamble, might want to add manual commands for
# example to after-all, which are processed during the Master
# invocation, but yet are actually instance invocation rules, and so
# need access to all the variables to build Instance invocation rules.
include $(GNUSTEP_MAKEFILES)/Instance/rules.make


# The following dummy rules are needed for performance - we need to
# prevent make from spending time trying to compute how/if to rebuild
# the system makefiles!  the following rules tell him that these files
# are always up-to-date

$(GNUSTEP_MAKEFILES)/*.make: ;

$(GNUSTEP_MAKEFILES)/$(GNUSTEP_TARGET_DIR)/config.make: ;

$(GNUSTEP_MAKEFILES)/Additional/*.make: ;

$(GNUSTEP_MAKEFILES)/Master/*.make: ;

$(GNUSTEP_MAKEFILES)/Instance/*.make: ;

endif
# rules.make loaded

## Local variables:
## mode: makefile
## End:
