#
#   rpm.make
#
#   Makefile rules to build a RPM spec files and RPM packages
#
#   Copyright (C) 2000 Free Software Foundation, Inc.
#
#   Author: Adam Fedor <fedor@gnu.org>
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

# rpm puts all tools, bundles, applications, subprojects, libraries, etc
# specified in the GNUmakefile into a single rpm. There aren't any provisions
# for putting separate apps/tools/etc in separate rpms (other than putting
# them in separate dirs).
#
# Common variables (Recommend you set all these):
# PACKAGE_NAME		- Name of the rpm package (REQUIRED)
# PACKAGE_DOCS		- Docs that go in /usr/doc
# VERSION		- Version (defaults to 1.0.0)
# GNUSTEP_INSTALLATION_DIR - Installation dir (defaults to Local root).
# PACKAGE_SOURCE	- Source file location
# PACKAGE_COPYRIGHT	- Copyright (GPL, etc)
# PACKAGE_SUMMARY	- Summary information
# PACKAGE_DESCRIPTION	- Package description
# PACKAGER		- Pacakger information
# PACKAGE_URL		- URL information
# PACKAGE_SUMMARY_DEVEL	- Summary information for devel package
# PACKAGE_DESCRIPTION_DEVEL - Devel package description
#
# RPM Specific variables (only needed in for unusual packaging requirements):
# RPM_RELEASE		- Release version
# RPM_GROUP		- Group information
# RPM_DIST		- Distributor information
# RPM_VENDOR		- Vendor information
# RPM_CONFLICTS		- Conflicting packages
# RPM_REQUIRES		- Required packages
# RPM_SETUP		- Additional setup instructions
# RPM_CONFIGURE		- Additional configuration (including configure script)
# RPM_ADDITIONAL_INSTALL- Additional install instructions
# RPM_POST		- Post instalation instructions
# RPM_PREUNINSTALL	- Preuninstall instructions
# RPM_POSTUNINSTALL	- Postuninstall instructions
# RPM_FILELIST		- Additional files to include in filelist
# RPM_FILELIST_DEVEL	- Additional files to include in filelist-devel
# RPM_DIRLIST		- Additional directories owned by package
# RPM_DIRLIST_DEVEL	- Additional directories owned by package
# RPM_CONFLICTS_DEVEL	- Conflicting packages for devel package
# RPM_REQUIRES_DEVEL	- Required packages for devel package
#
# Current Limitations:
#  - Not much configurability, such as, say, making debug=yes or different
#    libcombo's, although that stuff should be common throughout rpms anyway
#  - Naming information (e.g. shared vs dll vs static library names) are
#    locked in the spec file. Need to figure out how to insert those variables
#    into the spec file.
#  - No architecture specific configurability (aka with libs)

# prevent multiple inclusions
ifeq ($(RPM_MAKE_LOADED),)
RPM_MAKE_LOADED=yes

# Default variable settings
ifeq ($(DATE),)
  DATE=`date +"%Y%m%d"`
endif
ifeq ($(RPM_RELEASE),)
  RPM_RELEASE = 1
endif
ifeq ($(PACKAGE_SOURCE),)
  PACKAGE_SOURCE = ftp://ftp.gnustep.org/pub/gnustep/$(PACKAGE_NAME)-$(VERSION).tar.gz
endif
ifeq ($(PACKAGE_COPYRIGHT),)
  PACKAGE_COPYRIGHT = GPL
endif
ifeq ($(RPM_GROUP),)
  RPM_GROUP = Development/Tools
endif
ifeq ($(PACKAGE_SUMMARY),)
  PACKAGE_SUMMARY = $(PACKAGE_NAME) package
endif
ifeq ($(PACKAGE_DESCRIPTION),)
  PACKAGE_DESCRIPTION = Fill in a description here\n
endif
ifeq ($(PACKAGER),)
  PACKAGER = Mr. GNUstep \<gnustep@gnustep.org\>
endif
ifeq ($(RPM_DIST),)
  RPM_DIST = GNUstep Project Presents
endif
ifeq ($(RPM_VENDOR),)
  RPM_VENDOR = The GNUstep Project
endif
ifeq ($(PACKAGE_URL),)
  PACKAGE_URL = http://www.gnustep.org/
endif

#
# Internal targets
#
SPECNAME=$(PACKAGE_NAME).spec
FLIST=./filelist.rpm.in
FDLIST=./filelist-devel.rpm.in

GID = $(GNUSTEP_INSTALLATION_DIR)

GDIR_APPS = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_APPS))
GDIR_TOOLS = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_TOOLS))
GDIR_SERVICES = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_SERVICES))
GDIR_WOAPPS = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_WOAPPS))
GDIR_HEADERS = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_HEADERS))
GDIR_BUNDLES = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_BUNDLES))
GDIR_FRAMEWORKS = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_FRAMEWORKS))
GDIR_FRAMEWORKS_HEADERS = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_FRAMEWORKS_HEADERS))
GDIR_FRAMEWORKS_LIBRARIES_ROOT = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_FRAMEWORKS_LIBRARIES_ROOT))
GDIR_PALETTES = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_PALETTES))
GDIR_LIBRARIES_ROOT = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_LIBRARIES_ROOT))
GDIR_RESOURCES = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_RESOURCES))
GDIR_JAVA = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_JAVA))
GDIR_DOCUMENTATION = $(subst $(GNUSTEP_INSTALLATION_DIR),,$(GNUSTEP_DOCUMENTATION))

# FIXME: This isn't right. Need to do this for each word in the variable
_RPM_DOC_INSTALL_DIR="$($(DOCUMENT_NAME)_DOC_INSTALL_DIR)"

specfile: $(SPECNAME)

filelist-in:
	if [ "$(dir $(FLIST))" = "./" ]; then \
	  rm -f $(FLIST) $(FDLIST); \
	  echo "%defattr (-, bin, bin)" > $(FLIST); \
	  echo "%defattr (-, bin, bin)" > $(FDLIST); \
	fi
	if [ "$(PACKAGE_DOCS)" != "" ]; then \
	  echo "%doc $(PACKAGE_DOCS)" >> $(FLIST); \
	fi
	if [ '$(RPM_DIRLIST)' != "" ]; then \
	  printf "$(RPM_DIRLIST)" >> $(FLIST); \
	fi
	if [ '$(RPM_DIRLIST_DEVEL)' != "" ]; then \
	  printf "$(RPM_DIRLIST_DEVEL)" >> $(FDLIST); \
	fi
	names="__dummy__"; \
	if [ "$(APP_NAME)" != "" ]; then names="$(APP_NAME)"; fi; \
	if [ "$$names" != "__dummy__" ]; then \
	  for file in $$names; do \
	    echo "%dir %{gsr}$(GDIR_APPS)/$$file.app" >> $(FLIST); \
	    echo "%{gsr}$(GDIR_APPS)/$$file.app/*" >> $(FLIST); \
	  done; \
	fi
	names="__dummy__"; \
	if [ "$(BUNDLE_NAME)" != "" ]; then names="$(BUNDLE_NAME)"; fi; \
	if [ "$$names" != "__dummy__" ]; then \
	  for file in $$names; do \
	    echo "%dir %{gsr}$(GDIR_BUNDLES)/$$file.bundle" >> $(FLIST); \
	    echo "%{gsr}$(GDIR_BUNDLES)/$$file.bundle/*" >> $(FLIST); \
	  done; \
	fi
	names="__dummy__"; \
	if [ "$(DOCUMENT_NAME)" != "" ]; then names="$(DOCUMENT_NAME)"; fi; \
	if [ "$$names" != "__dummy__" ]; then \
	  for file in $$names; do \
	    echo "%dir %{gsr}$(GDIR_DOCUMENTATION)/$(_RPM_DOC_INSTALL_DIR)" >> $(FLIST); \
	  done; \
	fi
	names="__dummy__"; \
	if [ "$(FRAMEWORK_NAME)" != "" ]; then names="$(FRAMEWORK_NAME)"; fi; \
	if [ "$$names" != "__dummy__" ]; then \
	  for file in $$names; do \
            $(MAKE) -f $(MAKEFILE_NAME) INTERNAL_framework_NAME=$$file framework-filelist-in; \
	  done; \
	fi 
	names="__dummy__"; \
	if [ "$(LIBRARY_NAME)" != "" ]; then names="$(LIBRARY_NAME)"; fi; \
	if [ "$$names" != "__dummy__" ]; then \
	  for file in $$names; do \
            $(MAKE) -f $(MAKEFILE_NAME) INTERNAL_library_NAME=$$file library-filelist-in; \
	  done; \
	fi 
	names="__dummy__"; \
	if [ "$(PALETTE_NAME)" != "" ]; then names="$(PALETTE_NAME)"; fi; \
	if [ "$$names" != "__dummy__" ]; then \
	  for file in $$names; do \
	    echo "%dir %{gsr}$(GDIR_PALETTES)/$$file.palette" >> $(FLIST); \
	    echo "%{gsr}$(GDIR_PALETTES)/$$file.palette/*" >> $(FLIST); \
	  done; \
	fi
	names="__dummy__"; \
	if [ "$(TOOL_NAME)" != "" ]; then names="$(TOOL_NAME)"; fi; \
	if [ "$$names" != "__dummy__" ]; then \
	  for file in $$names; do \
	    echo "%{gsr}$(GDIR_TOOLS)/$$file" >> $(FLIST); \
	    echo "%{gsr}$(GDIR_TOOLS)/GSARCH/GSOS/%{libcombo}/$$file" >> $(FLIST); \
	  done; \
	fi
	if [ "$(CTOOL_NAME)" != "" ]; then names="$(CTOOL_NAME)"; fi; \
	if [ "$$names" != "__dummy__" ]; then \
	  for file in $$names; do \
	    echo "%{gsr}$(GDIR_TOOLS)/$$file" >> $(FLIST); \
	    echo "%{gsr}$(GDIR_TOOLS)/GSARCH/GSOS/$$file" >> $(FLIST); \
	  done; \
	fi
	if [ "$(SUBPROJECTS)" != "" ]; then names="$(SUBPROJECTS)"; fi; \
	if [ "$$names" != "__dummy__" ]; then \
	  for dir in $$names; do \
            mf=$(MAKEFILE_NAME); \
            if [ ! -f $$dir/$$mf -a -f $$dir/Makefile ]; then \
              mf=Makefile; \
              echo "WARNING: No $(MAKEFILE_NAME) found for subproject $$f; using 'Makefile'"; \
            fi; \
            if $(MAKE) -C $$dir -f $$mf FLIST="../$(FLIST)" FDLIST="../$(FDLIST)" filelist-in; then \
              :; else exit $$?; \
            fi; \
	  done; \
	fi
	if [ '$(RPM_FILELIST)' != "" ]; then \
	  printf "$(RPM_FILELIST)" >> $(FLIST); \
	fi
	if [ '$(RPM_FILELIST_DEVEL)' != "" ]; then \
	  printf "$(RPM_FILELIST_DEVEL)" >> $(FDLIST); \
	fi

%.spec: filelist-in
	rm -f rpmspec.sed
	rm -f $@
	echo "s/@PACKAGE_NAME@/$(PACKAGE_NAME)/" > rpmspec.sed
	echo "s/@VERSION@/$(VERSION)/" >> rpmspec.sed
	echo "s/@DATE@/$(DATE)/" >> rpmspec.sed
	echo "s,@GID@,$(GID)," >> rpmspec.sed
	echo "s/@LIBRARY_COMBO@/$(LIBRARY_COMBO)/" >> rpmspec.sed
	echo "s/@RPM_RELEASE@/$(RPM_RELEASE)/" >> rpmspec.sed
	echo "s,@PACKAGE_SOURCE@,$(PACKAGE_SOURCE)," >> rpmspec.sed
	echo "s/@PACKAGE_COPYRIGHT@/$(PACKAGE_COPYRIGHT)/" >> rpmspec.sed
	echo "s,@RPM_GROUP@,$(RPM_GROUP)," >> rpmspec.sed
	echo "s/@PACKAGE_SUMMARY@/$(PACKAGE_SUMMARY)/" >> rpmspec.sed
	echo "s/@PACKAGER@/$(PACKAGER)/" >> rpmspec.sed
	echo "s/@RPM_DIST@/$(RPM_DIST)/" >> rpmspec.sed
	echo "s/@RPM_VENDOR@/$(RPM_VENDOR)/" >> rpmspec.sed
	echo "s,@PACKAGE_URL@,$(PACKAGE_URL)," >> rpmspec.sed
	echo "s/@RPM_CONFLICTS@/$(RPM_CONFLICTS)/" >> rpmspec.sed
	echo "s/@RPM_REQUIRES@/$(RPM_REQUIRES)/" >> rpmspec.sed
	if [ "$(RPM_CONFLICTS)" != "" ]; then \
	  echo "Conflicts:	$(RPM_CONFLICTS)" >> $@; \
	fi
	if [ "$(RPM_REQUIRES)" != "" ]; then \
	  echo "Requires:	$(RPM_REQUIRES)" >> $@; \
	fi
	sed -f rpmspec.sed < $(GNUSTEP_MAKEFILES)/template.spec.in > $@
	echo "" >> $@
	echo "" >> $@
	echo "%description" >> $@
	printf "$(PACKAGE_DESCRIPTION)" >> $@
	echo "Library combo is %{libcombo}." >> $@
	echo "%{_buildblurb}" >> $@
	if [ "`grep Headers filelist-devel.rpm.in`" != "" ]; then \
	  echo "" >> $@; \
	  echo "%package devel" >> $@; \
	  echo "Summary: $(PACKAGE_SUMMARY_DEVEL)" >> $@; \
	  echo "Group: Developement/Libraries" >> $@; \
	  echo "Requires: %{name} = %{ver} $(RPM_REQUIRES_DEVEL)" >> $@; \
	  if [ "$(RPM_CONFLICTS_DEVEL)" != "" ]; then \
	    echo "Conflicts: $(RPM_CONFLICTS_DEVEL)" >> $@; \
	  fi; \
	  echo "" >> $@; \
	  echo "%description devel" >> $@; \
	  printf "$(PACKAGE_DESCRIPTION_DEVEL)" >> $@; \
	  echo "Library combo is %{libcombo}." >> $@; \
	  echo "%{_buildblurb}" >> $@; \
	fi
	echo "" >> $@
	echo "%prep" >> $@
	echo "%setup -q $(RPM_SETUP)" >> $@
	echo "" >> $@
	echo "%build" >> $@
	echo 'if [ -z "$$GNUSTEP_SYSTEM_ROOT" ]; then' >> $@
	echo "   . %{gsr}/Makefiles/GNUstep.sh " >> $@
	echo "fi" >> $@
	echo 'CFLAGS="$$RPM_OPT_FLAGS" $(RPM_CONFIGURE)' >> $@
	echo "make" >> $@
	echo "" >> $@
	echo "%install" >> $@
	echo 'rm -rf $$RPM_BUILD_ROOT' >> $@
	echo 'if [ -z "$$GNUSTEP_SYSTEM_ROOT" ]; then' >> $@
	echo "   . %{gsr}/Makefiles/GNUstep.sh " >> $@
	echo "fi" >> $@
	echo 'make install GNUSTEP_INSTALLATION_DIR=$${RPM_BUILD_ROOT}%{gsr}' >> $@
	echo "$(RPM_ADDITIONAL_INSTALL)" >> $@
	echo "" >> $@
	echo "cat > filelist.rpm.in  << EOF" >> $@
	cat filelist.rpm.in >> $@
	echo "EOF" >> $@
	if [ "`grep Headers filelist-devel.rpm.in`" != "" ]; then \
	  echo "" >> $@; \
	  echo "cat > filelist-devel.rpm.in  << EOF" >> $@; \
	  cat filelist-devel.rpm.in >> $@; \
	  echo "EOF" >> $@; \
	fi 
	echo "" >> $@
	echo 'sed -e "s|GSARCH|$${GNUSTEP_HOST_CPU}|" -e "s|GSOS|$${GNUSTEP_HOST_OS}|" < filelist.rpm.in > filelist.rpm' >> $@
	if [ "`grep Headers filelist-devel.rpm.in`" != "" ]; then \
	  echo 'sed -e "s|GSARCH|$${GNUSTEP_HOST_CPU}|" -e "s|GSOS|$${GNUSTEP_HOST_OS}|" < filelist-devel.rpm.in > filelist-devel.rpm' >> $@; \
	fi
	echo "" >> $@
	if [ "$(RPM_POST)" != "" ]; then \
	  echo "%post" >> $@; \
	  echo "$(RPM_POST)" >> $@; \
	  echo "" >> $@; \
	fi
	if [ "$(RPM_PREUNINSTALL)" != "" ]; then \
	  echo "%preun" >> $@; \
	  echo "$(RPM_PREUNINSTALL)" >> $@; \
	  echo "" >> $@; \
	fi
	if [ "$(RPM_POSTUNINSTALL)" != "" ]; then \
	  echo "%postun" >> $@; \
	  echo "$(RPM_POSTUNINSTALL)" >> $@; \
	  echo "" >> $@; \
	fi
	echo "%clean" >> $@
	echo 'rm -rf $$RPM_BUILD_ROOT' >> $@
	echo "" >> $@
	echo "%files -f filelist.rpm" >> $@
	if [ "`grep Headers filelist-devel.rpm.in`" != "" ]; then \
	  echo "%files -f filelist-devel.rpm devel" >> $@; \
	fi
	echo "" >> $@
	echo "%changelog" >> $@
	echo "$(RPM_CHANGELOG)" >> $@
	rm -f $(FLIST) $(FDLIST) rpmspec.sed

#
# Just playing around with these for now
#
snapshot-dist:
	PWD=`pwd`; \
	SNAPSHOT_DIR=`basename $(PWD)`; \
	cd ..; \
	mv $$SNAPSHOT_DIR $(PACKAGE_NAME)-$(VERSION); \
	tar --gzip -cf $(PACKAGE_NAME)-$(VERSION).tar.gz $(PACKAGE_NAME)-$(VERSION); \
	mv $(PACKAGE_NAME)-$(VERSION) $$SNAPSHOT_DIR


#
# Targets that get invoked the second time around, when INTERNAL_obj_NAME
# has been defined and the appropriate variables have been defined in
# other .make files
#
library-filelist-in:
	echo "%{gsr}/Libraries/GSARCH/GSOS/%{libcombo}/$(LIBRARY_FILE).*" >> $(FLIST)
	if [ "$(LIBRARY_FILE)" != "$(VERSION_LIBRARY_FILE)" ]; then \
	  echo "%{gsr}/Libraries/GSARCH/GSOS/%{libcombo}/$(LIBRARY_FILE)" >> $(FDLIST); \
	fi
	RPM_HEAD_DIR="$($(INTERNAL_library_NAME)_HEADER_FILES_INSTALL_DIR)"; \
	echo "%{gsr}/Headers$(RPM_HEAD_DIR)" >> $(FDLIST)

framework-filelist-in:
	echo "%dir %{gsr}$(GDIR_FRAMEWORKS)/$(FRAMEWORK_DIR_NAME) >> $(FLIST)
	echo "%{gsr}/$(GDIR_FRAMEWORKS)/$(FRAMEWORK_DIR_NAME)/*" >> $(FLIST)
	echo "%{gsr}/$(GDIR_FRAMEWORKS_LIBRARIES_ROOT)" >> $(FLIST)
	echo "%{gsr}/$(GDIR_FRAMEWORKS_HEADERS)" >> $(FLIST)


endif
# rpm.make loaded

## Local variables:
## mode: makefile
## End:
