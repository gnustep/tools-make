#
#   Instance/service.make
#
#   Instance Makefile rules to build GNUstep-based services.
#
#   Copyright (C) 1998, 2001 Free Software Foundation, Inc.
#
#   Author:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
#   Based on the makefiles by Scott Christley.
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

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

#
# The name of the service is in the SERVICE_NAME variable.
# The NSServices info should be in $(SERVICE_NAME)Info.plist
# The list of service resource file are in xxx_RESOURCE_FILES
# The list of service resource directories are in xxx_RESOURCE_DIRS
# where xxx is the service name
#

.PHONY: internal-service-all_ \
        internal-service-distclean \
        internal-service-install_ \
        internal-service-uninstall_ \
        service-resource-files

# Libraries that go before the GUI libraries
ALL_SERVICE_LIBS =							\
    $(shell $(WHICH_LIB_SCRIPT)						\
	$(ALL_LIB_DIRS)							\
	$(ADDITIONAL_GUI_LIBS) $(AUXILIARY_GUI_LIBS)			\
	$(GUI_LIBS) $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS)	\
	$(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS)	\
	$(OBJC_LIBS) $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)		\
	debug=$(debug) profile=$(profile) shared=$(shared)		\
	libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

# Don't include these definitions the first time make is invoked. This part is
# included when make is invoked the second time from the %.build rule (see
# rules.make).
SERVICE_DIR_NAME = $(GNUSTEP_INSTANCE:=.service)

#
# Internal targets
#
SERVICE_FILE = $(SERVICE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/$(GNUSTEP_INSTANCE)

# Copy any resources into $(SERVICE_DIR_NAME)/Resources
GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH = $(SERVICE_DIR_NAME)/Resources
include $(GNUSTEP_MAKEFILES)/Instance/Shared/bundle.make

#
# Compilation targets
#
internal-service-all_:: $(GNUSTEP_OBJ_DIR) \
                        $(SERVICE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR) \
                        $(SERVICE_FILE) \
                        $(SERVICE_DIR_NAME)/Resources/Info-gnustep.plist \
                        shared-instance-bundle-all

$(SERVICE_FILE): $(OBJ_FILES_TO_LINK)
	$(ECHO_LINKING)$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ $(OBJ_FILES_TO_LINK)\
		$(ALL_SERVICE_LIBS)$(END_ECHO)

$(SERVICE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR):
	@$(MKDIRS) $(SERVICE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)


# Allow the gui library to redefine make_services to use its local one
ifeq ($(GNUSTEP_MAKE_SERVICES),)
  GNUSTEP_MAKE_SERVICES = make_services
endif

$(SERVICE_DIR_NAME)/Resources/Info-gnustep.plist: \
	$(SERVICE_DIR_NAME)/Resources $(GNUSTEP_INSTANCE)Info.plist 
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_INSTANCE)\";"; \
	  cat $(GNUSTEP_INSTANCE)Info.plist; \
	  echo "}") >$@ ;\
	if $(GNUSTEP_MAKE_SERVICES) --test $@; then : ; else rm -f $@; false; \
	fi

#
# Install targets
#

$(GNUSTEP_SERVICES):
	$(MKINSTALLDIRS) $@

internal-service-install_:: $(GNUSTEP_SERVICES)
	$(ECHO_INSTALLING)rm -rf $(GNUSTEP_SERVICES)/$(SERVICE_DIR_NAME); \
	$(TAR) cf - $(SERVICE_DIR_NAME) \
	  | (cd $(GNUSTEP_SERVICES); $(TAR) xf -)$(END_ECHO)
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) $(GNUSTEP_SERVICES)/$(SERVICE_DIR_NAME)
endif
ifeq ($(strip),yes)
	$(STRIP) $(GNUSTEP_SERVICES)/$(SERVICE_FILE) 
endif

internal-service-uninstall_::
	(cd $(GNUSTEP_SERVICES); rm -rf $(SERVICE_DIR_NAME))


#
# Cleaning targets
#
internal-service-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj *.app *.debug *.profile *.iconheader \
	  $(SERVICE_DIR_NAME)

## Local variables:
## mode: makefile
## End:
