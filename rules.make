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
# internal-check-installation-permissions comes before everything so
# that we don't even run `make all' if we wouldn't be allowed to
# install afterwards
ifeq ($(MAKELEVEL),0)
install:: internal-check-install-permissions all \
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

# In case of problems, we print a message trying to educate the user
# about how to install elsewhere, except if the installation dir is
# GNUSTEP_SYSTEM_ROOT, in that case we don't want to suggest to
# install the software elsewhere, because it is likely to be system
# software like the gnustep-base library.  NB: the check of
# GNUSTEP_INSTALLATION_DIR against GNUSTEP_SYSTEM_ROOT is not perfect
# as /usr/GNUstep/System/ might not match /usr/GNUstep/System but what
# we really want to catch is the GNUSTEP_INSTALLATION_DIR =
# $(GNUSTEP_SYSTEM_ROOT) command in the makefiles, and the check of
# course works with it.
internal-check-install-permissions:
	@if [ -d "$(GNUSTEP_INSTALLATION_DIR)" \
	      -a ! -w "$(GNUSTEP_INSTALLATION_DIR)" ]; then \
	  echo "*ERROR*: the software is configured to install itself into $(GNUSTEP_INSTALLATION_DIR)"; \
	  echo "but you do not have permissions to write in that directory:";\
	  echo "Aborting installation."; \
	  echo ""; \
	  if [ "$(GNUSTEP_INSTALLATION_DIR)" != "$(GNUSTEP_SYSTEM_ROOT)" ]; then \
	    echo "Suggestion: if you can't get permissions to install there, you can try";\
	    echo "to install the software in a different directory by setting";\
	    echo "GNUSTEP_INSTALLATION_DIR.  For example, to install into";\
	    echo "$(GNUSTEP_USER_ROOT), which is your own GNUstep directory, just type"; \
	    echo ""; \
	    echo "make install GNUSTEP_INSTALLATION_DIR=\"$(GNUSTEP_USER_ROOT)\""; \
	    echo ""; \
	    echo "You should always be able to install into $(GNUSTEP_USER_ROOT),";\
	    echo "so this might be a good option.  The other meaningful values for";\
	    echo "GNUSTEP_INSTALLATION_DIR on your system are:";\
	    echo "$(GNUSTEP_SYSTEM_ROOT) (the System directory)";\
	    echo "$(GNUSTEP_LOCAL_ROOT) (the Local directory)";\
	    echo "$(GNUSTEP_NETWORK_ROOT) (the Network directory)";\
	    echo "but you might need special permissions to install in those directories.";\
	  fi; \
	  exit 1; \
	fi

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

#
# The bundle extension (default is .bundle) is defined by BUNDLE_EXTENSION.
#
ifeq ($(strip $(BUNDLE_EXTENSION)),)
BUNDLE_EXTENSION = .bundle
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

# the following is the code used in %.variables, %.tools and %.subprojects
# to extract the target, operation and type from the $* (the stem) of the 
# rule.  with GNU make => 3.78, we could define the following as macros 
# and use $(call ...) to call them; but because we have users who are using 
# GNU make older than that, we have to manually `paste' this code 
# wherever we need to access target or type or operation.
#
# Anyway, the following table tells you what these commands do - 
#
# target=$(basename $(basename $(1)))
# operation=$(subst .,,$(suffix $(basename $(1))))
# type=$(subst -,_,$(subst .,,$(suffix $(1))))
#
# It's very important to notice that $(basename $(basename $*)) in
# these rules is simply the target (such as libgmodel).

# Before building the real thing, we must build framework tools if
# any, then subprojects (FIXME - not sure - at what stage should we
# build framework tools ? perhaps after the framework so we can link
# with it ?)
%.variables: %.tools %.subprojects
	@ \
target=$(basename $(basename $*)); \
operation=$(subst .,,$(suffix $(basename $*))); \
type=$(subst -,_,$(subst .,,$(suffix $*))); \
echo Making $$operation for $$type $$target...; \
$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going \
  internal-$${type}-$$operation \
  INTERNAL_$${type}_NAME=$$target \
  TARGET=$$target \
  _SUBPROJECTS="$($(basename $(basename $*))_SUBPROJECTS)" \
  OBJC_FILES="$($(basename $(basename $*))_OBJC_FILES)" \
  C_FILES="$($(basename $(basename $*))_C_FILES)" \
  CC_FILES="$($(basename $(basename $*))_CC_FILES)" \
  JAVA_FILES="$($(basename $(basename $*))_JAVA_FILES)" \
  JAVA_JNI_FILES="$($(basename $(basename $*))_JAVA_JNI_FILES)" \
  OBJ_FILES="$($(basename $(basename $*))_OBJ_FILES)" \
  PSWRAP_FILES="$($(basename $(basename $*))_PSWRAP_FILES)" \
  HEADER_FILES="$($(basename $(basename $*))_HEADER_FILES)" \
  TEXI_FILES="$($(basename $(basename $*))_TEXI_FILES)" \
  GSDOC_FILES="$($(basename $(basename $*))_GSDOC_FILES)" \
  AGSDOC_FILES="$($(basename $(basename $*))_AGSDOC_FILES)" \
  AGSDOC_FLAGS="$($(basename $(basename $*))_AGSDOC_FLAGS)" \
  LATEX_FILES="$($(basename $(basename $*))_LATEX_FILES)" \
  JAVADOC_FILES="$($(basename $(basename $*))_JAVADOC_FILES)" \
  JAVADOC_SOURCEPATH="$($(basename $(basename $*))_JAVADOC_SOURCEPATH)" \
  DOC_INSTALL_DIR="$($(basename $(basename $*))_DOC_INSTALL_DIR)" \
  TEXT_MAIN="$($(basename $(basename $*))_TEXT_MAIN)" \
  HEADER_FILES_DIR="$($(basename $(basename $*))_HEADER_FILES_DIR)" \
  HEADER_FILES_INSTALL_DIR="$($(basename $(basename $*))_HEADER_FILES_INSTALL_DIR)" \
  COMPONENTS="$($(basename $(basename $*))_COMPONENTS)" \
  LANGUAGES="$($(basename $(basename $*))_LANGUAGES)" \
  HAS_GSWCOMPONENTS="$($(basename $(basename $*))_HAS_GSWCOMPONENTS)" \
  GSWAPP_INFO_PLIST="$($(basename $(basename $*))_GSWAPP_INFO_PLIST)" \
  WEBSERVER_RESOURCE_FILES="$($(basename $(basename $*))_WEBSERVER_RESOURCE_FILES)" \
  LOCALIZED_WEBSERVER_RESOURCE_FILES="$($(basename $(basename $*))_LOCALIZED_WEBSERVER_RESOURCE_FILES)" \
  WEBSERVER_RESOURCE_DIRS="$($(basename $(basename $*))_WEBSERVER_RESOURCE_DIRS)" \
  LOCALIZED_RESOURCE_FILES="$($(basename $(basename $*))_LOCALIZED_RESOURCE_FILES)" \
  RESOURCE_FILES="$($(basename $(basename $*))_RESOURCE_FILES)" \
  MAIN_MODEL_FILE="$($(basename $(basename $*))_MAIN_MODEL_FILE)" \
  RESOURCE_DIRS="$($(basename $(basename $*))_RESOURCE_DIRS)" \
  BUNDLE_LIBS="$($(basename $(basename $*))_BUNDLE_LIBS) $(BUNDLE_LIBS)" \
  SERVICE_INSTALL_DIR="$($(basename $(basename $*))_SERVICE_INSTALL_DIR)" \
  APPLICATION_ICON="$($(basename $(basename $*))_APPLICATION_ICON)" \
  PALETTE_ICON="$($(basename $(basename $*))_PALETTE_ICON)" \
  PRINCIPAL_CLASS="$($(basename $(basename $*))_PRINCIPAL_CLASS)" \
  DLL_DEF="$($(basename $(basename $*))_DLL_DEF)" \
  ADDITIONAL_INCLUDE_DIRS="$(ADDITIONAL_INCLUDE_DIRS) \
		$($(basename $(basename $*))_INCLUDE_DIRS)" \
  ADDITIONAL_GUI_LIBS="$($(basename $(basename $*))_GUI_LIBS) \
                       $(ADDITIONAL_GUI_LIBS)" \
  ADDITIONAL_TOOL_LIBS="$($(basename $(basename $*))_TOOL_LIBS) \
                        $(ADDITIONAL_TOOL_LIBS)" \
  ADDITIONAL_OBJC_LIBS="$($(basename $(basename $*))_OBJC_LIBS) \
                        $(ADDITIONAL_OBJC_LIBS)" \
  ADDITIONAL_LIBRARY_LIBS="$($(basename $(basename $*))_LIBS) \
                           $($(basename $(basename $*))_LIBRARY_LIBS) \
                           $(ADDITIONAL_LIBRARY_LIBS)" \
  ADDITIONAL_LIB_DIRS="$($(basename $(basename $*))_LIB_DIRS) \
                       $(ADDITIONAL_LIB_DIRS)" \
  ADDITIONAL_LDFLAGS="$($(basename $(basename $*))_LDFLAGS) \
                      $(ADDITIONAL_LDFLAGS)" \
  ADDITIONAL_CLASSPATH="$($(basename $(basename $*))_CLASSPATH) \
                        $(ADDITIONAL_CLASSPATH)" \
  LIBRARIES_DEPEND_UPON="$($(basename $(basename $*))_LIBRARIES_DEPEND_UPON) \
                         $(LIBRARIES_DEPEND_UPON)" \
  SCRIPTS_DIRECTORY="$($(basename $(basename $*))_SCRIPTS_DIRECTORY)" \
  CHECK_SCRIPT_DIRS="$($(basename $(basename $*))_SCRIPT_DIRS)"


ifneq ($(FRAMEWORK_NAME),)
#
# This rule is executed only for frameworks to build the framework tools.
# It is currently executed before %.subprojects (FIXME order).
#
%.tools:
	@ \
target=$(basename $(basename $*)); \
operation=$(subst .,,$(suffix $(basename $*))); \
type=$(subst -,_,$(subst .,,$(suffix $*))); \
if [ "$$operation" != "build-headers" ]; then \
  if [ "$($(basename $(basename $*))_TOOLS)" != "" ]; then \
    echo Building tools for $$type $$target...; \
    for f in $($(basename $(basename $*))_TOOLS) __done; do \
      if [ $$f != __done ]; then       \
        mf=$(MAKEFILE_NAME); \
        if [ ! -f $$f/$$mf -a -f $$f/Makefile ]; then \
          mf=Makefile; \
          echo "WARNING: No $(MAKEFILE_NAME) found for tool $$f; using 'Makefile'"; \
        fi; \
        if $(MAKE) -C $$f -f $$mf --no-keep-going $$operation \
             FRAMEWORK_NAME="$(FRAMEWORK_NAME)" \
             FRAMEWORK_VERSION_DIR_NAME="../$(FRAMEWORK_VERSION_DIR_NAME)" \
             FRAMEWORK_OPERATION="$$operation" \
             TOOL_OPERATION="$$operation" \
             DERIVED_SOURCES="../$(DERIVED_SOURCES)" \
             SUBPROJECT_ROOT_DIR="$(SUBPROJECT_ROOT_DIR)/$$f" \
           ; then \
           :; \
        else exit $$?; \
        fi; \
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
	@ \
target=$(basename $(basename $*)); \
operation=$(subst .,,$(suffix $(basename $*))); \
type=$(subst -,_,$(subst .,,$(suffix $*))); \
if [ "$($(basename $(basename $*))_SUBPROJECTS)" != "" ]; then \
  echo Making $$operation in subprojects of $$type $$target...; \
  for f in $($(basename $(basename $*))_SUBPROJECTS) __done; do \
    if [ $$f != __done ]; then       \
      mf=$(MAKEFILE_NAME); \
      if [ ! -f $$f/$$mf -a -f $$f/Makefile ]; then \
        mf=Makefile; \
        echo "WARNING: No $(MAKEFILE_NAME) found for subproject $$f; using 'Makefile'"; \
      fi; \
      if $(MAKE) -C $$f -f $$mf --no-keep-going $$operation \
          FRAMEWORK_NAME="$(FRAMEWORK_NAME)" \
          FRAMEWORK_VERSION_DIR_NAME="../$(FRAMEWORK_VERSION_DIR_NAME)" \
          DERIVED_SOURCES="../$(DERIVED_SOURCES)" \
          SUBPROJECT_ROOT_DIR="$(SUBPROJECT_ROOT_DIR)/$$f" \
        ; then \
        :; \
      else exit $$?; \
      fi; \
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
