#
#   service.make
#
#   Makefile rules to build GNUstep-based services.
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

# prevent multiple inclusions
ifeq ($(SERVICE_MAKE_LOADED),)
SERVICE_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
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

SERVICE_NAME:=$(strip $(SERVICE_NAME))

ifeq ($(INTERNAL_service_NAME),)
# This part gets included by the first invoked make process.
internal-all:: $(SERVICE_NAME:=.all.service.variables)

internal-install:: $(SERVICE_NAME:=.install.service.variables)

internal-uninstall:: $(SERVICE_NAME:=.uninstall.service.variables)

_PSWRAP_C_FILES = $(foreach service,$(SERVICE_NAME),$($(service)_PSWRAP_FILES:.psw=.c))
_PSWRAP_H_FILES = $(foreach service,$(SERVICE_NAME),$($(service)_PSWRAP_FILES:.psw=.h))

internal-clean:: $(SERVICE_NAME:=.clean.service.subprojects)
	rm -rf $(GNUSTEP_OBJ_DIR) $(_PSWRAP_C_FILES) $(_PSWRAP_H_FILES)
ifeq ($(OBJC_COMPILER), NeXT)
	rm -f *.iconheader
	for f in *.service; do \
	  rm -f $$f/`basename $$f .service`; \
	done
else
ifeq ($(GNUSTEP_FLATTENED),)
	rm -rf *.service/$(GNUSTEP_TARGET_LDIR)
else
	rm -rf *.service
endif
endif

internal-distclean:: $(SERVICE_NAME:=.distclean.service.variables)

$(SERVICE_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
	            $@.all.service.variables

else

.PHONY: internal-service-all \
        internal-service-distclean \
        internal-service-install \
        internal-service-uninstall \
        before-$(TARGET)-all \
        after-$(TARGET)-all \
        service-resource-files

# Libraries that go before the GUI libraries
ALL_GUI_LIBS = $(ADDITIONAL_GUI_LIBS) $(AUXILIARY_GUI_LIBS) \
   $(GUI_LIBS) $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) \
   $(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS) \
   $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)

ALL_GUI_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_GUI_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))

ifeq ($(WITH_DLL),yes)
TTMP_LIBS := $(ALL_GUI_LIBS)
TTMP_LIBS := $(filter -l%, $(TTMP_LIBS))
# filter all non-static libs (static libs are those ending in _ds, _s, _ps..)
TTMP_LIBS := $(filter-out -l%_ds, $(TTMP_LIBS))
TTMP_LIBS := $(filter-out -l%_s,  $(TTMP_LIBS))
TTMP_LIBS := $(filter-out -l%_dps,$(TTMP_LIBS))
TTMP_LIBS := $(filter-out -l%_ps, $(TTMP_LIBS))
# strip away -l, _p and _d ..
TTMP_LIBS := $(TTMP_LIBS:-l%=%)
TTMP_LIBS := $(TTMP_LIBS:%_d=%)
TTMP_LIBS := $(TTMP_LIBS:%_p=%)
TTMP_LIBS := $(TTMP_LIBS:%_dp=%)
TTMP_LIBS := $(shell echo $(TTMP_LIBS)|tr '-' '_')
TTMP_LIBS := $(TTMP_LIBS:%=-Dlib%_ISDLL=1)
ALL_CPPFLAGS += $(TTMP_LIBS)
endif

# Don't include these definitions the first time make is invoked. This part is
# included when make is invoked the second time from the %.build rule (see
# rules.make).
SERVICE_DIR_NAME = $(INTERNAL_service_NAME:=.service)
SERVICE_RESOURCE_DIRS =  $(foreach d, $(RESOURCE_DIRS), $(SERVICE_DIR_NAME)/Resources/$(d))

#
# Internal targets
#
SERVICE_FILE = $(SERVICE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/$(INTERNAL_service_NAME)


$(SERVICE_FILE): $(OBJ_FILES_TO_LINK)
	$(LD) $(ALL_LDFLAGS) -o $(LDOUT)$@ $(OBJ_FILES_TO_LINK) \
		$(ALL_LIB_DIRS) $(ALL_GUI_LIBS)

#
# Compilation targets
#
internal-service-all:: before-$(TARGET)-all \
                   $(GNUSTEP_OBJ_DIR) \
                   $(SERVICE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR) \
                   $(SERVICE_FILE) \
                   service-resource-files \
                   after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

$(SERVICE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR):
	@$(MKDIRS) $(SERVICE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)

$(SERVICE_RESOURCE_DIRS):
	$(MKDIRS) $(SERVICE_RESOURCE_DIRS)

service-resource-files:: $(SERVICE_DIR_NAME)/Resources/Info-gnustep.plist \
                     $(SERVICE_RESOURCE_DIRS)
ifneq ($(strip $(RESOURCE_FILES)),)
	@(echo "Copying resources into the service wrapper..."; \
	cp -r $(RESOURCE_FILES) $(SERVICE_DIR_NAME)/Resources)
endif

# Allow the gui library to redefine make_services to use its local one
ifeq ($(GNUSTEP_MAKE_SERVICES),)
  GNUSTEP_MAKE_SERVICES=make_services
endif

$(SERVICE_DIR_NAME)/Resources/Info-gnustep.plist: \
	$(SERVICE_DIR_NAME)/Resources $(INTERNAL_service_NAME)Info.plist 
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(INTERNAL_service_NAME)\";"; \
	  cat $(INTERNAL_service_NAME)Info.plist; \
	  echo "}") >$@ ;\
	if $(GNUSTEP_MAKE_SERVICES) --test $@; then : ; else rm -f $@; false; \
	fi

$(SERVICE_DIR_NAME)/Resources:
	@$(MKDIRS) $@

$(GNUSTEP_SERVICES):
	$(MKDIRS) $@

internal-service-install:: $(GNUSTEP_SERVICES)
	rm -rf $(GNUSTEP_SERVICES)/$(SERVICE_DIR_NAME); \
	$(TAR) cf - $(SERVICE_DIR_NAME) | (cd $(GNUSTEP_SERVICES); $(TAR) xf -)

internal-service-uninstall::
	(cd $(GNUSTEP_SERVICES); rm -rf $(SERVICE_DIR_NAME))


#
# Cleaning targets
#
internal-service-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj *.app *.debug *.profile *.iconheader \
	  $(SERVICE_DIR_NAME)

endif

endif
# service.make loaded

## Local variables:
## mode: makefile
## End:
