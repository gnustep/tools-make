#
#   framework.make
#
#   Makefile rules to build GNUstep-based frameworks.
#
#   Copyright (C) 2000 Free Software Foundation, Inc.
#
#   Author: Mirko Viviani <mirko.viviani@rccr.cremona.it>
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
ifeq ($(FRAMEWORK_MAKE_LOADED),)
FRAMEWORK_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

# The name of the bundle is in the FRAMEWORK_NAME variable.
# The list of framework resource files are in xxx_RESOURCE_FILES
# The list of framework web server resource files are in
#    xxx_WEBSERVER_RESOURCE_FILES
# The list of localized framework resource files is in
#    xxx_LOCALIZED_RESOURCE_FILES
# The list of localized framework web server resource files is in
#    xxx_LOCALIZED_WEBSERVER_RESOURCE_FILES
# The list of framework GSWeb components are in xxx_COMPONENTS
# The list of languages the framework supports is in xxx_LANGUAGES
# The list of framework resource directories are in xxx_RESOURCE_DIRS
# The list of framework subprojects directories are in xxx_SUBPROJECTS
# The list of framework tools directories are in xxx_TOOLS
# The name of the principal class is xxx_PRINCIPAL_CLASS
# The header files are in xxx_HEADER_FILES
# The list of framework web server resource directories are in
#    xxx_WEBSERVER_RESOURCE_DIRS
# The list of localized framework web server GSWeb components are in
#    xxx_LOCALIZED_WEBSERVER_RESOURCE_DIRS
# CURRENT_VERSION_NAME is the compiled version name (default "A")
# DEPLOY_WITH_CURRENT_VERSION deploy with current version or not (default
#       "yes")
#
# where xxx is the framework name
#

DERIVED_SOURCES = derived_src

ifeq ($(INTERNAL_framework_NAME),)
# This part is included the first time make is invoked.

# A framework has a special task to do before-all, which is to build 
# the public framework headers.
before-all:: $(FRAMEWORK_NAME:=.build-headers.framework.variables)

internal-all:: $(FRAMEWORK_NAME:=.all.framework.variables)

internal-install:: $(FRAMEWORK_NAME:=.install.framework.variables)

internal-uninstall:: $(FRAMEWORK_NAME:=.uninstall.framework.variables)

internal-clean:: $(FRAMEWORK_NAME:=.clean.framework.variables)

internal-distclean:: $(FRAMEWORK_NAME:=.distclean.framework.variables)

$(FRAMEWORK_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going \
		$@.all.framework.variables

else
# This part gets included the second time make is invoked.

ALL_FRAMEWORK_LIBS = $(FRAMEWORK_LIBS)

ALL_FRAMEWORK_LIBS := \
    $(shell $(WHICH_LIB_SCRIPT) $(LIB_DIRS_NO_SYSTEM) $(ALL_FRAMEWORK_LIBS) \
	debug=$(debug) profile=$(profile) shared=$(shared) libext=$(LIBEXT) \
	shared_libext=$(SHARED_LIBEXT))


DUMMY_FRAMEWORK = NSFramework_$(INTERNAL_framework_NAME)
DUMMY_FRAMEWORK_FILE = $(DERIVED_SOURCES)/$(DUMMY_FRAMEWORK).m
DUMMY_FRAMEWORK_OBJ_FILE = $(addprefix $(GNUSTEP_OBJ_DIR)/,$(DUMMY_FRAMEWORK).o)

FRAMEWORK_HEADER_FILES := $(addprefix $(FRAMEWORK_VERSION_DIR_NAME)/Headers/,$(HEADER_FILES))


ifneq ($(BUILD_DLL),yes)

FRAMEWORK_CURRENT_DIR_NAME := $(FRAMEWORK_DIR_NAME)/Versions/Current
FRAMEWORK_LIBRARY_DIR_NAME := $(FRAMEWORK_VERSION_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)
FRAMEWORK_CURRENT_LIBRARY_DIR_NAME := $(FRAMEWORK_CURRENT_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)

FRAMEWORK_LIBRARY_FILE = lib$(INTERNAL_framework_NAME)$(SHARED_LIBEXT)
FRAMEWORK_LIBRARY_FILE_EXT     = $(SHARED_LIBEXT)
VERSION_FRAMEWORK_LIBRARY_FILE = $(FRAMEWORK_LIBRARY_FILE).$(VERSION)
SOVERSION             = $(word 1,$(subst ., ,$(VERSION)))
SONAME_FRAMEWORK_FILE = $(FRAMEWORK_LIBRARY_FILE).$(SOVERSION)

FRAMEWORK_FILE := $(FRAMEWORK_LIBRARY_DIR_NAME)/$(VERSION_FRAMEWORK_LIBRARY_FILE)

else # BUILD_DLL

FRAMEWORK_FILE     = $(INTERNAL_framework_NAME)$(FRAMEWORK_NAME_SUFFIX)$(DLL_LIBEXT)
FRAMEWORK_FILE_EXT = $(DLL_LIBEXT)
DLL_NAME         = $(shell echo $(LIBRARY_FILE)|cut -b 4-)
DLL_EXP_LIB      = $(INTERNAL_framework_NAME)$(FRAMEWORK_NAME_SUFFIX)$(SHARED_LIBEXT)
DLL_EXP_DEF      = $(INTERNAL_framework_NAME)$(FRAMEWORK_NAME_SUFFIX).def

ifeq ($(DLL_INSTALLATION_DIR),)
  DLL_INSTALLATION_DIR = $(GNUSTEP_TOOLS)/$(GNUSTEP_TARGET_LDIR)
endif

endif # BUILD_DLL

ifeq ($(WITH_DLL),yes)
TTMP_LIBS := $(ALL_FRAMEWORK_LIBS)
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
FRAMEWORK_OBJ_EXT = $(DLL_LIBEXT)
endif # WITH_DLL

internal-framework-all:: before-$(TARGET)-all \
                         $(GNUSTEP_OBJ_DIR) \
                         build-framework \
                         after-$(TARGET)-all

before-$(TARGET)-all::

after-$(TARGET)-all::

FRAMEWORK_RESOURCE_DIRS = $(addprefix $(FRAMEWORK_VERSION_DIR_NAME)/Resources/,$(RESOURCE_DIRS))
FRAMEWORK_WEBSERVER_RESOURCE_DIRS =  $(addprefix $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources/,$(WEBSERVER_RESOURCE_DIRS))

ifeq ($(strip $(LANGUAGES)),)
  override LANGUAGES="English"
endif
ifeq ($(FRAMEWORK_INSTALL_DIR),)
  FRAMEWORK_INSTALL_DIR = $(GNUSTEP_FRAMEWORKS)
endif

internal-framework-build-headers:: build-framework-dirs \
                                   $(FRAMEWORK_HEADER_FILES)

build-framework-dirs:: $(DERIVED_SOURCES) \
                       $(FRAMEWORK_LIBRARY_DIR_NAME) \
                       $(FRAMEWORK_VERSION_DIR_NAME)/Headers \
                       $(FRAMEWORK_VERSION_DIR_NAME)/Resources \
                       $(FRAMEWORK_RESOURCE_DIRS)
ifeq ($(DEPLOY_WITH_CURRENT_VERSION),yes)
	@rm -f $(FRAMEWORK_DIR_NAME)/Versions/Current
endif
	@(cd $(FRAMEWORK_DIR_NAME)/Versions; \
	  if [ ! -L "Current" ]; then \
	    rm -f Current; \
	    $(LN_S) $(CURRENT_VERSION_NAME) Current; \
	  fi;)
	@(cd $(FRAMEWORK_DIR_NAME); \
	  if [ ! -L "Resources" ]; then \
	    rm -f Resources; \
	    $(LN_S) Versions/Current/Resources Resources; \
	  fi; \
	  if [ ! -L "Headers" ]; then \
	    rm -f Headers; \
	    $(LN_S) Versions/Current/Headers Headers; \
	  fi;)
	@(cd $(DERIVED_SOURCES); \
	  if [ ! -L "$(INTERNAL_framework_NAME)" ]; then \
	    $(LN_S) ../$(FRAMEWORK_DIR_NAME)/Headers \
                    ./$(INTERNAL_framework_NAME); \
	  fi;)

$(FRAMEWORK_LIBRARY_DIR_NAME):
	$(MKDIRS) $@

$(FRAMEWORK_VERSION_DIR_NAME)/Resources:
	$(MKDIRS) $@

$(FRAMEWORK_VERSION_DIR_NAME)/Headers:
	$(MKDIRS) $@

$(FRAMEWORK_RESOURCE_DIRS):
	$(MKDIRS) $@

$(DERIVED_SOURCES) :
	$(MKDIRS) $@

$(FRAMEWORK_HEADER_FILES):: $(HEADER_FILES)
ifneq ($(HEADER_FILES),)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) ./$$file \
	                    $(FRAMEWORK_VERSION_DIR_NAME)/Headers/$$file ; \
	  fi; \
	done
endif

OBJC_OBJ_FILES_TO_INSPECT = $(OBJC_OBJ_FILES) $(SUBPROJECT_OBJ_FILES)

# FIXME - I don't think we can depend on GNUmakefile - rather we should 
# FORCE then because GNUmakefile might include other arbitrary files outside
# our control
$(DUMMY_FRAMEWORK_FILE): $(DERIVED_SOURCES) $(OBJ_FILES_TO_LINK) GNUmakefile
	@ classes=""; \
	for f in $(OBJC_OBJ_FILES_TO_INSPECT) __dummy__; do \
	  if [ "$$f" != "__dummy__" ]; then \
	    sym=`nm -Pg $$f | awk '/__objc_class_name_/ {if($$2 == "$(OBJC_CLASS_SECTION)") print $$1}' | sed 's/__objc_class_name_//'`; \
	    classes="$$classes $$sym"; \
	  fi; \
	done; \
	classlist=""; \
	for f in $$classes __dummy__ ; do \
	  if [ "$$f" != "__dummy__" ]; then \
	    if [ "$$classlist" = "" ]; then \
	      classlist="@\"$$f\""; \
	    else \
	      classlist="$$classlist, @\"$$f\""; \
	    fi; \
	  fi; \
	done; \
	if [ "$$classlist" = "" ]; then \
	  classlist="NULL"; \
	else \
	  classlist="$$classlist, NULL"; \
	fi; \
	if [ "`echo $(FRAMEWORK_INSTALL_DIR) | sed 's/^$(subst /,\/,$(GNUSTEP_USER_ROOT))//'`" != "$(FRAMEWORK_INSTALL_DIR)" ]; then \
	  fw_env="@\"GNUSTEP_USER_ROOT\""; \
	elif [ "`echo $(FRAMEWORK_INSTALL_DIR) | sed 's/^$(subst /,\/,$(GNUSTEP_LOCAL_ROOT))//'`" != "$(FRAMEWORK_INSTALL_DIR)" ]; then \
	  fw_env="@\"GNUSTEP_LOCAL_ROOT\""; \
	elif [ "`echo $(FRAMEWORK_INSTALL_DIR) | sed 's/^$(subst /,\/,$(GNUSTEP_SYSTEM_ROOT))//'`" != "$(FRAMEWORK_INSTALL_DIR)" ]; then \
	  fw_env="@\"GNUSTEP_SYSTEM_ROOT\""; \
	else \
	  fw_env="nil"; \
	fi; \
	fw_path=`echo $(FRAMEWORK_INSTALL_DIR) | sed 's/^$(subst /,\/,$(GNUSTEP_FRAMEWORKS))//'`; \
	if [ "$$fw_path" = "$(FRAMEWORK_INSTALL_DIR)" ]; then \
	  fw_path="nil"; \
	elif [ "$$fw_path" = "" ]; then \
	  fw_path="nil"; \
	else \
	  fw_path="@\"$$fw_path\""; \
	fi; \
	echo "Creating $(DUMMY_FRAMEWORK_FILE)"; \
	echo "#include <Foundation/NSString.h>" > $@; \
	echo "@interface $(DUMMY_FRAMEWORK)" >> $@; \
	echo "+ (NSString *)frameworkEnv;" >> $@; \
	echo "+ (NSString *)frameworkPath;" >> $@; \
	echo "+ (NSString *)frameworkVersion;" >> $@; \
	echo "+ (NSString **)frameworkClasses;" >> $@; \
	echo "@end" >> $@; \
	echo "@implementation $(DUMMY_FRAMEWORK)" >> $@; \
	echo "+ (NSString *)frameworkEnv { return $$fw_env; }" >> $@; \
	echo "+ (NSString *)frameworkPath { return $$fw_path; }" >> $@; \
	echo "+ (NSString *)frameworkVersion { return @\"$(CURRENT_VERSION_NAME)\"; }" >> $@; \
	echo "static NSString *allClasses[] = {$$classlist};" >> $@; \
	echo "+ (NSString **)frameworkClasses { return allClasses; }" >> $@;\
	echo "@end" >> $@

$(DUMMY_FRAMEWORK_OBJ_FILE): $(DUMMY_FRAMEWORK_FILE)
	$(CC) $< -c $(ALL_CPPFLAGS) $(ALL_OBJCFLAGS) -o $@

build-framework:: $(FRAMEWORK_FILE) \
                  framework-components \
                  framework-resource-files \
                  framework-localized-resource-files \
                  framework-localized-webresource-files \
                  framework-webresource-files

ifeq ($(WITH_DLL),yes)

$(FRAMEWORK_FILE) : $(DUMMY_FRAMEWORK_OBJ_FILE) $(OBJ_FILES_TO_LINK)
	$(DLLWRAP) --driver-name $(CC) \
		-o $(LDOUT)$(FRAMEWORK_FILE) \
		$(OBJ_FILES_TO_LINK) \
		$(ALL_LIB_DIRS) $(ALL_FRAMEWORK_LIBS)

else # without DLL

$(FRAMEWORK_FILE) : $(DUMMY_FRAMEWORK_OBJ_FILE) $(OBJ_FILES_TO_LINK)
	$(FRAMEWORK_LINK_CMD)
	@(cd $(FRAMEWORK_LIBRARY_DIR_NAME); \
	  rm -f $(INTERNAL_framework_NAME); \
	  $(LN_S) $(VERSION_FRAMEWORK_LIBRARY_FILE) \
                  $(INTERNAL_framework_NAME))

endif # WITH_DLL

# NB: In the following rule we do not print a warning if we don't find
# a .lproj dir here - to avoid spurious or duplicated warnings
framework-components::
ifneq ($(strip $(COMPONENTS)),)
	@ echo "Copying components into the framework wrapper..."; \
	cd $(FRAMEWORK_VERSION_DIR_NAME)/Resources; \
	for component in $(COMPONENTS); do \
	  if [ -d ../../../../$$component ]; then \
	    cp -r ../../../../$$component ./; \
	  fi; \
	done; \
	echo "Copying localized components into the framework wrapper..."; \
	for l in $(LANGUAGES); do \
	  if [ -d $$l.lproj ]; then \
	    $(MKDIRS) $$l.lproj; \
	    cd $$l.lproj; \
	    for f in $(COMPONENTS); do \
	      if [ -d ../../../../../$$l.lproj/$$f ]; then \
	        cp -r ../../../../../$$l.lproj/$$f .;\
	      fi; \
	    done;\
	    cd ..; \
	  fi;\
	done
endif

framework-resource-files:: $(FRAMEWORK_VERSION_DIR_NAME)/Resources/Info.plist\
                           $(FRAMEWORK_VERSION_DIR_NAME)/Resources/Info-gnustep.plist
ifneq ($(strip $(RESOURCE_FILES)),)
	@ echo "Copying resources into the framework wrapper..."; \
	for f in "$(RESOURCE_FILES)"; do \
	  cp -r $$f $(FRAMEWORK_VERSION_DIR_NAME)/Resources; \
	done
endif

framework-localized-resource-files:: $(FRAMEWORK_VERSION_DIR_NAME)/Resources/Info-gnustep.plist
ifneq ($(strip $(LOCALIZED_RESOURCE_FILES)),)
	@ echo "Copying localized resources into the framework wrapper..."; \
	for l in $(LANGUAGES); do \
	  if [ -d $$l.lproj ]; then \
	    $(MKDIRS) $(FRAMEWORK_VERSION_DIR_NAME)/Resources/$$l.lproj; \
	    for f in $(LOCALIZED_RESOURCE_FILES); do \
	      if [ -f $$l.lproj/$$f ]; then \
	        cp -r $$l.lproj/$$f $(FRAMEWORK_VERSION_DIR_NAME)/Resources/$$l.lproj; \
	      fi; \
	    done; \
	  else \
	    echo "Warning: $$l.lproj not found - ignoring"; \
	  fi; \
	done
endif

$(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources:
	$(MKDIRS) $@

$(FRAMEWORK_WEBSERVER_RESOURCE_DIRS):
	$(MKDIRS) $@

framework-webresource-dir:: $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources\
                            $(FRAMEWORK_WEBSERVER_RESOURCE_DIRS)
	@ if [ ! -L "$(FRAMEWORK_DIR_NAME)/WebServerResources" ]; then \
	  rm -f $(FRAMEWORK_DIR_NAME)/WebServerResources; \
	  $(LN_S) Versions/Current/WebServerResources $(FRAMEWORK_DIR_NAME);\
	fi

framework-webresource-files::

ifneq ($(strip $(WEBSERVER_RESOURCE_FILES)),)
framework-webresource-files:: framework-webresource-dir
	@ echo "Copying webserver resources into the framework wrapper..."; \
	for ff in $(WEBSERVER_RESOURCE_FILES); do \
	  if [ -f ./WebServerResources/$$ff ]; then \
	    cp -r ./WebServerResources/$$ff \
                  $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources/$$ff; \
	  fi; \
	done
endif

framework-localized-webresource-files::

ifneq ($(strip $(LOCALIZED_WEBSERVER_RESOURCE_FILES)),)
framework-localized-webresource-files:: framework-webresource-dir
	@ echo "Copying localized webserver resources into the framework wrapper..."; \
	for l in $(LANGUAGES); do \
	  if [ -d WebServerResources/$$l.lproj ]; then \
	    $(MKDIRS) \
	        $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources/$$l.lproj;\
	    for f in $(LOCALIZED_WEBSERVER_RESOURCE_FILES); do \
	      if [ -f WebServerResources/$$l.lproj/$$f ]; then \
	        cp -r WebServerResources/$$l.lproj/$$f \
	              $(FRAMEWORK_VERSION_DIR_NAME)/WebServerResources/$$l.lproj/$$f; \
	      fi;\
	    done;\
	  else \
	   echo "Warning: WebServerResources/$$l.lproj not found - ignoring"; \
	  fi; \
	done
endif

ifeq ($(PRINCIPAL_CLASS),)
override PRINCIPAL_CLASS = $(INTERNAL_framework_NAME)
endif

# MacOSX-S frameworks
$(FRAMEWORK_VERSION_DIR_NAME)/Resources/Info.plist: $(FRAMEWORK_VERSION_DIR_NAME)/Resources
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_TARGET_LDIR)/$(FRAMEWORK_NAME)${FRAMEWORK_OBJ_EXT}\";"; \
	  if [ "$(MAIN_MODEL_FILE)" = "" ]; then \
	    echo "  NSMainNibFile = \"\";"; \
	  else \
	    echo "  NSMainNibFile = \"`echo $(MAIN_MODEL_FILE) | sed 's/.gmodel//'`\";"; \
	  fi; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "}") >$@

# GNUstep frameworks
$(FRAMEWORK_VERSION_DIR_NAME)/Resources/Info-gnustep.plist: $(FRAMEWORK_VERSION_DIR_NAME)/Resources
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(INTERNAL_framework_NAME)${FRAMEWORK_OBJ_EXT}\";"; \
	  if [ "$(MAIN_MODEL_FILE)" = "" ]; then \
	    echo "  NSMainNibFile = \"\";"; \
	  else \
	    echo "  NSMainNibFile = \"`echo $(MAIN_MODEL_FILE) | sed 's/.gmodel//'`\";"; \
	  fi; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "}") >$@


ifneq ($(WITH_DLL),yes)

internal-framework-install:: $(FRAMEWORK_INSTALL_DIR) \
                      $(GNUSTEP_FRAMEWORKS_LIBRARIES)/$(GNUSTEP_TARGET_LDIR) \
                      $(GNUSTEP_FRAMEWORKS_HEADERS)
	rm -rf $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME)
	$(TAR) cf - $(FRAMEWORK_DIR_NAME) | (cd $(FRAMEWORK_INSTALL_DIR); $(TAR) xf -)
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME)
endif
ifeq ($(strip),yes)
	$(STRIP) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_FILE) 
endif
	@(cd $(GNUSTEP_FRAMEWORKS_HEADERS); \
	if [ "$(HEADER_FILES)" != "" ]; then \
	  if test -L "$(INTERNAL_framework_NAME)"; then \
	    rm -f $(INTERNAL_framework_NAME); \
	  fi; \
	  $(LN_S) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME)/Headers $(INTERNAL_framework_NAME); \
	fi;)
ifneq ($(CHOWN_TO),)
	@(cd $(GNUSTEP_FRAMEWORKS_HEADERS); \
	if [ "$(HEADER_FILES)" != "" ]; then \
	  $(CHOWN) $(CHOWN_TO) $(INTERNAL_framework_NAME); \
	fi;)
endif
	@(cd $(GNUSTEP_FRAMEWORKS_LIBRARIES)/$(GNUSTEP_TARGET_LDIR); \
	if test -f "$(FRAMEWORK_LIBRARY_FILE)"; then \
	  rm -f $(FRAMEWORK_LIBRARY_FILE); \
	fi; \
	if test -f "$(SONAME_FRAMEWORK_FILE)"; then \
	  rm -f $(SONAME_FRAMEWORK_FILE); \
	fi; \
	if test -f "$(VERSION_FRAMEWORK_LIBRARY_FILE)"; then \
	  rm -f $(VERSION_FRAMEWORK_LIBRARY_FILE); \
	fi; \
	$(LN_S) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_CURRENT_LIBRARY_DIR_NAME)/$(FRAMEWORK_LIBRARY_FILE) $(FRAMEWORK_LIBRARY_FILE); \
	if test -f "$(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_CURRENT_LIBRARY_DIR_NAME)/$(SONAME_FRAMEWORK_FILE)"; then \
	  $(LN_S) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_CURRENT_LIBRARY_DIR_NAME)/$(SONAME_FRAMEWORK_FILE) $(SONAME_FRAMEWORK_FILE); \
	fi; \
	$(LN_S) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_CURRENT_LIBRARY_DIR_NAME)/$(VERSION_FRAMEWORK_LIBRARY_FILE) $(VERSION_FRAMEWORK_LIBRARY_FILE);)
ifneq ($(CHOWN_TO),)
	(cd $(GNUSTEP_FRAMEWORKS_LIBRARIES)/$(GNUSTEP_TARGET_LDIR); \
	$(CHOWN) $(CHOWN_TO) $(FRAMEWORK_LIBRARY_FILE); \
	if test -f "$(SONAME_FRAMEWORK_FILE)"; then \
	  $(CHOWN) $(CHOWN_TO) $(SONAME_FRAMEWORK_FILE); \
	fi; \
	$(CHOWN) $(CHOWN_TO) $(VERSION_FRAMEWORK_LIBRARY_FILE))
endif

else # install DLL

internal-framework-install:: $(FRAMEWORK_INSTALL_DIR) \
                      $(GNUSTEP_FRAMEWORKS_LIBRARIES)/$(GNUSTEP_TARGET_LDIR) \
                      $(GNUSTEP_FRAMEWORKS_HEADERS) \
                      $(DLL_INSTALLATION_DIR)
	rm -rf $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME)
	$(TAR) cf - $(FRAMEWORK_DIR_NAME) | (cd $(FRAMEWORK_INSTALL_DIR); $(TAR) xf -)
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME)
endif
ifeq ($(strip),yes)
	$(STRIP) $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_FILE) 
endif
	(cd $(GNUSTEP_FRAMEWORKS_HEADERS); \
	if [ "$(HEADER_FILES)" != "" ]; then \
	  if test -d "$(INTERNAL_framework_NAME)"; then \
	    rm -Rf $(INTERNAL_framework_NAME); \
	  fi; \
          $(MKINSTALLDIRS) $(INTERNAL_framework_NAME); \
	  cd $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_VERSION_DIR_NAME)/Headers ; \
            $(TAR) cf - . | (cd  $(GNUSTEP_FRAMEWORKS_HEADERS)/$(INTERNAL_framework_NAME); \
            $(TAR) xf - ); \
	fi;)
ifneq ($(CHOWN_TO),)
	@(cd $(GNUSTEP_FRAMEWORKS_HEADERS); \
	if [ "$(HEADER_FILES)" != "" ]; then \
	  $(CHOWN) -R $(CHOWN_TO) $(INTERNAL_framework_NAME); \
	fi;)
endif
	(cd $(DLL_INSTALLATION_DIR); \
	if test -f "$(FRAMEWORK_FILE)"; then \
	  rm -f $(FRAMEWORK_FILE); \
	fi;)
	$(INSTALL_PROGRAM) -m 0755 $(FRAMEWORK_FILE) \
          $(DLL_INSTALLATION_DIR)/$(FRAMEWORK_FILE);

endif

$(DLL_INSTALLATION_DIR)::
	$(MKINSTALLDIRS) $@

$(FRAMEWORK_DIR_NAME)/Resources::
	$(MKDIRS) $@

$(FRAMEWORK_INSTALL_DIR)::
	@$(MKINSTALLDIRS) $@

$(GNUSTEP_FRAMEWORKS_LIBRARIES)/$(GNUSTEP_TARGET_LDIR) :
	$(MKINSTALLDIRS) $@

$(GNUSTEP_FRAMEWORKS_HEADERS) :
	$(MKINSTALLDIRS) $@

internal-framework-uninstall::
	if [ "$(HEADER_FILES)" != "" ]; then \
	  for file in $(HEADER_FILES) __done; do \
	    if [ $$file != __done ]; then \
	      rm -rf $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	    fi; \
	  done; \
	fi; \
	rm -rf $(FRAMEWORK_INSTALL_DIR)/$(FRAMEWORK_DIR_NAME)

#
# Cleaning targets
#
internal-framework-clean::
	rm -rf $(GNUSTEP_OBJ_DIR) $(PSWRAP_C_FILES) $(PSWRAP_H_FILES) \
	       $(FRAMEWORK_DIR_NAME) $(DERIVED_SOURCES)

internal-framework-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj $(DERIVED_SOURCES)

endif

endif
# framework.make loaded

## Local variables:
## mode: makefile
## End:
