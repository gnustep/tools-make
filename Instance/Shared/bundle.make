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
#  $(GNUSTEP_INSTANCE)_RESOURCE_FILES : a list of resource files to install.
#  They are recursively copied (/symlinked), so it might also include dirs.
#
#  $(GNUSTEP_INSTANCE)_RESOURCE_DIRS : a list of additional resource dirs
#  to create.
#
#  $(GNUSTEP_INSTANCE)_LANGUAGES : the list of languages of localized resource
#  files
#
#  $(GNUSTEP_INSTANCE)_LOCALIZED_RESOURCE_FILES : a list of localized
#  resource files to install.
#
#  $(GNUSTEP_INSTANCE)_RESOURCE_DIRS : a list of additional localized
#  resource dirs to create.
#
#  $(GNUSTEP_INSTANCE)_COMPONENTS : a list of directories which are
#  recursively copied (/locally symlinked if symlinks are available)
#  into the resource bundle.  Basically, they are currently added to
#  $(GNUSTEP_INSTANCE)_RESOURCE_FILES.
#
#  $(GNUSTEP_INSTANCE)_LOCALIZED_COMPONENTS : a list of localized
#  directories which are recursively copied (/locally symlinked if
#  symlinks are available) into the resource bundle.  Currently, they
#  are simply added to $(GNUSTEP_INSTANCE)_LOCALIZED_RESOURCE_FILES.
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
# $(GNUSTEP_INSTANCE)_WEBSERVER_LOCALIZED_RESOURCE_FILES : a list of
# localized resource files to copy from the yyy.lproj subdir of the
# WebServerResources directory into the yyy.lproj subdir of the
# WebServer subdirectory of the resource bundle - this for each
# language yyy.
#
# $(GNUSTEP_INSTANCE)_WEBSERVER_COMPONENTS:
# $(GNUSTEP_INSTANCE)_WEBSERVER_LOCALIZED_COMPONENTS:
# $(GNUSTEP_INSTANCE)_WEBSERVER_RESOURCE_DIRS:
# $(GNUSTEP_INSTANCE)_WEBSERVER_LOCALIZED_RESOURCE_DIRS:
#

#
# public targets:
# 
#  shared-instance-bundle-all
#
#  $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH): Creates the bundle
#  resource path (invoked automatically)
#

RESOURCE_FILES = $(strip $($(GNUSTEP_INSTANCE)_RESOURCE_FILES)) \
                 $(strip $($(GNUSTEP_INSTANCE)_COMPONENTS))
RESOURCE_DIRS = $(strip $($(GNUSTEP_INSTANCE)_RESOURCE_DIRS))
LANGUAGES = $(strip $($(GNUSTEP_INSTANCE)_LANGUAGES))
LOCALIZED_RESOURCE_FILES = \
  $(strip $($(GNUSTEP_INSTANCE)_LOCALIZED_RESOURCE_FILES)) \
  $(strip $($(GNUSTEP_INSTANCE)_LOCALIZED_COMPONENTS))
LOCALIZED_RESOURCE_DIRS = \
  $(strip $($(GNUSTEP_INSTANCE)_LOCALIZED_RESOURCE_DIRS))

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
  LANGUAGES = English
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

# Please note the trick when copying subproject resources - if there
# is nothing inside $$subproject/Resources/Subproject/, in
# $$subproject/Resources/Subproject/* the * expands to itself.  So we
# check if that is true before trying to copy.

shared-instance-bundle-all: $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH) \
                      $(FULL_RESOURCE_DIRS) \
                      shared-instance-bundle-all-gsweb
ifneq ($(RESOURCE_FILES),)
	@(echo "Copying resources into the $(GNUSTEP_TYPE) wrapper..."; \
	for f in $(RESOURCE_FILES); do \
	  if [ -f $$f -o -d $$f ]; then \
	    cp -r $$f $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH); \
	  else \
	    echo "Warning: $$f not found - ignoring"; \
	  fi; \
	done)
endif
ifneq ($(LOCALIZED_RESOURCE_DIRS),)
	@(echo "Creating localized resource dirs into the $(GNUSTEP_TYPE) wrapper..."; \
	for l in $(LANGUAGES); do \
	  if [ -d $$l.lproj ]; then \
	    $(MKDIRS) $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/$$l.lproj; \
	    for f in $(LOCALIZED_RESOURCE_DIRS); do \
	      $(MKDIRS) $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/$$l.lproj/$$f; \
	    done; \
	  else \
	    echo "Warning: $$l.lproj not found - ignoring"; \
	  fi; \
	done)
endif
ifneq ($(LOCALIZED_RESOURCE_FILES),)
	@(echo "Copying localized resources into the $(GNUSTEP_TYPE) wrapper..."; \
	for l in $(LANGUAGES); do \
	  if [ -d $$l.lproj ]; then \
	    $(MKDIRS) $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/$$l.lproj; \
	    for f in $(LOCALIZED_RESOURCE_FILES); do \
	      if [ -f $$l.lproj/$$f -o -d $$l.lproj/$$f ]; then \
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
ifneq ($(_SUBPROJECTS),)
	@(echo "Copying resources from subprojects into the $(GNUSTEP_TYPE) wrapper..."; \
	for subproject in $(_SUBPROJECTS); do \
	  if [ -d $$subproject/Resources/Subproject ]; then \
	    if [ $$subproject/Resources/Subproject/* != $$subproject'/Resources/Subproject/*' ]; then \
	      cp -r $$subproject/Resources/Subproject/* \
	            $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/; \
	    fi; \
	  fi; \
	done)
endif

##
##
## GSWeb code
## A main issue here is - executing *nothing* if gsweb is not used :-)
##
##

WEBSERVER_RESOURCE_FILES = \
  $(strip $($(GNUSTEP_INSTANCE)_WEBSERVER_RESOURCE_FILES)) \
  $(strip $($(GNUSTEP_INSTANCE)_WEBSERVER_COMPONENTS))
# For historical reasons, we recognized the old variant
# xxx_LOCALIZED_WEBSERVER_RESOURCE_FILES - but we recommend to use
# xxx_WEBSERVER_LOCALIZED_RESOURCE_FILES instead.
WEBSERVER_LOCALIZED_RESOURCE_FILES = \
  $(strip $($(GNUSTEP_INSTANCE)_LOCALIZED_WEBSERVER_RESOURCE_FILES)) \
  $(strip $($(GNUSTEP_INSTANCE)_WEBSERVER_LOCALIZED_RESOURCE_FILES)) \
  $(strip $($(GNUSTEP_INSTANCE)_WEBSERVER_LOCALIZED_COMPONENTS))
WEBSERVER_RESOURCE_DIRS = \
  $(strip $($(GNUSTEP_INSTANCE)_WEBSERVER_RESOURCE_DIRS))
WEBSERVER_LOCALIZED_RESOURCE_DIRS = \
  $(strip $($(GNUSTEP_INSTANCE)_WEBSERVER_LOCALIZED_RESOURCE_DIRS))


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
	for f in $(WEBSERVER_RESOURCE_FILES); do \
	  if [ -f ./WebServerResources/$$f \
	       -o -d ./WebServerResources/$$f ]; then \
	    cp -r ./WebServerResources/$$f \
	       $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer/$$f; \
	  else \
	    echo "Warning: WebServerResources/$$f not found - ignoring"; \
	  fi; \
	done)
else

shared-instance-bundle-all-webresources:

endif

ifneq ($(WEBSERVER_LOCALIZED_RESOURCE_FILES)$(WEBSERVER_LOCALIZED_RESOURCE_DIRS),)
shared-instance-bundle-all-localized-webresources: \
  $(WEBSERVER_FULL_RESOURCE_DIRS)
ifneq ($(WEBSERVER_LOCALIZED_RESOURCE_DIRS),)
	@(echo "Creating localized webserver resource dirs into the $(GNUSTEP_TYPE) wrapper..."; \
	for l in $(LANGUAGES); do \
	 if [ -d ./WebServerResources/$$l.lproj ]; then \
	  $(MKDIRS) \
	   $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer/$$l.lproj; \
	  for f in $(WEBSERVER_LOCALIZED_RESOURCE_DIRS); do \
	   $(MKDIRS) \
	     $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer/$$l.lproj/$$f; \
	    done; \
	  else \
	    echo "Warning: WebServer/$$l.lproj not found - ignoring"; \
	  fi; \
	done)
endif
	@(echo "Copying localized webserver resources into the $(GNUSTEP_TYPE) wrapper..."; \
	for l in $(LANGUAGES); do \
	 if [ -d ./WebServerResources/$$l.lproj ]; then \
	  $(MKDIRS) \
	  $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer/$$l.lproj;\
	  for f in $(WEBSERVER_LOCALIZED_RESOURCE_FILES); do \
	   if [ -f ./WebServerResources/$$l.lproj/$$f \
	        -o -d ./WebServerResources/$$l.lproj/$$f ]; then \
	    cp -r ./WebServerResources/$$l.lproj/$$f \
	          $(GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH)/WebServer/$$l.lproj/$$f; \
	      else \
	        echo "Warning: WebServerResources/$$l.lproj/$$f not found - ignoring"; \
	      fi; \
	    done; \
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
