#
#   java-tool.make
#
#   Makefile rules to build Java command-line tools.
#
#   Copyright (C) 2001 Free Software Foundation, Inc.
#
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

# Why using Java if you can use Objective-C ...
# Anyway if you really want it, here we go.

#
# The name of the tools is in the JAVA_TOOL_NAME variable.
# The main class (the one implementing main) is in the
# xxx_PRINCIPAL_CLASS variable.
#

# prevent multiple inclusions
ifeq ($(JAVA_TOOL_MAKE_LOADED),)
JAVA_TOOL_MAKE_LOADED = yes

JAVA_TOOL_NAME:=$(strip $(JAVA_TOOL_NAME))

include $(GNUSTEP_MAKEFILES)/rules.make

ifeq ($(INTERNAL_java_tool_NAME),)

internal-all:: $(JAVA_TOOL_NAME:=.all.java_tool.variables)

internal-install:: $(JAVA_TOOL_NAME:=.install.java_tool.variables)

internal-uninstall:: $(JAVA_TOOL_NAME:=.uninstall.java_tool.variables)

internal-clean:: $(JAVA_TOOL_NAME:=.clean.java_tool.variables)

internal-distclean:: $(JAVA_TOOL_NAME:=.distclean.java_tool.variables)

$(JAVA_TOOL_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
	         $@.all.java_tool.variables

else # second pass

# This is the directory where the tools get installed. If you don't specify a
# directory they will get installed in $(GNUSTEP_LOCAL_ROOT)/Tools/Java/.
ifeq ($(JAVA_TOOL_INSTALLATION_DIR),)
  JAVA_TOOL_INSTALLATION_DIR = $(GNUSTEP_TOOLS)/Java/
endif

internal-java_tool-all:: before-$(TARGET)-all \
                         $(JAVA_OBJ_FILES)    \
                         after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

internal-java_tool-install:: internal-java_tool-all install-java_tool

$(JAVA_TOOL_INSTALLATION_DIR):
	$(MKDIRS) $(JAVA_TOOL_INSTALLATION_DIR)

internal-install-java_tool-dirs:: $(JAVA_TOOL_INSTALLATION_DIR)
	if [ "$(JAVA_OBJ_FILES)" != "" ]; then \
	  $(MKDIRS) $(addprefix $(JAVA_TOOL_INSTALLATION_DIR)/,$(dir $(JAVA_OBJ_FILES))); \
	fi

ifeq ($(PRINCIPAL_CLASS),)
  $(warning You must specify PRINCIPAL_CLASS)
  # But then, we are good, and try guessing
  PRINCIPAL_CLASS = $(word 1 $(JAVA_OBJ_FILES))
endif

# Remove an eventual extension (.class or .java) from PRINCIPAL_CLASS;
# only take the first word of it
NORMALIZED_PRINCIPAL_CLASS = $(basename $(word 1 $(PRINCIPAL_CLASS)))

# Escape '/' so it can be passes to sed
ESCAPED_PRINCIPAL_CLASS = $(subst /,\/,$(PRINCIPAL_CLASS))

$(GNUSTEP_INSTALLATION_DIR)/Tools/$(INTERNAL_java_tool_NAME):
	sed -e 's/JAVA_OBJ_FILE/$(ESCAPED_PRINCIPAL_CLASS)/g' \
	    $(GNUSTEP_MAKEFILES)/java-executable.template \
	    > $(GNUSTEP_INSTALLATION_DIR)/Tools/$(INTERNAL_java_tool_NAME); \
	chmod a+x $(GNUSTEP_INSTALLATION_DIR)/Tools/$(INTERNAL_java_tool_NAME);

# See java.make for comments on ADDITIONAL_JAVA_OBJ_FILES
UNESCAPED_ADD_JAVA_OBJ_FILES = $(wildcard $(JAVA_OBJ_FILES:.class=[$$]*.class))
ADDITIONAL_JAVA_OBJ_FILES = $(subst $$,\$$,$(UNESCAPED_ADD_JAVA_OBJ_FILES))

install-java_tool:: internal-install-java_tool-dirs \
$(GNUSTEP_INSTALLATION_DIR)/Tools/$(INTERNAL_java_tool_NAME)
	if [ "$(JAVA_OBJ_FILES)" != "" ]; then \
	  for file in $(JAVA_OBJ_FILES) __done; do \
	    if [ $$file != __done ]; then \
	      $(INSTALL_DATA) $$file $(JAVA_TOOL_INSTALLATION_DIR)/$$file ; \
	    fi; \
	  done; \
	fi; \
	if [ "$(ADDITIONAL_JAVA_OBJ_FILES)" != "" ]; then \
	  for file in $(ADDITIONAL_JAVA_OBJ_FILES) __done; do \
	    if [ $$file != __done ]; then \
	      $(INSTALL_DATA) $$file $(JAVA_TOOL_INSTALLATION_DIR)/$$file ; \
	    fi;    \
	  done;    \
	fi

# Warning - to uninstall nested classes you need to have a compiled 
# source available ...
internal-java_tool-uninstall::
	rm -f $(JAVA_TOOL_INSTALLATION_DIR)/$(JAVA_OBJ_FILES)
	rm -f $(JAVA_TOOL_INSTALLATION_DIR)/$(ADDITIONAL_JAVA_OBJ_FILES)
	rm -f $(GNUSTEP_INSTALLATION_DIR)/Tools/$(INTERNAL_java_tool_NAME)

#
# Cleaning targets
#
internal-java_tool-clean::
	rm -f $(JAVA_OBJ_FILES)
	rm -f $(ADDITIONAL_JAVA_OBJ_FILES)

internal-java_tool-distclean::


endif # internal java tool name
endif # java_tool.make loaded

## Local variables:
## mode: makefile
## End:
