#   -*-makefile-*-
#   documentation.make
#
#   Makefile rules to build GNUstep-based documentation.
#
#   Copyright (C) 1998, 2000, 2001 Free Software Foundation, Inc.
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

# prevent multiple inclusions
ifeq ($(DOCUMENTATION_MAKE_LOADED),)
DOCUMENTATION_MAKE_LOADED=yes

#
# Include in the common makefile rules
#
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

DOCUMENT_NAME:=$(strip $(DOCUMENT_NAME))
DOCUMENT_TEXT_NAME:=$(strip $(DOCUMENT_TEXT_NAME))

ifeq ($(INTERNAL_doc_NAME)$(INTERNAL_textdoc_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(DOCUMENT_NAME:=.all.doc.variables) \
               $(DOCUMENT_TEXT_NAME:=.all.textdoc.variables)

internal-install:: $(DOCUMENT_NAME:=.install.doc.variables) \
                   $(DOCUMENT_TEXT_NAME:=.install.textdoc.variables)

internal-uninstall:: $(DOCUMENT_NAME:=.uninstall.doc.variables) \
                     $(DOCUMENT_TEXT_NAME:=.uninstall.textdoc.variables)

internal-clean:: $(DOCUMENT_NAME:=.clean.doc.variables) \
                 $(DOCUMENT_TEXT_NAME:=.clean.textdoc.variables)

internal-distclean:: $(DOCUMENT_NAME:=.distclean.doc.variables) \
                     $(DOCUMENT_TEXT_NAME:=.distclean.textdoc.variables)

#$(DOCUMENT_NAME):
#	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
#		$@.all.doc.variables

else
# This part gets included the second time make is invoked.

.PHONY: internal-doc-all \
        internal-textdoc-all \
        internal-doc-clean \
        internal-textdoc-clean \
        internal-doc-distclean \
        internal-textdoc-distclean \
        internal-doc-install \
        internal-textdoc-install \
        internal-doc-uninstall \
        internal-textdoc-uninstall \
        before-$(TARGET)-all \
        after-$(TARGET)-all \
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

internal-doc-all:: before-$(TARGET)-all \
                   $(INTERNAL_doc_NAME).info \
                   $(INTERNAL_doc_NAME).ps \
                   $(INTERNAL_doc_NAME)_toc.html \
                   after-$(TARGET)-all

internal-textdoc-all:: before-$(TARGET)-all \
                   $(INTERNAL_textdoc_NAME) \
                   after-$(TARGET)-all

$(INTERNAL_doc_NAME).info: $(TEXI_FILES)
	$(GNUSTEP_MAKEINFO) $(GNUSTEP_MAKEINFO_FLAGS) \
		-o $@ $(INTERNAL_doc_NAME).texi

$(INTERNAL_doc_NAME).dvi: $(TEXI_FILES)
	$(GNUSTEP_TEXI2DVI) $(GNUSTEP_TEXI2DVI_FLAGS) $(INTERNAL_doc_NAME).texi

$(INTERNAL_doc_NAME).ps: $(INTERNAL_doc_NAME).dvi
	$(GNUSTEP_DVIPS) $(GNUSTEP_DVIPS_FLAGS) \
		$(INTERNAL_doc_NAME).dvi -o $@

# Some systems don't have GNUSTEP_TEXI2HTML.  Simply don't build the
# HTML in these cases - but without aborting compilation.  Below, we
# don't install the result if it doesn't exist.

$(INTERNAL_doc_NAME)_toc.html: $(TEXI_FILES)
	-$(GNUSTEP_TEXI2HTML) $(GNUSTEP_TEXI2HTML_FLAGS) \
		$(INTERNAL_doc_NAME).texi

$(INTERNAL_textdoc_NAME): $(TEXI_FILES) $(TEXT_MAIN)
	$(GNUSTEP_MAKETEXT) $(GNUSTEP_MAKETEXT_FLAGS) \
		-o $@ $(TEXT_MAIN)

endif # TEXI_FILES

before-$(TARGET)-all::

after-$(TARGET)-all::


#
# Compilation of gsdoc files
#
ifneq ($(GSDOC_FILES),)

# The only thing we know is that each %.gsdoc file should generate a
# %.html file.  If any of the %.gsdoc files is newer than a corresponding
# %.html file, we rebuild them all.
GSDOC_OBJECT_FILES = $(patsubst %.gsdoc,%.html,$(GSDOC_FILES))

internal-doc-all:: before-$(TARGET)-all \
                   $(GSDOC_OBJECT_FILES) \
                   after-$(TARGET)-all

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
INTERNAL_AGSDOCFLAGS += -Project $(INTERNAL_doc_NAME)
INTERNAL_AGSDOCFLAGS += -DocumentationDirectory $(INTERNAL_doc_NAME)

INTERNAL_AGSLINKFLAGS = $(AGSLINK_FLAGS)
INTERNAL_AGSLINKFLAGS += -Project $(INTERNAL_doc_NAME)
INTERNAL_AGSLINKFLAGS += -DocumentationDirectory $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME)

AGSDOC_OBJS = $(patsubst %.gsdoc,%.html,\
               $(patsubst %.h,%.html,\
                $(patsubst %.m,%.html,$(AGSDOC_FILES))))
AGSDOC_HTML_FILES = $(addprefix $(INTERNAL_doc_NAME)/,$(AGSDOC_OBJS))
AGSDOC_GSDOC_FILES = $(patsubst %.html,%.gsdoc,$(AGSDOC_HTML_FILES))

.PRECIOUS: $(INTERNAL_doc_NAME)/%.gsdoc

$(INTERNAL_doc_NAME):
	$(MKDIRS) $@

$(INTERNAL_doc_NAME)/%.gsdoc: %.gsdoc
	cp $< $@

$(INTERNAL_doc_NAME)/%.gsdoc: %.h
	autogsdoc $(INTERNAL_AGSDOCFLAGS) -GenerateHtml NO $<

$(INTERNAL_doc_NAME)/%.gsdoc: $($(INTERNAL_doc_NAME)_HEADER_FILES_DIR)/%.h
	autogsdoc $(INTERNAL_AGSDOCFLAGS) -GenerateHtml NO $<

$(INTERNAL_doc_NAME)/%.gsdoc: %.m
	autogsdoc $(INTERNAL_AGSDOCFLAGS) -GenerateHtml NO $<

$(INTERNAL_doc_NAME)/%.html: $(INTERNAL_doc_NAME)/%.gsdoc $(INTERNAL_doc_NAME)/$(INTERNAL_doc_NAME).igsdoc
	autogsdoc $(INTERNAL_AGSDOCFLAGS) -GenerateHtml YES $<

$(INTERNAL_doc_NAME)/$(INTERNAL_doc_NAME).igsdoc: $(AGSDOC_GSDOC_FILES)
	autogsdoc $(INTERNAL_AGSDOCFLAGS) -GenerateHtml NO $(AGSDOC_GSDOC_FILES)

internal-doc-all:: before-$(TARGET)-all \
                     $(AGSDOC_HTML_FILES) \
                     after-$(TARGET)-all

before-$(TARGET)-all:: $(INTERNAL_doc_NAME)

else

#
# Stable/working rules
#

INTERNAL_AGSDOCFLAGS = $(AGSDOC_FLAGS)
INTERNAL_AGSDOCFLAGS += -Project $(INTERNAL_doc_NAME)
INTERNAL_AGSDOCFLAGS += -DocumentationDirectory $(INTERNAL_doc_NAME)

# The autogsdoc program has built-in dependency handling, so we can
# simply run it and it will work out what needs to be rebuilt.
internal-doc-all:: before-$(TARGET)-all \
                   generate-autogsdoc \
                   after-$(TARGET)-all

$(INTERNAL_doc_NAME):
	$(MKDIRS) $@

generate-autogsdoc: $(INTERNAL_doc_NAME)
	autogsdoc $(INTERNAL_AGSDOCFLAGS) $(AGSDOC_FILES)

endif # AGSDOC_EXPERIMENTAL

else

internal-doc-all::
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
$(INTERNAL_doc_NAME).dvi: $(LATEX_FILES)
	latex $(INTERNAL_doc_NAME).tex
	latex $(INTERNAL_doc_NAME).tex

$(INTERNAL_doc_NAME).ps: $(INTERNAL_doc_NAME).dvi
	$(GNUSTEP_DVIPS) $(GNUSTEP_DVIPS_FLAGS) \
		$(INTERNAL_doc_NAME).dvi -o $@

$(INTERNAL_doc_NAME).ps.gz: $(INTERNAL_doc_NAME).ps 
	gzip $(INTERNAL_doc_NAME).ps -c > $(INTERNAL_doc_NAME).ps.gz

internal-doc-all:: before-$(TARGET)-all \
                   $(INTERNAL_doc_NAME).ps.gz

#
# Targets built only if we can find `latex2html'
#
# NB: you may set LATEX2HTML on the command line if the following doesn't work
LATEX2HTML = $(shell which latex2html | awk '{print $$1}' |  sed -e 's/which://')

ifneq ($(LATEX2HTML),)
  HAS_LATEX2HTML = yes
endif

ifeq ($(HAS_LATEX2HTML),yes)
internal-doc-all:: $(INTERNAL_doc_NAME).tar.gz 

$(INTERNAL_doc_NAME)/$(INTERNAL_doc_NAME).html: $(INTERNAL_doc_NAME).dvi 
	$(LATEX2HTML) $(INTERNAL_doc_NAME)

$(INTERNAL_doc_NAME).tar.gz: $(INTERNAL_doc_NAME)/$(INTERNAL_doc_NAME).html
	$(TAR) cfz $(INTERNAL_doc_NAME).tar.gz $(INTERNAL_doc_NAME)

endif # LATEX2HTML

internal-doc-all:: after-$(TARGET)-all

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

internal-doc-all:: before-$(TARGET)-all \
                   $(INTERNAL_doc_NAME)/index.html \
                   after-$(TARGET)-all
$(INTERNAL_doc_NAME)/index.html:
	$(MKDIRS) $(INTERNAL_doc_NAME); \
	$(JAVADOC) $(ALL_JAVADOCFLAGS) $(JAVADOC_FILES) -d $(INTERNAL_doc_NAME)

else # Build always

internal-doc-all:: before-$(TARGET)-all \
                   generate-javadoc \
                   after-$(TARGET)-all
generate-javadoc:
	$(MKDIRS) $(INTERNAL_doc_NAME); \
	$(JAVADOC) $(ALL_JAVADOCFLAGS) $(JAVADOC_FILES) -d $(INTERNAL_doc_NAME)

endif


endif # JAVADOC_FILES

#
# Install and uninstall targets
#

#
# Installation directory - always created
#
internal-doc-install:: $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)

$(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR):
	$(MKINSTALLDIRS) $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)

# xxx_INSTALL_FILES
ifneq ($($(INTERNAL_doc_NAME)_INSTALL_FILES)$($(INTERNAL_textdoc_NAME)_INSTALL_FILES),)
internal-doc-install::
	for file in $($(INTERNAL_doc_NAME)_INSTALL_FILES) \
	            $($(INTERNAL_textdoc_NAME)_INSTALL_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $$file \
	               $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$$file ; \
	  fi; \
	done

internal-doc-uninstall::
	for file in $($(INTERNAL_doc_NAME)_INSTALL_FILES) \
	            $($(INTERNAL_textdoc_NAME)_INSTALL_FILES) __done; do \
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
internal-doc-install::
	$(INSTALL_DATA) $(INTERNAL_doc_NAME).ps \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
	$(INSTALL_DATA) $(INTERNAL_doc_NAME).info \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
	if [ -f $(INTERNAL_doc_NAME)_toc.html ]; then \
	  $(INSTALL_DATA) $(INTERNAL_doc_NAME)_*.html \
	                  $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR); \
	fi

internal-doc-uninstall::
	rm -f \
          $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME).ps
	rm -f \
          $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME).info
	rm -f \
          $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME)_*.html
endif # TEXI_FILES

#
# gsdoc installation
#
ifneq ($(GSDOC_FILES),)

internal-doc-install::
	$(INSTALL_DATA) $(GSDOC_OBJECT_FILES) \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
internal-doc-uninstall:: 
	rm -f \
	  $(addprefix $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/,\
	              $(GSDOC_OBJECT_FILES))
endif # GSDOC_FILES

#
# autogsdoc installation
#
ifneq ($(AGSDOC_FILES),)

internal-doc-install:: 
	rm -rf $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME)
	$(TAR) cf - $(INTERNAL_doc_NAME) | \
	  (cd $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR); $(TAR) xf -)
ifeq ($(GNUSTEP_BASE_HAVE_LIBXML),1)
	autogsdoc $(INTERNAL_AGSLINKFLAGS) $(notdir $(AGSDOC_HTML_FILES))
endif
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) \
	      $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME)
endif

internal-doc-uninstall:: 
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME)

endif # AUTOGSDOC_FILES

#
# LaTeX installation
#
ifneq ($(LATEX_FILES),)
internal-doc-install:: 
	$(INSTALL_DATA) $(INTERNAL_doc_NAME).ps \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
internal-doc-uninstall:: 
	rm -f \
	  $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME).ps

ifeq ($(HAS_LATEX2HTML),yes)
internal-doc-install:: 
	$(INSTALL_DATA) $(INTERNAL_doc_NAME)/*.html \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
	$(INSTALL_DATA) $(INTERNAL_doc_NAME)/*.css \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
# Yeah - I know - the following is dangerous if you have misused the 
# DOC_INSTALL_DIR - but it's the only way to do it
internal-doc-uninstall:: 
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/*.html
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/*.css
endif # LATEX2HTML
endif # LATEX_FILES

#
# Javadoc installation
#
ifneq ($(JAVADOC_FILES),)

internal-doc-install:: 
	rm -rf $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME)
	$(TAR) cf - $(INTERNAL_doc_NAME) |  \
	  (cd $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR); $(TAR) xf -)
ifneq ($(CHOWN_TO),)
	$(CHOWN) -R $(CHOWN_TO) \
	      $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME)
endif

internal-doc-uninstall:: 
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME)

endif # JAVADOC_FILES

#
# text file installation
#
internal-textdoc-install:: $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
	$(INSTALL_DATA) $(INTERNAL_textdoc_NAME) \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)

internal-textdoc-uninstall::
	rm -f \
          $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_textdoc_NAME)

#
# Cleaning targets
#
internal-doc-clean::
	@ -rm -f $(INTERNAL_doc_NAME).aux  \
	         $(INTERNAL_doc_NAME).cp   \
	         $(INTERNAL_doc_NAME).cps  \
	         $(INTERNAL_doc_NAME).dvi  \
	         $(INTERNAL_doc_NAME).fn   \
	         $(INTERNAL_doc_NAME).info \
	         $(INTERNAL_doc_NAME).ky   \
	         $(INTERNAL_doc_NAME).log  \
	         $(INTERNAL_doc_NAME).pg   \
	         $(INTERNAL_doc_NAME).ps   \
	         $(INTERNAL_doc_NAME).toc  \
	         $(INTERNAL_doc_NAME).tp   \
	         $(INTERNAL_doc_NAME).vr   \
	         $(INTERNAL_doc_NAME).vrs  \
	         $(INTERNAL_doc_NAME)_*.html \
	         $(INTERNAL_doc_NAME).ps.gz  \
	         $(INTERNAL_doc_NAME).tar.gz \
	         $(INTERNAL_doc_NAME)/*
ifneq ($(GSDOC_FILES),)
	@ -rm -f $(GSDOC_OBJECT_FILES)
endif
ifneq ($(AGSDOC_FILES),)
	@ -rm -Rf $(INTERNAL_doc_NAME)
endif
ifneq ($(LATEX_FILES),)
	@ rm -f *.aux
endif
ifneq ($(JAVADOC_FILES),)
	@ -rm -Rf $(INTERNAL_doc_NAME)
endif

internal-textdoc-clean::
	@ rm -f $(INTERNAL_textdoc_NAME)

ifneq ($(LATEX_FILES),)
ifeq ($(HAS_LATEX2HTML),yes)
internal-doc-distclean::
	@ if [ -d "$(INTERNAL_doc_NAME)" ]; then \
	    rm -rf $(INTERNAL_doc_NAME)/; \
	  fi
endif
endif

ifneq ($(JAVADOC_FILES),)
internal-doc-distclean::
	@ rm -rf $(INTERNAL_doc_NAME)
endif 

internal-textdoc-distclean::

endif

endif
# documentation.make loaded
