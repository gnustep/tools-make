#
#   source-distribution.make
#
#   Makefile rules to build snapshots from cvs, source .tar.gz etc
#
#   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
#
#   Author: Adam Fedor <fedor@gnu.org>
#   Author: Nicola Pero <n.pero@mi.flashnet.it>
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
# Interesting variables to define in your GNUmakefile:
#
# PACKAGE_NAME = gnustep-base
# VERSION = 1.0.0
#
# For CVS exports, you may want to define something like:
#
# CVS_MODULE_NAME = base
# CVS_FLAGS = -d :pserver:anoncvs@subversions.gnu.org:/cvsroot/gnustep
#
# You can also pass/override them on the command line if you want,
# make cvs-snapshot CVS_FLAGS="-d :pserver:anoncvs@subversions.gnu.org:/cvsroot/gnustep -z9"
#
# If you set the RELEASE_DIR variable, all generated .tar.gz files will 
# be automatically moved to that directory after having being created.
# RELEASE_DIR is either an absolute path, or a relative path to the 
# current directory.
#

# prevent multiple inclusions
ifeq ($(SOURCE_DISTRIBUTION_MAKE_LOADED),)
SOURCE_DISTRIBUTION_MAKE_LOADED=yes

ifeq ($(CVS_MODULE_NAME),)
  CVS_MODULE_NAME = $(PACKAGE_NAME)
endif

ifeq ($(CVS_FLAGS),)
  CVS_FLAGS = -z3
endif

VERSION_NAME = $(PACKAGE_NAME)-$(VERSION)

VERTAG = `echo $(VERSION) | tr '.' '_'`

.PHONY: dist cvs-tag cvs-dist cvs-snapshot internal-cvs-export

#
# Build a .tgz with the whole directory tree
#
dist: distclean
	@echo "Generating $(VERSION_NAME).tar.gz in the parent directory..."; \
	SNAPSHOT_DIR=`basename $$(pwd)`; \
	cd ..;                           \
	if [ "$$SNAPSHOT_DIR" != "$(VERSION_NAME)" ]; then \
	  if [ -d "$(VERSION_NAME)" ]; then \
	    echo "$(VERSION_NAME) already exists in parent directory (?):"; \
	    echo "Saving old version in $(VERSION_NAME)~"; \
	    mv $(VERSION_NAME) $(VERSION_NAME)~; \
	  fi; \
	  mv $$SNAPSHOT_DIR $(VERSION_NAME);\
        fi; \
	if [ -f ${VERSION_NAME}.tar.gz ]; then             \
	  echo "${VERSION_NAME}.tar.gz already exists:";    \
	  echo "Saving old version in ${VERSION_NAME}.tar.gz~"; \
	  mv ${VERSION_NAME}.tar.gz ${VERSION_NAME}.tar.gz~;    \
	fi; \
	tar cfz $(VERSION_NAME).tar.gz $(VERSION_NAME);    \
	if [ "$$SNAPSHOT_DIR" != "$(VERSION_NAME)" ]; then \
	  mv $(VERSION_NAME) $$SNAPSHOT_DIR;               \
        fi; \
	if [ ! -f $(VERSION_NAME).tar.gz ]; then \
	  echo "*Error* creating .tar.gz"; \
	  exit 1; \
	fi;
ifneq ($(RELEASE_DIR),)
	@echo "Moving $(VERSION_NAME).tar.gz to $(RELEASE_DIR)..."; \
	if [ ! -d $(RELEASE_DIR) ]; then \
	  $(MKDIRS) $(RELEASE_DIR); \
	fi; \
	if [ -f $(RELEASE_DIR)/$(VERSION_NAME).tar.gz ]; then \
	  echo "$(RELEASE_DIR)/${VERSION_NAME}.tar.gz already exists:";    \
	  echo "Saving old version in $(RELEASE_DIR)/${VERSION_NAME}.tar.gz~";\
	  mv $(RELEASE_DIR)/${VERSION_NAME}.tar.gz \
	     $(RELEASE_DIR)/${VERSION_NAME}.tar.gz~;\
	fi; \
	mv ../$(VERSION_NAME).tar.gz $(RELEASE_DIR)
endif

#
# Tag the CVS source with the $(CVS_MODULE_NAME)-$(VERTAG) tag
#
cvs-tag:
	cvs $(CVS_FLAGS) rtag $(CVS_MODULE_NAME)-$(VERTAG) $(CVS_MODULE_NAME)

#
# Build a .tar.gz from the CVS sources using revision/tag 
# $(CVS_MODULE_NAME)-$(VERTAG)
#
cvs-dist: EXPORT_CVS_FLAGS = -r $(CVS_MODULE_NAME)-$(VERTAG) 
cvs-dist: internal-cvs-export

#
# Build a .tar.gz from the CVS source as they are now
#
cvs-snapshot: EXPORT_CVS_FLAGS = -D now
cvs-snapshot: internal-cvs-export

internal-cvs-export:
	@echo "Exporting from module $(CVS_MODULE_NAME) on CVS..."; \
	if [ -e $(CVS_MODULE_NAME) ]; then \
	  echo "*Error* cannot export: $(CVS_MODULE_NAME) already exists"; \
	  exit 1; \
	fi; \
	cvs $(CVS_FLAGS) export $(EXPORT_CVS_FLAGS) $(CVS_MODULE_NAME); \
	echo "Generating $(VERSION_NAME).tar.gz"; \
	mv $(CVS_MODULE_NAME) $(VERSION_NAME); \
	if [ -f ${VERSION_NAME}.tar.gz ]; then            \
	  echo "${VERSION_NAME}.tar.gz already exists:";   \
	  echo "Saving old version in ${VERSION_NAME}.tar.gz~"; \
	  mv ${VERSION_NAME}.tar.gz ${VERSION_NAME}.tar.gz~;    \
	fi; \
	tar cfz $(VERSION_NAME).tar.gz $(VERSION_NAME); \
	rm -rf $(VERSION_NAME);                  \
	if [ ! -f $(VERSION_NAME).tar.gz ]; then \
	  echo "*Error* creating .tar.gz"; \
	  exit 1; \
	fi;
ifneq ($(RELEASE_DIR),)
	@echo "Moving $(VERSION_NAME).tar.gz to $(RELEASE_DIR)..."; \
	if [ ! -d $(RELEASE_DIR) ]; then \
	  $(MKDIRS) $(RELEASE_DIR); \
	fi; \
	if [ -f $(RELEASE_DIR)/$(VERSION_NAME).tar.gz ]; then \
	  echo "$(RELEASE_DIR)/${VERSION_NAME}.tar.gz already exists:";    \
	  echo "Saving old version in $(RELEASE_DIR)/${VERSION_NAME}.tar.gz~";\
	  mv $(RELEASE_DIR)/${VERSION_NAME}.tar.gz \
	     $(RELEASE_DIR)/${VERSION_NAME}.tar.gz~;\
	fi; \
	mv $(VERSION_NAME).tar.gz $(RELEASE_DIR)
endif

endif
# source-distribution.make loaded

## Local variables:
## mode: makefile
## End:

