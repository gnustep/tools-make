#
#   rules.make
#
#   Makefile rules for the Master invocation.
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
# instance-type-operation prerequisite.  The make subprocess will be run
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
	rm -f core

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

# Prevent make from trying to remove stuff like
# libcool.library.all.subprojects thinking that it is a temporary file
.PRECIOUS: %.variables %.tools %.subprojects

#
## The magical %.variables rules, thank you GNU make!
#

# The %.variables target has to be called with the name of the actual
# instance, followed by the operation, then the makefile fragment to be
# called and then the variables word. Suppose for example we build the
# library libgmodel, the target should look like:
#
#	libgmodel.all.library.variables
#
# when the rule is executed, $* is libgmodel.all.libray;
#  instance will be libgmodel
#  operation will be all
#  type will be library 
#
# this rule might be executed many times, for different targets to build.

# the rule then calls a submake, which runs the real code

# the following is the code used in %.variables, %.tools and %.subprojects
# to extract the instance, operation and type from the $* (the stem) of the 
# rule.  with GNU make => 3.78, we could define the following as macros 
# and use $(call ...) to call them; but because we have users who are using 
# GNU make older than that, we have to manually `paste' this code 
# wherever we need to access instance or type or operation.
#
# Anyway, the following table tells you what these commands do - 
#
# instance=$(basename $(basename $(1)))
# operation=$(subst .,,$(suffix $(basename $(1))))
# type=$(subst -,_,$(subst .,,$(suffix $(1))))
#
# It's very important to notice that $(basename $(basename $*)) in
# these rules is simply the instance (such as libgmodel).

# NB: INTERNAL_$${type}_NAME and TARGET are deprecated - use
# GNUSTEP_INSTANCE instead.

# Before building the real thing, we must build framework tools if
# any, then subprojects (FIXME - not sure - at what stage should we
# build framework tools ? perhaps after the framework so we can link
# with it ?)
%.variables: %.tools %.subprojects
	@ \
instance=$(basename $(basename $*)); \
operation=$(subst .,,$(suffix $(basename $*))); \
type=$(subst -,_,$(subst .,,$(suffix $*))); \
echo Making $$operation for $$type $$instance...; \
$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going \
  internal-$${type}-$$operation \
  GNUSTEP_TYPE=$$type \
  GNUSTEP_INSTANCE=$$instance \
  INTERNAL_$${type}_NAME=$$instance \
  TARGET=$$instance \
  HEADER_FILES="$($(basename $(basename $*))_HEADER_FILES)" \
  HEADER_FILES_DIR="$($(basename $(basename $*))_HEADER_FILES_DIR)" \
  HEADER_FILES_INSTALL_DIR="$($(basename $(basename $*))_HEADER_FILES_INSTALL_DIR)" \
  COMPONENTS="$($(basename $(basename $*))_COMPONENTS)" \
  LANGUAGES="$($(basename $(basename $*))_LANGUAGES)" \
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
instance=$(basename $(basename $*)); \
operation=$(subst .,,$(suffix $(basename $*))); \
type=$(subst -,_,$(subst .,,$(suffix $*))); \
if [ "$$operation" != "build-headers" ]; then \
  if [ "$($(basename $(basename $*))_TOOLS)" != "" ]; then \
    echo Building tools for $$type $$instance...; \
    for f in $($(basename $(basename $*))_TOOLS) __done; do \
      if [ $$f != __done ]; then       \
        mf=$(MAKEFILE_NAME); \
        if [ ! -f $$f/$$mf -a -f $$f/Makefile ]; then \
          mf=Makefile; \
          echo "WARNING: No $(MAKEFILE_NAME) found for tool $$f; using 'Makefile'"; \
        fi; \
        if $(MAKE) -C $$f -f $$mf --no-print-directory --no-keep-going $$operation \
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
instance=$(basename $(basename $*)); \
operation=$(subst .,,$(suffix $(basename $*))); \
type=$(subst -,_,$(subst .,,$(suffix $*))); \
if [ "$($(basename $(basename $*))_SUBPROJECTS)" != "" ]; then \
  echo Making $$operation in subprojects of $$type $$instance...; \
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
# Now rules for packaging - all automatically included
# 

#
# Rules for building source distributions
#
include $(GNUSTEP_MAKEFILES)/Master/source-distribution.make

#
# Rules for building spec files/file lists for RPMs, and RPMs
#
include $(GNUSTEP_MAKEFILES)/Master/rpm.make

#
# Rules for building debian/* scripts for DEBs, and DEBs
# 
#include $(GNUSTEP_MAKEFILES)/Master/deb.make <TODO>


## Local variables:
## mode: makefile
## End:
