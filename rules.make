#
#   rules.make
#
#   All of the common makefile rules.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#   Java support by Lyndon Tremblay <ltremblay@mezzanine.xnot.com>
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
ifeq ($(RULES_MAKE_LOADED),)
RULES_MAKE_LOADED=yes

# This part is included the first time make is invoked. This part defines the
# global targets and the following implicit rule which determines the
# TARGET_TYPE of the next thing to be build in the following make invocation
# (a library, application, tool etc.), the current name of the target from a
# specific library/application/tool/etc list and the OPERATION to be performed
# (all, install, clean, distclean etc.).

# This target has to be called with the name of the actual target, followed
# by the operation, then the makefile fragment to be called and then the
# variables word. Suppose for example we build the library libgmodel, the
# target should look like:
#
#	libgmodel.all.library.variables
#
%.variables:
	@(target=`echo $* | sed -e 's/\(.*\)\.\(.*\)\.\(.*\)/\1/'`; \
	operation=`echo $* | sed -e 's/\(.*\)\.\(.*\)\.\(.*\)/\2/'`; \
	type=`echo $* | sed -e 's/\(.*\)\.\(.*\)\.\(.*\)/\3/' | tr - _`; \
	$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going \
	    TARGET_TYPE=$${type} \
	    OPERATION=$${operation} TARGET=$${target} \
	    PROCESS_SECOND_TIME=yes $${target}.build \
	    OBJCFLAGS="$(OBJCFLAGS)" CFLAGS="$(CFLAGS)" \
	    OPTFLAG="$(OPTFLAG)" )

#
# Global targets
#
all:: before-all internal-all after-all

install:: before-install internal-install after-install

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

before-uninstall::

internal-uninstall::

after-uninstall::

before-clean::

internal-clean::
	rm -rf *~

after-clean::

before-distclean::

internal-distclean::

after-distclean::

before-check::

internal-check::

after-check::

ifeq ($(PROCESS_SECOND_TIME),yes)

ALL_CPPFLAGS = $(CPPFLAGS) $(ADDITIONAL_CPPFLAGS) $(AUXILIARY_CPPFLAGS)

ALL_OBJCFLAGS = $(INTERNAL_OBJCFLAGS) $(ADDITIONAL_OBJCFLAGS) \
   $(AUXILIARY_OBJCFLAGS) $(ADDITIONAL_INCLUDE_DIRS) \
   $(AUXILIARY_INCLUDE_DIRS) -I. $(SYSTEM_INCLUDES) \
   $(GNUSTEP_HEADERS_FND_FLAG) $(GNUSTEP_HEADERS_GUI_FLAG) \
   $(GNUSTEP_HEADERS_TARGET_FLAG) $(GNUSTEP_USER_HEADERS_FLAG) \
   $(GNUSTEP_LOCAL_HEADERS_FLAG) $(GNUSTEP_NETWORK_HEADERS_FLAG) \
   -I$(GNUSTEP_SYSTEM_HEADERS) 

ALL_CFLAGS = $(INTERNAL_CFLAGS) $(ADDITIONAL_CFLAGS) \
   $(AUXILIARY_CFLAGS) $(ADDITIONAL_INCLUDE_DIRS) \
   $(AUXILIARY_INCLUDE_DIRS) -I. $(SYSTEM_INCLUDES) \
   $(GNUSTEP_HEADERS_FND_FLAG) $(GNUSTEP_HEADERS_GUI_FLAG) \
   $(GNUSTEP_HEADERS_TARGET_FLAG) $(GNUSTEP_USER_HEADERS_FLAG) \
   $(GNUSTEP_LOCAL_HEADERS_FLAG) $(GNUSTEP_NETWORK_HEADERS_FLAG) \
   -I$(GNUSTEP_SYSTEM_HEADERS)

ALL_JAVAFLAGS = $(INTERNAL_JAVAFLAGS) $(ADDITIONAL_JAVAFLAGS) \
	$(AUXILIARY_JAVAFLAGS)

ALL_LDFLAGS = $(ADDITIONAL_LDFLAGS) $(AUXILIARY_LDFLAGS) $(GUI_LDFLAGS) \
   $(BACKEND_LDFLAGS) $(SYSTEM_LDFLAGS) $(INTERNAL_LDFLAGS)

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

.SUFFIXES: .m .c .psw .java

.PRECIOUS: %.c %.h $(GNUSTEP_OBJ_DIR)/%${OEXT}

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.c
	$(CC) -c $(ALL_CPPFLAGS) $(ALL_CFLAGS) -o $@ $<

$(GNUSTEP_OBJ_DIR)/%${OEXT} : %.m
	$(CC) -c $(ALL_CPPFLAGS) $(ALL_OBJCFLAGS) -o $@ $<

$(JAVA_OBJ_PREFIX)%.class : %.java
	@if [ $< -nt $(JAVA_OBJ_PREFIX)/`(grep package $< | awk '{ print $$2 }') | sed -e "s/\./\//g" -e "s/\;//"`/$@ -o ! -f $(JAVA_OBJ_PREFIX)/`(grep package $< | awk '{ print $$2 }') | sed -e "s/\./\//g" -e "s/\;//"`/$@ ]; then \
		echo $(JAVAC) $(ALL_JAVAFLAGS) $< -d $(JAVA_OBJ_PREFIX); \
		$(JAVAC) $(ALL_JAVAFLAGS) $< -d $(JAVA_OBJ_PREFIX); \
	fi

%.c : %.psw
	pswrap -h $*.h -o $@ $<

# The magical application rules, thank you GNU make!
%.build:
	@(echo Making $(OPERATION) for $(TARGET_TYPE) $*...; \
        tmp="$($*_SUBPROJECTS)"; \
        if test "x$(tmp)" != x ; then \
          for f in $tmp; do \
	    mf=$(MAKEFILE_NAME); \
	    if [ ! -f $$f/$$mf -a -f $$f/Makefile ]; then \
	      mf=Makefile; \
	      echo "WARNING: No $(MAKEFILE_NAME) found for subproject $$f; using 'Makefile'"; \
	    fi; \
	    if $(MAKE) -C $$f -f $$mf --no-keep-going $(OPERATION); then \
	      :; \
	    else exit $$?; \
	    fi; \
	  done; \
        fi; \
	$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going \
	    internal-$(TARGET_TYPE)-$(OPERATION) \
	    INTERNAL_$(TARGET_TYPE)_NAME=$* \
	    SUBPROJECTS="$($*_SUBPROJECTS)" \
	    OBJC_FILES="$($*_OBJC_FILES)" \
	    C_FILES="$($*_C_FILES)" \
		JAVA_FILES="$($*_JAVA_FILES)" \
		JAVA_JOBS_FILES="$($*_JOBS_FILES)" \
		JAVA_WRAPPER_FRAMEWORK="$($*_WRAPPER_FRAMEWORK)" \
	    PSWRAP_FILES="$($*_PSWRAP_FILES)" \
	    HEADER_FILES="$($*_HEADER_FILES)" \
	    TEXI_FILES="$($*_TEXI_FILES)" \
	    TEXT_MAIN="$($*_TEXT_MAIN)" \
	    HEADER_FILES_DIR="$($*_HEADER_FILES_DIR)" \
	    HEADER_FILES_INSTALL_DIR="$($*_HEADER_FILES_INSTALL_DIR)" \
	    RESOURCE_FILES="$($*_RESOURCE_FILES)" \
	    WEBSERVER_RESOURCE_FILES="$($*_WEBSERVER_RESOURCE_FILES)" \
		LOCALIZED_RESOURCE_FILES="$($*_LOCALIZED_RESOURCE_FILES)" \
		LOCALIZED_WEBSERVER_RESOURCE_FILES="$($*_LOCALIZED_WEBSERVER_RESOURCE_FILES)" \
	    MAIN_MODEL_FILE="$($*_MAIN_MODEL_FILE)" \
	    APPLICATION_ICON="$($*_APPLICATION_ICON)" \
	    RESOURCE_DIRS="$($*_RESOURCE_DIRS)" \
		COMPONENTS="$($*_COMPONENTS)" \
		LANGUAGES="$($*_LANGUAGES)" \
		HAS_GSWCOMPONENTS="$($*_HAS_GSWCOMPONENTS)" \
		GSWAPP_INFO_PLIST="$($*_GSWAPP_INFO_PLIST)" \
	    BUNDLE_LIBS="$($*_BUNDLE_LIBS) $(BUNDLE_LIBS)" \
	    SERVICE_INSTALL_DIR="$($*_SERVICE_INSTALL_DIR)" \
	    PRINCIPAL_CLASS="$($*_PRINCIPAL_CLASS)" \
	    ADDITIONAL_INCLUDE_DIRS="$(ADDITIONAL_INCLUDE_DIRS) \
					$($*_INCLUDE_DIRS)" \
	    ADDITIONAL_GUI_LIBS="$($*_GUI_LIBS) $(ADDITIONAL_GUI_LIBS)" \
	    ADDITIONAL_TOOL_LIBS="$($*_TOOL_LIBS) $(ADDITIONAL_TOOL_LIBS)" \
	    ADDITIONAL_OBJC_LIBS="$($*_OBJC_LIBS) $(ADDITIONAL_OBJC_LIBS)" \
	    ADDITIONAL_LIBRARY_LIBS="$($*_LIBS)" \
	    ADDITIONAL_LIB_DIRS="$($*_LIB_DIRS) $(ADDITIONAL_LIB_DIRS)" \
	    ADDITIONAL_LDFLAGS="$($*_LDFLAGS) $(ADDITIONAL_LDFLAGS)" \
	    LIBRARIES_DEPEND_UPON="$(shell $(WHICH_LIB_SCRIPT) \
		$(LIB_DIRS_NO_SYSTEM) $(LIBRARIES_DEPEND_UPON) \
		$($*_LIBRARIES_DEPEND_UPON) debug=$(debug) profile=$(profile) \
		shared=$(shared) libext=$(LIBEXT) \
		shared_libext=$(SHARED_LIBEXT))" \
	    SCRIPTS_DIRECTORY="$($*_SCRIPTS_DIRECTORY)" \
	    CHECK_SCRIPT_DIRS="$($*_SCRIPT_DIRS)" \
	)

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

ifneq ($(SUBPROJECTS),)
  SUBPROJECT_OBJ_FILES = $(foreach d, $(SUBPROJECTS), \
    $(addprefix $(d)/, $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT)))
endif

OBJC_OBJS = $(OBJC_FILES:.m=${OEXT})
OBJC_OBJ_FILES = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(OBJC_OBJS))

JAVA_OBJS = $(JAVA_FILES:.java=.class)
ifeq ($(JAVA_OBJ_PREFIX),)
	JAVA_OBJ_FILES = $(JAVA_OBJS)
else
	JAVA_OBJ_FILES = $(addprefix $(JAVA_OBJ_PREFIX),$(JAVA_OBJS))
endif

PSWRAP_C_FILES = $(PSWRAP_FILES:.psw=.c)
PSWRAP_H_FILES = $(PSWRAP_FILES:.psw=.h)
PSWRAP_OBJS = $(PSWRAP_FILES:.psw=${OEXT})
PSWRAP_OBJ_FILES = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(PSWRAP_OBJS))

C_OBJS = $(C_FILES:.c=${OEXT})
C_OBJ_FILES = $(PSWRAP_OBJ_FILES) $(addprefix $(GNUSTEP_OBJ_DIR)/,$(C_OBJS))
# Rules processed second time
endif

ifeq ($(OBJ_DIR_RULE),)
OBJ_DIR_RULE = defined
# The rule to create the objects file directory. This rule is here so that it
# can be accessed from the global before and after targets as well.
$(GNUSTEP_OBJ_DIR):
	@$(MKDIRS) ./$(GNUSTEP_OBJ_DIR)
endif

endif
# rules.make loaded

## Local variables:
## mode: makefile
## End:
