#
#   Shared/bundle.make
#
#   Makefile fragment with rules to copy resource files 
#   into a local bundle
#
#   Copyright (C) 2002 Free Software Foundation, Inc.
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

#
# input variables:
#

#
#  GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH : the path to the
#  local resource bundle (this might be a subdirectory of the actual
#  bundle directory).  Resource files will be copied into this path.
#  For example, for a normal bundle it would be
#  $(BUNDLE_DIR)/Resources; for an application it would be
#  $(APP_DIR)/Resources; for a library or a tool,
#  Resources/$(GNUSTEP_INSTANCE).  This variable is used during build,
#  to copy the resources in place.
#
#  GNUSTEP_SHARED_INSTANCE_BUNDLE_MAIN_PATH : the path to the top
#  level bundle directory to install.  For example, for a normal
#  bundle it would be $(BUNDLE_DIR); for an application it would be
#  $(APP_DIR); for a library or a tool, Resources/$(GNUSTEP_INSTANCE).
#
#  GNUSTEP_SHARED_INSTANCE_BUNDLE_PRESERVE_LINK_PATH : the path
#  to a symlink to preserve when installing.  Normally symlinks are
#  dereferenced, but we have support to preserve a single symlink.
#  This is used when building bundles on MacOSX.  If not set, it's
#  ignored.
#
#  $(GNUSTEP_INSTANCE)_RESOURCE_FILES : the list of resource files to install
#
#  $(GNUSTEP_INSTANCE)_RESOURCE_FILES_DIR : the directory in which the
#  resources are located.
#
#  $(GNUSTEP_INSTANCE)_RESOURCE_DIRS : the list of additional resource dirs
#  to create.
#
#  $(GNUSTEP_INSTANCE)_LANGUAGES : the list of languages of localized resource
#  files
#
#  $(GNUSTEP_INSTANCE)_LOCALIZED_RESOURCE_FILES : the list of localized
#  resource files to install
#
#  $(GNUSTEP_INSTANCE)_COMPONENTS : a list of directories which are
#  recursively copied (/locally symlinked if symlinks are available)
#  into the resource bundle. <FIXME - not sure this will be kept>
#
#  $(GNUSTEP_INSTANCE)_SUBPROJECTS : the list of subprojects is used
#  because the resources from each subproject are merged into the bundle
#  resources (by recursively copying from LLL/Resources/Subproject into
#  the GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH, where $(LLL) is the
#  subproject name.
#
#  GNUSTEP_TYPE : used when printing the message 'Copying resources into 
#  the $(GNUSTEP_TYPE) wrapper...'
#
# GSWeb related variables - 
#
# $(GNUSTEP_INSTANCE)_WEBSERVER_RESOURCE_FILES : a list of resource files to
# copy from the WebServerResources directory into the WebServer
# subdirectory of the resource bundle
#
# $(GNUSTEP_INSTANCE)_LOCALIZED_WEBSERVER_RESOURCE_FILES : a list of
# localized resource files to copy from the yyy.lproj subdir of the
# WebServerResources directory into the yyy.lproj subdir of the
# WebServer subdirectory of the resource bundle - this for each
# language yyy.


#
# public targets:
# 
#  shared-instance-bundle-all
#
#  $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH): Creates the bundle
#  resource path (invoked automatically)
#

# NB: The 'override' in all this file are needed to override the
# Master/rules.make setting of LANGUAGES and similar variables.
# Once that setting will be removed (as it should be), the 'override'
# in this file should be removed as well.
override RESOURCE_FILES = $(strip $($(GNUSTEP_INSTANCE)_RESOURCE_FILES))
override RESOURCE_DIRS = $(strip $($(GNUSTEP_INSTANCE)_RESOURCE_DIRS))
override LANGUAGES = $(strip $($(GNUSTEP_INSTANCE)_LANGUAGES))
override LOCALIZED_RESOURCE_FILES = $(strip $($(GNUSTEP_INSTANCE)_LOCALIZED_RESOURCE_FILES))
override COMPONENTS = $(strip $($(GNUSTEP_INSTANCE)_COMPONENTS))

# NB: Use _SUBPROJECTS, not SUBPROJECTS here as that might conflict
# with what is used in aggregate.make.
_SUBPROJECTS = $(strip $($(GNUSTEP_INSTANCE)_SUBPROJECTS))

.PHONY: \
shared-instance-bundle-all \
shared-instance-bundle-all-resources \
shared-instance-bundle-all-gsweb

ifneq ($(RESOURCE_DIRS),)

FULL_RESOURCE_DIRS = \
$(foreach d, $(RESOURCE_DIRS), $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/$(d))

endif

ifeq ($(LANGUAGES),)
override LANGUAGES = English
endif

$(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH):
	$(MKDIRS) $@

$(FULL_RESOURCE_DIRS):
	$(MKDIRS) $@


#
# We provide two different ways of building bundles, suited to
# different usages - normal user and developer.
#
# `Normal user` builds the bundle once.  We optimize for single-build
# in this case.
#
# `Developer` builds and rebuilds the bundle a lot of times with minor
# changes each time.  We optimize for efficient rebuilding in this
# case.
#
# The default behaviour is 'Normal user'.  To switch to 'Developer'
# mode, set GNUSTEP_DEVELOPER=YES in the environment.
#
# TODO - implement the `Developer` mode :-)
#

shared-instance-bundle-all: $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH) \
                      $(FULL_RESOURCE_DIRS) \
                      shared-instance-bundle-all-gsweb
ifneq ($(RESOURCE_FILES),)
	@(echo "Copying resources into the $(GNUSTEP_TYPE) wrapper..."; \
	for f in $(RESOURCE_FILES); do \
	  cp -r $$f $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH); \
	done)
endif
ifneq ($(LOCALIZED_RESOURCE_FILES),)
	@(echo "Copying localized resources into the $(GNUSTEP_TYPE) wrapper..."; \
	for l in $(LANGUAGES); do \
	  if [ -d $$l.lproj ]; then \
	    $(MKDIRS) $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/$$l.lproj; \
	    for f in $(LOCALIZED_RESOURCE_FILES); do \
	      if [ -f $$l.lproj/$$f ]; then \
	        cp -r $$l.lproj/$$f \
	              $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/$$l.lproj; \
	      else \
	        echo "Warning: $$l.lproj/$$f not found - ignoring"; \
	      fi; \
	    done; \
	  else \
	    echo "Warning: $$l.lproj not found - ignoring"; \
	  fi; \
	done)
endif
ifneq ($(COMPONENTS),)
	@(echo "Copying components into the $(GNUSTEP_TYPE) wrapper..."; \
	for component in $(COMPONENTS); do \
	 if [ -d $$component ]; then \
	  cp -r $$component $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/;\
	 fi; \
	done)
endif
ifneq ($(_SUBPROJECTS),)
	@(echo "Copying resources from subprojects into the $(GNUSTEP_TYPE) wrapper..."; \
	for subproject in $(_SUBPROJECTS); do \
	  if [ -d $$subproject/Resources/Subproject ]; then \
	    cp -r $$subproject/Resources/Subproject/* $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/; \
	  fi; \
	done)
endif

##
##
## GSWeb code
##
##

override WEBSERVER_RESOURCE_FILES = $(strip $($(GNUSTEP_INSTANCE)_WEBSERVER_RESOURCE_FILES))
# For historical reasons, the external API is different for the following one
override WEBSERVER_LOCALIZED_RESOURCE_FILES = $(strip $($(GNUSTEP_INSTANCE)_LOCALIZED_WEBSERVER_RESOURCE_FILES))
override WEBSERVER_RESOURCE_DIRS = $(strip $($(GNUSTEP_INSTANCE)_WEBSERVER_RESOURCE_DIRS))


ifneq ($(WEBSERVER_RESOURCE_DIRS),)

WEBSERVER_FULL_RESOURCE_DIRS = \
$(foreach d, $(WEBSERVER_RESOURCE_DIRS), $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer/$(d))

$(WEBSERVER_FULL_RESOURCE_DIRS):
	$(MKDIRS) $@

endif


.PHONY: shared-instance-bundle-all-webresources \
       shared-instance-bundle-all-localized-webresources

shared-instance-bundle-all-gsweb: shared-instance-bundle-all-webresources \
                           shared-instance-bundle-all-localized-webresources

ifneq ($(WEBSERVER_RESOURCE_FILES),)

$(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer:
	$(MKDIRS) $@

shared-instance-bundle-all-webresources: \
  $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer \
  $(WEBSERVER_FULL_RESOURCE_DIRS)
	@(echo "Copying webserver resources into the $(GNUSTEP_TYPE) wrapper..."; \
	for file in $(WEBSERVER_RESOURCE_FILES); do \
	 cp -r ./WebServerResources/$$file \
	    $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer/$$file;\
	done)
else

shared-instance-bundle-all-webresources:

endif

ifneq ($(LOCALIZED_WEBSERVER_RESOURCE_FILES),)
shared-instance-bundle-all-localized-webresources: \
  $(WEBSERVER_FULL_RESOURCE_DIRS)
	@( echo "Copying localized webserver resources into the $(GNUSTEP_TYPE) wrapper..."; \
	for l in $(LANGUAGES); do \
	 if [ -d WebServerResources/$$l.lproj ]; then \
	  $(MKDIRS) \
	  $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer/$$l.lproj;\
	  for f in $(LOCALIZED_WEBSERVER_RESOURCE_FILES); do \
	   if [ -f WebServerResources/$$l.lproj/$$f ]; then \
	    cp -r WebServerResources/$$l.lproj/$$f \
	     $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer/$$l.lproj/$$f; \
	   else \
	    echo "Warning: WebServerResources/$$l.lproj/$$f not found - ignoring";\
	   fi;\
	  done;\
	 else \
	  echo "Warning: WebServerResources/$$l.lproj not found - ignoring"; \
	 fi; \
	done)

else

shared-instance-bundle-all-localized-webresources:

endif



## Local variables:
## mode: makefile
## End:
