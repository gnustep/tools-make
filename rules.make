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
# Quick explanation - 
#
# Say that you run `make all'.  The rule for `all' is below here, and
# depends on internal-all.  Rules for internal-all are found in
# tool.make, library.make etc; there, internal-all will depend on a
# list of appropriate %.variables targets, such as
# gsdoc.tool.all.variables <which means we need to make `all' for the
# `tool' called `gsdoc'> - to process these prerequisites, the
# %.variables rule below is used.  this rule gets an appropriate make
# subprocess going, with the task of building that specific
# target-type-operation prerequisite.  The make subprocess will be run
# as in `make internal-tool-all INTERNAL_tool_NAME=gsdoc ...<and other
# variables>' and this make subprocess wil find the internal-tool-all
# rule in tool.make, and execute that, building the tool.
#
# Hint: run make with `make -n' to see the recursive method invocations 
#       with the parameters used
#

#
# Global targets
#

# The first time you invoke `make', if you have not given a target,
# `all' is executed as it is the first one.
all:: before-all internal-all after-all

# internal-after-install is used by packaging to get the list of files 
# installed (see rpm.make); it must come after *all* the installation 
# rules have been executed.
ifeq ($(MAKELEVEL),0)
install:: all \
          before-install internal-install after-install internal-after-install
else
install:: before-install internal-install after-install internal-after-install
endif

uninstall:: before-uninstall internal-uninstall after-uninstall

clean:: before-clean internal-clean after-clean

ifeq ($(MAKELEVEL),0)
distclean:: clean before-distclean internal-distclean after-distclean
else 
distclean:: before-distclean internal-distclean after-distclean
endif

check:: before-check internal-check after-check

#
# Placeholders for internal targets
#

before-all::

internal-all::

after-all::

before-install::

internal-install::

after-install::

# The following for exclusive use of packaging code
internal-after-install::

before-uninstall::

internal-uninstall::

after-uninstall::

before-clean::

internal-clean::
	rm -rf *~ obj

after-clean::

before-distclean::

internal-distclean::

after-distclean::

before-check::

internal-check::

after-check::

# declare targets as PHONY

.PHONY: all before-all internal-all after-all \
	 install before-install internal-install after-install \
	         internal-after-install \
	 uninstall before-uninstall internal-uninstall after-uninstall \
	 clean before-clean internal-clean after-clean \
	 distclean before-distclean internal-distclean after-distclean \
	 check before-check internal-check after-check

# The following dummy rules are needed for performance - we need to
# prevent make from spending time trying to compute how/if to rebuild
# the system makefiles!  the following rules tell him that these files
# are always up-to-date

$(GNUSTEP_MAKEFILES)/*.make: ;

$(GNUSTEP_MAKEFILES)/$(GNUSTEP_TARGET_DIR)/config.make: ;

$(GNUSTEP_MAKEFILES)/Additional/*.make: ;


ALL_CPPFLAGS = $(CPPFLAGS) $(ADDITIONAL_CPPFLAGS) $(AUXILIARY_CPPFLAGS)

ALL_OBJCFLAGS = $(INTERNAL_OBJCFLAGS) $(ADDITIONAL_OBJCFLAGS) \
   $(AUXILIARY_OBJCFLAGS) $(ADDITIONAL_INCLUDE_DIRS) \
   $(AUXILIARY_INCLUDE_DIRS) -I. $(SYSTEM_INCLUDES) \
   $(GNUSTEP_USER_FRAMEWORKS_HEADERS_FLAG) \
   $(GNUSTEP_LOCAL_FRAMEWORKS_HEADERS_FLAG) \
   $(GNUSTEP_NETWORK_FRAMEWORKS_HEADERS_FLAG) \
   -I$(GNUSTEP_SYSTEM_FRAMEWORKS_HEADERS) \
   $(GNUSTEP_HEADERS_FND_FLAG) $(GNUSTEP_HEADERS_GUI_FLAG) \
   $(GNUSTEP_HEADERS_TARGET_FLAG) $(GNUSTEP_USER_HEADERS_FLAG) \
   $(GNUSTEP_LOCAL_HEADERS_FLAG) $(GNUSTEP_NETWORK_HEADERS_FLAG) \
   -I$(GNUSTEP_SYSTEM_HEADERS) 

ALL_CFLAGS = $(INTERNAL_CFLAGS) $(ADDITIONAL_CFLAGS) \
   $(AUXILIARY_CFLAGS) $(ADDITIONAL_INCLUDE_DIRS) \
   $(AUXILIARY_INCLUDE_DIRS) -I. $(SYSTEM_INCLUDES) \
   $(GNUSTEP_USER_FRAMEWORKS_HEADERS_FLAG) \
   $(GNUSTEP_LOCAL_FRAMEWORKS_HEADERS_FLAG) \
   $(GNUSTEP_NETWORK_FRAMEWORKS_HEADERS_FLAG) \
   -I$(GNUSTEP_SYSTEM_FRAMEWORKS_HEADERS) \
   $(GNUSTEP_HEADERS_FND_FLAG) $(GNUSTEP_HEADERS_GUI_FLAG) \
   $(GNUSTEP_HEADERS_TARGET_FLAG) $(GNUSTEP_USER_HEADERS_FLAG) \
   $(GNUSTEP_LOCAL_HEADERS_FLAG) $(GNUSTEP_NETWORK_HEADERS_FLAG) \
   -I$(GNUSTEP_SYSTEM_HEADERS)

INTERNAL_CLASSPATHFLAGS = -classpath ./$(subst ::,:,:$(strip $(ADDITIONAL_CLASSPATH)):)$(CLASSPATH)

ALL_JAVACFLAGS = $(INTERNAL_CLASSPATHFLAGS) $(ADDITIONAL_JAVACFLAGS) \
$(AUXILIARY_JAVACFLAGS)

ALL_JAVAHFLAGS = $(INTERNAL_CLASSPATHFLAGS) $(ADDITIONAL_JAVAHFLAGS) \
$(AUXILIARY_JAVAHFLAGS)

ALL_JAVADOCFLAGS = $(INTERNAL_CLASSPATHFLAGS) $(ADDITIONAL_JAVADOCFLAGS) \
$(AUXILIARY_JAVADOCFLAGS)

ALL_LDFLAGS = $(ADDITIONAL_LDFLAGS) $(AUXILIARY_LDFLAGS) $(GUI_LDFLAGS) \
   $(BACKEND_LDFLAGS) $(SYSTEM_LDFLAGS) $(INTERNAL_LDFLAGS)

ALL_FRAMEWORK_DIRS = $(ADDITIONAL_FRAMEWORK_DIRS) $(AUXILIARY_FRAMEWORK_DIRS) \
   $(GNUSTEP_USER_FRAMEWORKS_LIBRARIES_FLAG) \
   $(GNUSTEP_LOCAL_FRAMEWORKS_LIBRARIES_FLAG) \
   $(GNUSTEP_NETWORK_FRAMEWORKS_LIBRARIES_FLAG) \
   -L$(GNUSTEP_SYSTEM_FRAMEWORKS_LIBRARIES)

ALL_LIB_DIRS = $(ADDITIONAL_LIB_DIRS) $(AUXILIARY_LIB_DIRS) \
   $(GNUSTEP_USER_LIBRARIES_FLAG) $(GNUSTEP_USER_TARGET_LIBRARIES_FLAG) \
   $(GNUSTEP_LOCAL_LIBRARIES_FLAG) $(GNUSTEP_LOCAL_TARGET_LIBRARIES_FLAG) \
   $(GNUSTEP_NETWORK_LIBRARIES_FLAG) $(GNUSTEP_NETWORK_TARGET_LIBRARIES_FLAG) \
   -L$(GNUSTEP_SYSTEM_LIBRARIES) -L$(GNUSTEP_SYSTEM_TARGET_LIBRARIES) \
   $(SYSTEM_LIB_DIR)

LIB_DIRS_NO_SYSTEM = $(ADDITIONAL_LIB_DIRS) \
   $(GNUSTEP_USER_LIBRARIES_FLAG) $(GNUSTEP_USER_TARGET_LIBRARIES_FLAG) \
   $(GNUSTEP_LOCAL_LIBRARIES_FLAG) $(GNUSTEP_LOCAL_TARGET_LIBRARIES_FLAG) \
   $(GNUSTEP_NETWORK_LIBRARIES_FLAG) $(GNUSTEP_NETWORK_TARGET_LIBRARIES_FLAG) \
   -L$(GNUSTEP_SYSTEM_LIBRARIES) -L$(GNUSTEP_SYSTEM_TARGET_LIBRARIES)

#
# The bundle extension (default is .bundle) is defined by BUNDLE_EXTENSION.
#
ifeq ($(strip $(BUNDLE_EXTENSION)),)
BUNDLE_EXTENSION = .bundle
endif


# General rules
VPATH = .

.SUFFIXES: .m .c .psw .java .h

.PRECIOUS: %.c %.h $(GNUSTEP_OBJ_DIR)/%${OEXT}

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.c
	$(CC) $< -c $(ALL_CPPFLAGS) $(ALL_CFLAGS) -o $@

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.m
	$(CC) $< -c $(ALL_CPPFLAGS) $(ALL_OBJCFLAGS) -o $@

%.class : %.java
	$(JAVAC) $(ALL_JAVACFLAGS) $<

# A jni header file which is created using JAVAH
# Example of how this rule will be applied: 
# gnu/gnustep/base/NSObject.h : gnu/gnustep/base/NSObject.java
#	javah -o gnu/gnustep/base/NSObject.h gnu.gnustep.base.NSObject
%.h : %.java
	$(JAVAH) $(ALL_JAVAHFLAGS) -o $@ $(subst /,.,$*) 

%.c : %.psw
	pswrap -h $*.h -o $@ $<


# Prevent make from trying to remove stuff like
# libcool.library.all.subprojects thinking that it is a temporary file
.PRECIOUS: %.variables %.tools %.subprojects

#
## The magical %.variables rules, thank you GNU make!
#

# The %.variables target has to be called with the name of the actual
# target, followed by the operation, then the makefile fragment to be
# called and then the variables word. Suppose for example we build the
# library libgmodel, the target should look like:
#
#	libgmodel.all.library.variables
#
# when the rule is executed, $* is libgmodel.all.libray;
#  target will be libgmodel
#  operation will be all
#  type will be library 
#
# this rule might be executed many times, for different targets to build.

# the rule then calls a submake, which runs the real code

# The following functions are used in the %.variables, %.tools,
# %.subprojects rules to extract the target, operation and type from
# the $* (the stem) of the rule.  for example, $(call target,$*) will
# be the target.
target=$(basename $(basename $(1)))
operation=$(subst .,,$(suffix $(basename $(1))))
type=$(subst -,_,$(subst .,,$(suffix $(1))))

# Before building the real thing, we must build framework tools if
# any, then subprojects (FIXME - not sure - at what stage should we
# build framework tools ? perhaps after the framework so we can link
# with it ?)
%.variables: %.tools %.subprojects
	@ echo Making $(call operation,$*) for $(call type,$*) $(call target,$*)...; \
	$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going \
	    internal-$(call type,$*)-$(call operation,$*) \
	    INTERNAL_$(call type,$*)_NAME=$(call target,$*) \
	    TARGET=$(call target,$*) \
	    _SUBPROJECTS="$($(call target,$*)_SUBPROJECTS)" \
	    OBJC_FILES="$($(call target,$*)_OBJC_FILES)" \
	    C_FILES="$($(call target,$*)_C_FILES)" \
	    JAVA_FILES="$($(call target,$*)_JAVA_FILES)" \
	    JAVA_JNI_FILES="$($(call target,$*)_JAVA_JNI_FILES)" \
	    OBJ_FILES="$($(call target,$*)_OBJ_FILES)" \
	    PSWRAP_FILES="$($(call target,$*)_PSWRAP_FILES)" \
	    HEADER_FILES="$($(call target,$*)_HEADER_FILES)" \
	    TEXI_FILES="$($(call target,$*)_TEXI_FILES)" \
	    GSDOC_FILES="$($(call target,$*)_GSDOC_FILES)" \
	    LATEX_FILES="$($(call target,$*)_LATEX_FILES)" \
	    JAVADOC_FILES="$($(call target,$*)_JAVADOC_FILES)" \
	    JAVADOC_SOURCEPATH="$($(call target,$*)_JAVADOC_SOURCEPATH)" \
	    DOC_INSTALL_DIR="$($(call target,$*)_DOC_INSTALL_DIR)" \
	    TEXT_MAIN="$($(call target,$*)_TEXT_MAIN)" \
	    HEADER_FILES_DIR="$($(call target,$*)_HEADER_FILES_DIR)" \
	    HEADER_FILES_INSTALL_DIR="$($(call target,$*)_HEADER_FILES_INSTALL_DIR)" \
	    COMPONENTS="$($(call target,$*)_COMPONENTS)" \
	    LANGUAGES="$($(call target,$*)_LANGUAGES)" \
	    HAS_GSWCOMPONENTS="$($(call target,$*)_HAS_GSWCOMPONENTS)" \
	    GSWAPP_INFO_PLIST="$($(call target,$*)_GSWAPP_INFO_PLIST)" \
	    WEBSERVER_RESOURCE_FILES="$($(call target,$*)_WEBSERVER_RESOURCE_FILES)" \
	    LOCALIZED_WEBSERVER_RESOURCE_FILES="$($(call target,$*)_LOCALIZED_WEBSERVER_RESOURCE_FILES)" \
	    WEBSERVER_RESOURCE_DIRS="$($(call target,$*)_WEBSERVER_RESOURCE_DIRS)" \
	    LOCALIZED_RESOURCE_FILES="$($(call target,$*)_LOCALIZED_RESOURCE_FILES)" \
	    RESOURCE_FILES="$($(call target,$*)_RESOURCE_FILES)" \
	    MAIN_MODEL_FILE="$($(call target,$*)_MAIN_MODEL_FILE)" \
	    RESOURCE_DIRS="$($(call target,$*)_RESOURCE_DIRS)" \
	    BUNDLE_LIBS="$($(call target,$*)_BUNDLE_LIBS) $(BUNDLE_LIBS)" \
	    SERVICE_INSTALL_DIR="$($(call target,$*)_SERVICE_INSTALL_DIR)" \
	    APPLICATION_ICON="$($(call target,$*)_APPLICATION_ICON)" \
	    PALETTE_ICON="$($(call target,$*)_PALETTE_ICON)" \
	    PRINCIPAL_CLASS="$($(call target,$*)_PRINCIPAL_CLASS)" \
	    DLL_DEF="$($(call target,$*)_DLL_DEF)" \
	    ADDITIONAL_INCLUDE_DIRS="$(ADDITIONAL_INCLUDE_DIRS) \
					$($(call target,$*)_INCLUDE_DIRS)" \
	    ADDITIONAL_GUI_LIBS="$($(call target,$*)_GUI_LIBS) \
                                 $(ADDITIONAL_GUI_LIBS)" \
	    ADDITIONAL_TOOL_LIBS="$($(call target,$*)_TOOL_LIBS) \
                                  $(ADDITIONAL_TOOL_LIBS)" \
	    ADDITIONAL_OBJC_LIBS="$($(call target,$*)_OBJC_LIBS) \
                                  $(ADDITIONAL_OBJC_LIBS)" \
	    ADDITIONAL_LIBRARY_LIBS="$($(call target,$*)_LIBS) \
                                     $($(call target,$*)_LIBRARY_LIBS) \
                                     $(ADDITIONAL_LIBRARY_LIBS)" \
	    ADDITIONAL_LIB_DIRS="$($(call target,$*)_LIB_DIRS) \
                                 $(ADDITIONAL_LIB_DIRS)" \
	    ADDITIONAL_LDFLAGS="$($(call target,$*)_LDFLAGS) \
                                $(ADDITIONAL_LDFLAGS)" \
	    ADDITIONAL_CLASSPATH="$($(call target,$*)_CLASSPATH) \
                                  $(ADDITIONAL_CLASSPATH)" \
	    LIBRARIES_DEPEND_UPON="$(shell $(WHICH_LIB_SCRIPT) \
		$($(call target,$*)_LIB_DIRS) $(ADDITIONAL_LIB_DIRS) \
                $(ALL_LIB_DIRS) $(LIBRARIES_DEPEND_UPON) \
		$($(call target,$*)_LIBRARIES_DEPEND_UPON) debug=$(debug) \
                profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
		shared_libext=$(SHARED_LIBEXT))" \
	    SCRIPTS_DIRECTORY="$($(call target,$*)_SCRIPTS_DIRECTORY)" \
	    CHECK_SCRIPT_DIRS="$($(call target,$*)_SCRIPT_DIRS)"


ifneq ($(FRAMEWORK_NAME),)
#
# This rule is executed only for frameworks to build the framework tools.
# It is currently executed before %.subprojects (FIXME order).
#
%.tools:
	@ if [ "$(call operation,$*)" != "build-headers" ]; then \
	  if [ "$($(call target,$*)_TOOLS)" != "" ]; then \
	    echo Building tools for $(call type,$*) $(call target,$*)...; \
	    for f in $($(call target,$*)_TOOLS); do \
	      mf=$(MAKEFILE_NAME); \
	      if [ ! -f $$f/$$mf -a -f $$f/Makefile ]; then \
	        mf=Makefile; \
	        echo "WARNING: No $(MAKEFILE_NAME) found for tool $$f; using 'Makefile'"; \
	      fi; \
	      if $(MAKE) -C $$f -f $$mf --no-keep-going $(call operation,$*) \
	           FRAMEWORK_NAME="$(FRAMEWORK_NAME)" \
	           FRAMEWORK_VERSION_DIR_NAME="../$(FRAMEWORK_VERSION_DIR_NAME)" \
	           FRAMEWORK_OPERATION="$(call operation,$*)" \
	           TOOL_OPERATION="$(call operation,$*)" \
	           DERIVED_SOURCES="../$(DERIVED_SOURCES)" \
	           SUBPROJECT_ROOT_DIR="$(SUBPROJECT_ROOT_DIR)/$$f" \
	         ; then \
	         :; \
	      else exit $$?; \
	      fi; \
	    done; \
	  fi; \
	fi
else # no FRAMEWORK
%.tools: ;
endif # end of FRAMEWORK code

#
# This rule is executed before %.variables to process (eventual) subprojects
#
%.subprojects:
	@ if [ "$($(call target,$*)_SUBPROJECTS)" != "" ]; then \
	echo Making $(call operation,$*) in subprojects of $(call type,$*) $(call target,$*)...; \
	for f in $($(call target,$*)_SUBPROJECTS); do \
	  mf=$(MAKEFILE_NAME); \
	  if [ ! -f $$f/$$mf -a -f $$f/Makefile ]; then \
	    mf=Makefile; \
	    echo "WARNING: No $(MAKEFILE_NAME) found for subproject $$f; using 'Makefile'"; \
	  fi; \
	  if $(MAKE) -C $$f -f $$mf --no-keep-going $(call operation,$*) \
	        FRAMEWORK_NAME="$(FRAMEWORK_NAME)" \
	        FRAMEWORK_VERSION_DIR_NAME="../$(FRAMEWORK_VERSION_DIR_NAME)" \
	        DERIVED_SOURCES="../$(DERIVED_SOURCES)" \
	        SUBPROJECT_ROOT_DIR="$(SUBPROJECT_ROOT_DIR)/$$f" \
	      ; then \
	      :; \
	  else exit $$?; \
	  fi; \
	done; \
	fi

#
# The list of Objective-C source files to be compiled
# are in the OBJC_FILES variable.
#
# The list of C source files to be compiled
# are in the C_FILES variable.
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

#
# Common variables for frameworks
#
ifeq ($(CURRENT_VERSION_NAME),)
  CURRENT_VERSION_NAME := A
endif
ifeq ($(DEPLOY_WITH_CURRENT_VERSION),)
  DEPLOY_WITH_CURRENT_VERSION := yes
endif

FRAMEWORK_NAME := $(strip $(FRAMEWORK_NAME))
FRAMEWORK_DIR_NAME := $(FRAMEWORK_NAME:=.framework)
FRAMEWORK_VERSION_DIR_NAME := $(FRAMEWORK_DIR_NAME)/Versions/$(CURRENT_VERSION_NAME)
SUBPROJECT_ROOT_DIR := "."

# The rule to create the objects file directory. This rule is here so that it
# can be accessed from the global before and after targets as well.
$(GNUSTEP_OBJ_DIR):
	@($(MKDIRS) ./$(GNUSTEP_OBJ_DIR); \
	rm -f obj; \
	$(LN_S) ./$(GNUSTEP_OBJ_DIR) obj)

#
# Now rules for packaging - all automatically included
# 

#
# Rules for building source distributions
#
include $(GNUSTEP_MAKEFILES)/source-distribution.make

#
# Rules for building spec files/file lists for RPMs, and RPMs
#
include $(GNUSTEP_MAKEFILES)/rpm.make

#
# Rules for building debian/* scripts for DEBs, and DEBs
# 
#include $(GNUSTEP_MAKEFILES)/deb.make <TODO>

endif
# rules.make loaded

## Local variables:
## mode: makefile
## End:
