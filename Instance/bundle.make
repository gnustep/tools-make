#
#   Instace/bundle.make
#
#   Instance makefile rules to build GNUstep-based bundles.
#
#   Copyright (C) 1997, 2001 Free Software Foundation, Inc.
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

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

include $(GNUSTEP_MAKEFILES)/Instance/Shared/headers.make

# The name of the bundle is in the BUNDLE_NAME variable.
# The list of bundle resource file are in xxx_RESOURCE_FILES
# The list of localized bundle resource files is in 
#                               xxx_LOCALIZED_RESOURCE_FILES
# The list of languages the bundle supports is in xxx_LANGUAGES
# The list of bundle resource directories are in xxx_RESOURCE_DIRS
# The name of the principal class is xxx_PRINCIPAL_CLASS
# The header files are in xxx_HEADER_FILES
# The directory where the header files are located is xxx_HEADER_FILES_DIR
# The directory where to install the header files inside the library
# installation directory is xxx_HEADER_FILES_INSTALL_DIR
# where xxx is the bundle name
#

.PHONY: internal-bundle-all_ \
        internal-bundle-install_ \
        internal-bundle-uninstall_ \
        build-bundle-dir \
        build-bundle \
        build-macosx-bundle \
        bundle-resource-files \
        bundle-localized-resource-files 


# On Solaris we don't need to specifies the libraries the bundle needs.
# How about the rest of the systems? BUNDLE_LIBS is temporary empty.
# We need this for MS Windows, so use it again!
BUNDLE_LIBS = $(ADDITIONAL_GUI_LIBS) $(AUXILIARY_GUI_LIBS) $(BACKEND_LIBS) \
   $(GUI_LIBS) $(ADDITIONAL_TOOL_LIBS) $(AUXILIARY_TOOL_LIBS) \
   $(FND_LIBS) $(ADDITIONAL_OBJC_LIBS) $(AUXILIARY_OBJC_LIBS) $(OBJC_LIBS) \
   $(SYSTEM_LIBS) $(TARGET_SYSTEM_LIBS)

ALL_BUNDLE_LIBS =						\
    $(shell $(WHICH_LIB_SCRIPT)					\
	$(ALL_LIB_DIRS)						\
	$(BUNDLE_LIBS)						\
	debug=$(debug) profile=$(profile) shared=$(shared)	\
	libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

ifeq ($(WITH_DLL),yes)
TTMP_LIBS := $(ALL_BUNDLE_LIBS)
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
BUNDLE_OBJ_EXT = $(DLL_LIBEXT)
endif # WITH_DLL

internal-bundle-all_:: $(GNUSTEP_OBJ_DIR) \
                       build-bundle \
                       build-macosx-bundle

BUNDLE_DIR_NAME = $(GNUSTEP_INSTANCE:=$(BUNDLE_EXTENSION))

GNUSTEP_SHARED_INSTANCE_BUNDLE_RESOURCE_PATH = $(BUNDLE_DIR_NAME)/Resources
include $(GNUSTEP_MAKEFILES)/Instance/Shared/bundle.make

BUNDLE_FILE = \
$(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR)/$(GNUSTEP_INSTANCE)$(BUNDLE_OBJ_EXT)

ifeq ($(BUNDLE_INSTALL_DIR),)
  BUNDLE_INSTALL_DIR = $(GNUSTEP_BUNDLES)
endif

build-bundle:: $(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR) \
               $(BUNDLE_FILE) \
               $(BUNDLE_DIR_NAME)/Resources \
               $(BUNDLE_DIR_NAME)/Resources/Info.plist \
               $(BUNDLE_DIR_NAME)/Resources/Info-gnustep.plist \
               shared-instance-bundle-all

# The rule to build $(BUNDLE_DIR_NAME)/Resources is already provided
# by Instance/Shared/bundle.make

$(BUNDLE_DIR_NAME)/$(GNUSTEP_TARGET_LDIR):
	$(MKDIRS) $@

ifeq ($(WITH_DLL),yes)

$(BUNDLE_FILE) : $(OBJ_FILES_TO_LINK)
	$(DLLWRAP) --driver-name $(CC) \
		-o $(LDOUT)$(BUNDLE_FILE) \
		$(OBJ_FILES_TO_LINK) \
		$(ALL_BUNDLE_LIBS)

else # WITH_DLL

$(BUNDLE_FILE) : $(OBJ_FILES_TO_LINK)
	$(BUNDLE_LD) $(BUNDLE_LDFLAGS) $(ALL_LDFLAGS) \
		-o $(LDOUT)$(BUNDLE_FILE) \
		$(OBJ_FILES_TO_LINK) \
		$(ALL_BUNDLE_LIBS)

endif # WITH_DLL

PRINCIPAL_CLASS = $(strip $($(GNUSTEP_INSTANCE)_PRINCIPAL_CLASS))

ifeq ($(PRINCIPAL_CLASS),)
  PRINCIPAL_CLASS = $(GNUSTEP_INSTANCE)
endif

# MacOSX bundles

$(BUNDLE_DIR_NAME)/Contents :
	$(MKDIRS) $@

$(BUNDLE_DIR_NAME)/Contents/Resources : $(BUNDLE_DIR_NAME)/Contents \
                                        $(BUNDLE_DIR_NAME)/Resources
	@(cd $(BUNDLE_DIR_NAME)/Contents; rm -f Resources; \
	  $(LN_S) ../Resources .)

$(BUNDLE_DIR_NAME)/Contents/Info.plist: $(BUNDLE_DIR_NAME)/Contents
	@(echo "<?xml version='1.0' encoding='utf-8'?>";\
	  echo "<!DOCTYPE plist SYSTEM 'file://localhost/System/Library/DTDs/PropertyList.dtd'>";\
	  echo "<!-- Automatically generated, do not edit! -->";\
	  echo "<plist version='0.9'>";\
	  echo "  <dict>";\
	  echo "    <key>CFBundleExecutable</key>";\
	  echo "    <string>$(GNUSTEP_TARGET_LDIR)/$(GNUSTEP_INSTANCE)${BUNDLE_OBJ_EXT}</string>";\
	  echo "    <key>CFBundleInfoDictionaryVersion</key>";\
	  echo "    <string>6.0</string>";\
	  echo "    <key>CFBundlePackageType</key>";\
	  echo "    <string>BNDL</string>";\
	  echo "    <key>NSPrincipalClass</key>";\
	  echo "    <string>$(PRINCIPAL_CLASS)</string>";\
	  echo "  </dict>";\
	  echo "</plist>";\
	) >$@

build-macosx-bundle :: $(BUNDLE_DIR_NAME)/Contents \
                       $(BUNDLE_DIR_NAME)/Contents/Resources \
                       $(BUNDLE_DIR_NAME)/Contents/Info.plist

MAIN_MODEL_FILE = $(strip $(subst .gmodel,,$(subst .gorm,,$(subst .nib,,$($(GNUSTEP_INSTANCE)_MAIN_MODEL_FILE)))))

# NeXTstep bundles
$(BUNDLE_DIR_NAME)/Resources/Info.plist:
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_TARGET_LDIR)/$(GNUSTEP_INSTANCE)${BUNDLE_OBJ_EXT}\";"; \
	  echo "  NSMainNibFile = \"$(MAIN_MODEL_FILE)\";"; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "}") >$@

# GNUstep bundles
$(BUNDLE_DIR_NAME)/Resources/Info-gnustep.plist:
	@(echo "{"; echo '  NOTE = "Automatically generated, do not edit!";'; \
	  echo "  NSExecutable = \"$(GNUSTEP_INSTANCE)${BUNDLE_OBJ_EXT}\";"; \
	  echo "  NSMainNibFile = \"$(MAIN_MODEL_FILE)\";"; \
	  echo "  NSPrincipalClass = \"$(PRINCIPAL_CLASS)\";"; \
	  echo "}") >$@
	@if [ -r "$(GNUSTEP_INSTANCE)Info.plist" ]; then \
	  plmerge $@ $(GNUSTEP_INSTANCE)Info.plist; \
	fi

# Comment on the tar options used in the rule below - 

# The h option to tar makes sure the bundle can contain symbolic links
# to external files (for example templates), and when you install the
# bundle, the symbolic links are replaced with the actual files.  The
# X option is used because otherwise the -h option would dereference
# the Contents/Resources-->Resources symbolic link, and install the
# Resources directory twice.  Instead, we exclude the symbolic link
# from the tar file, then rebuild the link by hand in the installation
# directory.

# Because of compatibility issues with older versions of GNU tar (not
# to speak of non-GNU tars), we use the X option rather than the
# --exclude= option.  The X option requires as argument a file listing
# files to exclude.  We create a temporary file for this, then remove
# it immediately afterwards.

# When rebuilding the link, just as yet another compatibility safety
# measure, we need to make sure that we can manage the case that tar
# was actually broken and didn't honour the X option (and/or the h
# option).  To manage this, we simply do not build the link if
# Resources already exists and is a directory (either a real one or a
# symbolic link, we don't care).

internal-bundle-install_:: $(BUNDLE_INSTALL_DIR) shared-instance-headers-install
	rm -f .tmp.gnustep.exclude; \
	echo "$(BUNDLE_DIR_NAME)/Contents/Resources" > .tmp.gnustep.exclude;\
	rm -rf $(BUNDLE_INSTALL_DIR)/$(BUNDLE_DIR_NAME); \
	$(TAR) chfX - .tmp.gnustep.exclude $(BUNDLE_DIR_NAME) \
	    | (cd $(BUNDLE_INSTALL_DIR); $(TAR) xf -); \
	rm -f .tmp.gnustep.exclude; \
	(cd $(BUNDLE_INSTALL_DIR)/$(BUNDLE_DIR_NAME)/Contents; \
	    if [ ! -d Resources ]; then \
	      rm -f Resources; $(LN_S) ../Resources .; \
	    fi;)
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) $(BUNDLE_INSTALL_DIR)/$(BUNDLE_DIR_NAME)
endif
ifeq ($(strip),yes)
	$(STRIP) $(BUNDLE_INSTALL_DIR)/$(BUNDLE_FILE)
endif

$(BUNDLE_INSTALL_DIR):
	$(MKINSTALLDIRS) $@

internal-bundle-uninstall_:: shared-instance-headers-uninstall
	rm -rf $(BUNDLE_INSTALL_DIR)/$(BUNDLE_DIR_NAME)


## Local variables:
## mode: makefile
## End:
