#   -*-makefile-*-
#   Instance/documentation.make
#
#   Instance Makefile rules to build GNUstep-based documentation.
#
#   Copyright (C) 1998, 2000, 2001, 2002 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#  
#   Author:  Nicola Pero <n.pero@mi.flashnet.it> 
#   Date: 2000, 2001
#   Changes: Support for installing documentation, for LaTeX projects,
#            for Javadoc, lots of other changes and fixes
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
# The names of the documents are in the DOCUMENT_NAME variable.
# These final documents will be generated in info, dvi, ps, and html output.
#
# The names of text documents are in the DOCUMENT_TEXT_NAME variable.
#
# The main file for text document is in the xxx_TEXT_MAIN variable.
# Files already ready to be installed without pre-processing (eg, html, rtf)
#                                         are in the xxx_INSTALL_FILES
# The Texinfo files that needs pre-processing are in xxx_TEXI_FILES
# The GSDoc files that needs pre-processing are in xxx_GSDOC_FILES
# The files for processing by autogsdoc are in xxx_AGSDOC_FILES
# The options for controlling autogsdoc are in xxx_AGSDOC_FLAGS
#
# Javadoc support: 
# The Java classes and packages that needs documenting using javadoc
# are in xxx_JAVADOC_FILES (could contain both packages, as
# `gnu.gnustep.base', and standalone classes, as
# `gnu.gnustep.base.NSArray.java')
#
# The sourcepath to the Java classes source code in in xxx_JAVADOC_SOURCEPATH 
#   (it can contain more than one path, as CLASSPATH or LD_LIBRARY_PATH do).
# To set special flags for javadoc (eg, -public), use ADDITIONAL_JAVADOCFLAGS
#
# The installation directory is in the xxx_DOC_INSTALL_DIR variable
# (eg, Gui_DOC_INSTALL_DIR = Developer/Gui/Reference
#  Things should be installed under `Developer/YourProjectName' or 
#  `User/YourProjectName' - for Javadoc, use `Developer/YourProjectName' or 
#   `Developer/YourProjectName/Java' if your project has both java and 
#   non java)
#
#	Where xxx is the name of the document
#

# TODO - clean all this file, breaking it into little manageable
# independent files

TEXI_FILES = $($(GNUSTEP_INSTANCE)_TEXI_FILES)
GSDOC_FILES = $($(GNUSTEP_INSTANCE)_GSDOC_FILES)
AGSDOC_FILES = $($(GNUSTEP_INSTANCE)_AGSDOC_FILES)
AGSDOC_FLAGS = $($(GNUSTEP_INSTANCE)_AGSDOC_FLAGS)
LATEX_FILES = $($(GNUSTEP_INSTANCE)_LATEX_FILES)
JAVADOC_FILES = $($(GNUSTEP_INSTANCE)_JAVADOC_FILES)
JAVADOC_SOURCEPATH = $($(GNUSTEP_INSTANCE)_JAVADOC_SOURCEPATH)
DOC_INSTALL_DIR = $($(GNUSTEP_INSTANCE)_DOC_INSTALL_DIR)
TEXT_MAIN = $($(GNUSTEP_INSTANCE)_TEXT_MAIN)


.PHONY: internal-doc-all_ \
        internal-textdoc-all_ \
        internal-doc-clean \
        internal-textdoc-clean \
        internal-doc-distclean \
        internal-textdoc-distclean \
        internal-doc-install_ \
        internal-textdoc-install_ \
        internal-doc-uninstall_ \
        internal-textdoc-uninstall_ \
        generate-javadoc

#
# Internal targets
#

#
# Compilation targets
#

#
# Compilation of texinfo files
#
ifneq ($(TEXI_FILES),)

internal-doc-all_:: $(GNUSTEP_INSTANCE).info \
                    $(GNUSTEP_INSTANCE).ps \
                    $(GNUSTEP_INSTANCE)_toc.html

internal-textdoc-all_:: $(GNUSTEP_INSTANCE)

$(GNUSTEP_INSTANCE).info: $(TEXI_FILES)
	$(GNUSTEP_MAKEINFO) $(GNUSTEP_MAKEINFO_FLAGS) \
		-o $@ $(GNUSTEP_INSTANCE).texi

$(GNUSTEP_INSTANCE).dvi: $(TEXI_FILES)
	$(GNUSTEP_TEXI2DVI) $(GNUSTEP_TEXI2DVI_FLAGS) $(GNUSTEP_INSTANCE).texi

$(GNUSTEP_INSTANCE).ps: $(GNUSTEP_INSTANCE).dvi
	$(GNUSTEP_DVIPS) $(GNUSTEP_DVIPS_FLAGS) \
		$(GNUSTEP_INSTANCE).dvi -o $@

# Some systems don't have GNUSTEP_TEXI2HTML.  Simply don't build the
# HTML in these cases - but without aborting compilation.  Below, we
# don't install the result if it doesn't exist.

$(GNUSTEP_INSTANCE)_toc.html: $(TEXI_FILES)
	-$(GNUSTEP_TEXI2HTML) $(GNUSTEP_TEXI2HTML_FLAGS) \
		$(GNUSTEP_INSTANCE).texi

$(GNUSTEP_INSTANCE): $(TEXI_FILES) $(TEXT_MAIN)
	$(GNUSTEP_MAKETEXT) $(GNUSTEP_MAKETEXT_FLAGS) \
		-o $@ $(TEXT_MAIN)

endif # TEXI_FILES


#
# Compilation of gsdoc files
#
ifneq ($(GSDOC_FILES),)

# The only thing we know is that each %.gsdoc file should generate a
# %.html file.  If any of the %.gsdoc files is newer than a corresponding
# %.html file, we rebuild them all.
GSDOC_OBJECT_FILES = $(patsubst %.gsdoc,%.html,$(GSDOC_FILES))

internal-doc-all_:: $(GSDOC_OBJECT_FILES)

$(GSDOC_OBJECT_FILES): $(GSDOC_FILES)
	gsdoc $(GSDOC_FILES)

endif # GSDOC_FILES

#
# Processing of agsdoc files
#
ifneq ($(AGSDOC_FILES),)

ifeq ($(GNUSTEP_BASE_HAVE_LIBXML), 1)

ifeq ($(AGSDOC_EXPERIMENTAL), 1)

INTERNAL_AGSDOCFLAGS = $(AGSDOC_FLAGS)
INTERNAL_AGSDOCFLAGS += -IgnoreDependencies YES
INTERNAL_AGSDOCFLAGS += -Project $(GNUSTEP_INSTANCE)
INTERNAL_AGSDOCFLAGS += -DocumentationDirectory $(GNUSTEP_INSTANCE)

INTERNAL_AGSLINKFLAGS = $(AGSLINK_FLAGS)
INTERNAL_AGSLINKFLAGS += -Project $(GNUSTEP_INSTANCE)
INTERNAL_AGSLINKFLAGS += -DocumentationDirectory $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)

AGSDOC_OBJS = $(patsubst %.gsdoc,%.html,\
               $(patsubst %.h,%.html,\
                $(patsubst %.m,%.html,$(AGSDOC_FILES))))
AGSDOC_HTML_FILES = $(addprefix $(GNUSTEP_INSTANCE)/,$(AGSDOC_OBJS))
AGSDOC_GSDOC_FILES = $(patsubst %.html,%.gsdoc,$(AGSDOC_HTML_FILES))

.PRECIOUS: $(GNUSTEP_INSTANCE)/%.gsdoc

$(GNUSTEP_INSTANCE):
	$(MKDIRS) $@

$(GNUSTEP_INSTANCE)/%.gsdoc: %.gsdoc
	cp $< $@

$(GNUSTEP_INSTANCE)/%.gsdoc: %.h
	autogsdoc $(INTERNAL_AGSDOCFLAGS) -GenerateHtml NO $<

$(GNUSTEP_INSTANCE)/%.gsdoc: $($(GNUSTEP_INSTANCE)_HEADER_FILES_DIR)/%.h
	autogsdoc $(INTERNAL_AGSDOCFLAGS) -GenerateHtml NO $<

$(GNUSTEP_INSTANCE)/%.gsdoc: %.m
	autogsdoc $(INTERNAL_AGSDOCFLAGS) -GenerateHtml NO $<

$(GNUSTEP_INSTANCE)/%.html: $(GNUSTEP_INSTANCE)/%.gsdoc $(GNUSTEP_INSTANCE)/$(GNUSTEP_INSTANCE).igsdoc
	autogsdoc $(INTERNAL_AGSDOCFLAGS) -GenerateHtml YES $<

$(GNUSTEP_INSTANCE)/$(GNUSTEP_INSTANCE).igsdoc: $(AGSDOC_GSDOC_FILES)
	autogsdoc $(INTERNAL_AGSDOCFLAGS) -GenerateHtml NO $(AGSDOC_GSDOC_FILES)

internal-doc-all_::  $(GNUSTEP_INSTANCE) \
                     $(AGSDOC_HTML_FILES)

else

#
# Stable/working rules
#

INTERNAL_AGSDOCFLAGS = $(AGSDOC_FLAGS)
INTERNAL_AGSDOCFLAGS += -Project $(GNUSTEP_INSTANCE)
INTERNAL_AGSDOCFLAGS += -DocumentationDirectory $(GNUSTEP_INSTANCE)

# The autogsdoc program has built-in dependency handling, so we can
# simply run it and it will work out what needs to be rebuilt.
internal-doc-all_:: generate-autogsdoc

$(GNUSTEP_INSTANCE):
	$(MKDIRS) $@

generate-autogsdoc: $(GNUSTEP_INSTANCE)
	autogsdoc $(INTERNAL_AGSDOCFLAGS) $(AGSDOC_FILES)

endif # AGSDOC_EXPERIMENTAL

else

internal-doc-all_::
	@echo "No libxml - processing of autogsdoc files skipped"

endif # GNUSTEP_BASE_HAVE_LIBXML

endif # AGSDOC_FILES

#
# Compilation of LaTeX files
#
ifneq ($(LATEX_FILES),)
#
# Targets which are always built
#
$(GNUSTEP_INSTANCE).dvi: $(LATEX_FILES)
	latex $(GNUSTEP_INSTANCE).tex
	latex $(GNUSTEP_INSTANCE).tex

$(GNUSTEP_INSTANCE).ps: $(GNUSTEP_INSTANCE).dvi
	$(GNUSTEP_DVIPS) $(GNUSTEP_DVIPS_FLAGS) \
		$(GNUSTEP_INSTANCE).dvi -o $@

$(GNUSTEP_INSTANCE).ps.gz: $(GNUSTEP_INSTANCE).ps 
	gzip $(GNUSTEP_INSTANCE).ps -c > $(GNUSTEP_INSTANCE).ps.gz

internal-doc-all_:: $(GNUSTEP_INSTANCE).ps.gz

#
# Targets built only if we can find `latex2html'
#
# NB: you may set LATEX2HTML on the command line if the following doesn't work
LATEX2HTML = $(shell which latex2html | awk '{print $$1}' |  sed -e 's/which://')

ifneq ($(LATEX2HTML),)
  HAS_LATEX2HTML = yes
endif

ifeq ($(HAS_LATEX2HTML),yes)
internal-doc-all_:: $(GNUSTEP_INSTANCE).tar.gz 

$(GNUSTEP_INSTANCE)/$(GNUSTEP_INSTANCE).html: $(GNUSTEP_INSTANCE).dvi 
	$(LATEX2HTML) $(GNUSTEP_INSTANCE)

$(GNUSTEP_INSTANCE).tar.gz: $(GNUSTEP_INSTANCE)/$(GNUSTEP_INSTANCE).html
	$(TAR) cfz $(GNUSTEP_INSTANCE).tar.gz $(GNUSTEP_INSTANCE)

endif # LATEX2HTML

endif # LATEX_FILES

#
# Documentation generated with javadoc
#
ifneq ($(JAVADOC_FILES),)

ifeq ($(JAVADOC_SOURCEPATH),)
  INTERNAL_JAVADOCFLAGS = -sourcepath ./
else
  INTERNAL_JAVADOCFLAGS = -sourcepath ./:$(strip $(JAVADOC_SOURCEPATH))
endif

# incremental compilation with javadoc is not supported - you can only
# build once, or always.  by default we build only once - use
# `JAVADOC_BUILD_ALWAYS = YES' to force rebuilding it always

ifneq ($(JAVADOC_BUILD_ALWAYS),YES) # Build only once

internal-doc-all_:: $(GNUSTEP_INSTANCE)/index.html

$(GNUSTEP_INSTANCE)/index.html:
	$(MKDIRS) $(GNUSTEP_INSTANCE); \
	$(JAVADOC) $(ALL_JAVADOCFLAGS) $(JAVADOC_FILES) -d $(GNUSTEP_INSTANCE)

else # Build always

internal-doc-all_:: generate-javadoc

generate-javadoc:
	$(MKDIRS) $(GNUSTEP_INSTANCE); \
	$(JAVADOC) $(ALL_JAVADOCFLAGS) $(JAVADOC_FILES) -d $(GNUSTEP_INSTANCE)

endif


endif # JAVADOC_FILES

#
# Install and uninstall targets
#

#
# Installation directory - always created
#
internal-doc-install_:: $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)

$(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR):
	$(MKINSTALLDIRS) $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)

# xxx_INSTALL_FILES
ifneq ($($(GNUSTEP_INSTANCE)_INSTALL_FILES),)
internal-doc-install_::
	for file in $($(GNUSTEP_INSTANCE)_INSTALL_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $$file \
	               $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$$file ; \
	  fi; \
	done

internal-doc-uninstall_::
	for file in $($(GNUSTEP_INSTANCE)_INSTALL_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$$file ; \
	  fi; \
	done
endif

#
# texi installation
#
ifneq ($(TEXI_FILES),)

# NB: Only install HTML if it has been generated
internal-doc-install_::
	$(INSTALL_DATA) $(GNUSTEP_INSTANCE).ps \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
	$(INSTALL_DATA) $(GNUSTEP_INSTANCE).info \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
	if [ -f $(GNUSTEP_INSTANCE)_toc.html ]; then \
	  $(INSTALL_DATA) $(GNUSTEP_INSTANCE)_*.html \
	                  $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR); \
	fi

internal-doc-uninstall_::
	rm -f \
          $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE).ps
	rm -f \
          $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE).info
	rm -f \
          $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)_*.html
endif # TEXI_FILES

#
# gsdoc installation
#
ifneq ($(GSDOC_FILES),)

internal-doc-install_::
	$(INSTALL_DATA) $(GSDOC_OBJECT_FILES) \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
internal-doc-uninstall_:: 
	rm -f \
	  $(addprefix $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/,\
	              $(GSDOC_OBJECT_FILES))
endif # GSDOC_FILES

#
# autogsdoc installation
#
ifneq ($(AGSDOC_FILES),)

internal-doc-install_:: 
	rm -rf $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)
	$(TAR) cf - $(GNUSTEP_INSTANCE) | \
	  (cd $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR); $(TAR) xf -)
ifeq ($(GNUSTEP_BASE_HAVE_LIBXML),1)
	-autogsdoc $(INTERNAL_AGSLINKFLAGS) $(notdir $(AGSDOC_HTML_FILES))
endif
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) \
	      $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)
endif

internal-doc-uninstall_:: 
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)

endif # AUTOGSDOC_FILES

#
# LaTeX installation
#
ifneq ($(LATEX_FILES),)
internal-doc-install_:: 
	$(INSTALL_DATA) $(GNUSTEP_INSTANCE).ps \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
internal-doc-uninstall_:: 
	rm -f \
	  $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE).ps

ifeq ($(HAS_LATEX2HTML),yes)
internal-doc-install_:: 
	$(INSTALL_DATA) $(GNUSTEP_INSTANCE)/*.html \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
	$(INSTALL_DATA) $(GNUSTEP_INSTANCE)/*.css \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
# Yeah - I know - the following is dangerous if you have misused the 
# DOC_INSTALL_DIR - but it's the only way to do it
internal-doc-uninstall_:: 
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/*.html
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/*.css
endif # LATEX2HTML
endif # LATEX_FILES

#
# Javadoc installation
#
ifneq ($(JAVADOC_FILES),)

internal-doc-install_:: 
	rm -rf $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)
	$(TAR) cf - $(GNUSTEP_INSTANCE) |  \
	  (cd $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR); $(TAR) xf -)
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) \
	      $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)
endif

internal-doc-uninstall_:: 
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)

endif # JAVADOC_FILES

#
# text file installation
#
internal-textdoc-install_:: $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
	$(INSTALL_DATA) $(GNUSTEP_INSTANCE) \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)

internal-textdoc-uninstall_::
	rm -f \
          $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(GNUSTEP_INSTANCE)

#
# Cleaning targets
#
internal-doc-clean::
	@ -rm -f $(GNUSTEP_INSTANCE).aux  \
	         $(GNUSTEP_INSTANCE).cp   \
	         $(GNUSTEP_INSTANCE).cps  \
	         $(GNUSTEP_INSTANCE).dvi  \
	         $(GNUSTEP_INSTANCE).fn   \
	         $(GNUSTEP_INSTANCE).info \
	         $(GNUSTEP_INSTANCE).ky   \
	         $(GNUSTEP_INSTANCE).log  \
	         $(GNUSTEP_INSTANCE).pg   \
	         $(GNUSTEP_INSTANCE).ps   \
	         $(GNUSTEP_INSTANCE).toc  \
	         $(GNUSTEP_INSTANCE).tp   \
	         $(GNUSTEP_INSTANCE).vr   \
	         $(GNUSTEP_INSTANCE).vrs  \
	         $(GNUSTEP_INSTANCE)_*.html \
	         $(GNUSTEP_INSTANCE).ps.gz  \
	         $(GNUSTEP_INSTANCE).tar.gz \
	         $(GNUSTEP_INSTANCE)/*
ifneq ($(GSDOC_FILES),)
	@ -rm -f $(GSDOC_OBJECT_FILES)
endif
ifneq ($(AGSDOC_FILES),)
	@ -rm -Rf $(GNUSTEP_INSTANCE)
endif
ifneq ($(LATEX_FILES),)
	@ rm -f *.aux
endif
ifneq ($(JAVADOC_FILES),)
	@ -rm -Rf $(GNUSTEP_INSTANCE)
endif

internal-textdoc-clean::
	@ rm -f $(GNUSTEP_INSTANCE)

ifneq ($(LATEX_FILES),)
ifeq ($(HAS_LATEX2HTML),yes)
internal-doc-distclean::
	@ if [ -d "$(GNUSTEP_INSTANCE)" ]; then \
	    rm -rf $(GNUSTEP_INSTANCE)/; \
	  fi
endif
endif

ifneq ($(JAVADOC_FILES),)
internal-doc-distclean::
	@ rm -rf $(GNUSTEP_INSTANCE)
endif 

internal-textdoc-distclean::

