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
include $(GNUSTEP_MAKEFILES)/rules.make

#
# The names of the documents are in the DOCUMENT_NAME variable.
# These final documents will be generated in info, dvi, ps, and html output.
#
# The names of text documents are in the DOCUMENT_TEXT_NAME variable.
#
# The main file for text document is in the xxx_TEXT_MAIN variable.
# The Texinfo files that needs pre-processing are in xxx_TEXI_FILES
# The GSDoc files that needs pre-processing are in xxx_GSDOC_FILES
# The LaTeX files that needs pre-processing are in xxx_LATEX_FILES
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
LATEX2HTML = $(shell which latex2html)

ifneq ($(LATEX2HTML),)
internal-doc-all:: $(INTERNAL_doc_NAME).tar.gz 

$(INTERNAL_doc_NAME)/$(INTERNAL_doc_NAME).html: $(INTERNAL_doc_NAME).dvi 
	$(LATEX2HTML) $(INTERNAL_doc_NAME)

$(INTERNAL_doc_NAME).tar.gz: $(INTERNAL_doc_NAME)/$(INTERNAL_doc_NAME).html
	$(TAR) cf $(INTERNAL_doc_NAME).tar.gz $(INTERNAL_doc_NAME)

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
internal-doc-install:: internal-install-dirs

internal-install-dirs:: $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)

$(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR):
	$(MKDIRS) $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)

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
# LaTeX installation
#
ifneq ($(LATEX_FILES),)
internal-doc-install:: 
	$(INSTALL_DATA) $(INTERNAL_doc_NAME).ps \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
internal-doc-uninstall:: 
	rm -f \
	  $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME).ps

ifneq ($(LATEX2HTML),)
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

internal-doc-uninstall:: 
	-rm -f $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_doc_NAME)

endif # JAVADOC_FILES

#
# text file installation
#
internal-textdoc-install:: internal-install-dirs
	$(INSTALL_DATA) $(INTERNAL_textdoc_NAME) \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)

internal-textdoc-uninstall::
	rm -f \
          $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)/$(INTERNAL_textdoc_NAME)

#
# Cleaning targets
#
internal-doc-clean::
	rm -f $(INTERNAL_doc_NAME).aux
	rm -f $(INTERNAL_doc_NAME).cp
	rm -f $(INTERNAL_doc_NAME).cps
	rm -f $(INTERNAL_doc_NAME).dvi
	rm -f $(INTERNAL_doc_NAME).fn
	rm -f $(INTERNAL_doc_NAME).info
	rm -f $(INTERNAL_doc_NAME).ky
	rm -f $(INTERNAL_doc_NAME).log
	rm -f $(INTERNAL_doc_NAME).pg
	rm -f $(INTERNAL_doc_NAME).ps
	rm -f $(INTERNAL_doc_NAME).toc
	rm -f $(INTERNAL_doc_NAME).tp
	rm -f $(INTERNAL_doc_NAME).vr
	rm -f $(INTERNAL_doc_NAME).vrs
	rm -f $(INTERNAL_doc_NAME)_*.html
	rm -f $(INTERNAL_doc_NAME).ps.gz
	rm -f $(INTERNAL_doc_NAME).tar.gz
	-rm -f $(INTERNAL_doc_NAME)/*
ifneq ($(GSDOC_FILES),)
	for i in $(GSDOC_FILES); do \
	  rm -f $(GSDOC_OBJECT_FILES) ; \
	done
endif
ifneq ($(LATEX_FILES),)
	for i in $(LATEX_FILES); do \
	  rm -f `basename $$i .tex`.aux ; \
	done
endif

internal-textdoc-clean::
	rm -f $(INTERNAL_textdoc_NAME)

ifneq ($(JAVADOC_FILES),)

internal-doc-distclean::
	rm -Rf $(INTERNAL_doc_NAME)

endif # JAVADOC_FILES

ifneq ($(LATEX_FILES),)

internal-doc-distclean::
	rm -Rf *~ 
	rm -Rf *.aux
else # ! LATEX_FILES
internal-doc-distclean::
	rm -Rf *~ 
endif # LATEX_FILES

internal-textdoc-distclean::

#
# Testing targets
#
internal-doc-check::

internal-textdoc-check::

endif

endif
# documentation.make loaded
