#
#   documentation.make
#
#   Makefile rules to build GNUstep-based texinfo documentation.
#
#   Copyright (C) 1998, 2000 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#  
#   Author:  Nicola Pero <n.pero@mi.flashnet.it> 
#   Date: November 2000 
#   Changes: Support for installing documentation, and for LaTeX projects
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
# The installation directory is in the xxx_DOC_INSTALL_DIR variable
# (eg, Gui_DOC_INSTALL_DIR = Developer/Gui/Reference
#  Things should be installed under `Developer/YourProjectName' or 
#  `User/YourProjectName')
#
#	Where xxx is the name of the document
#

DOCUMENT_NAME:=$(strip $(DOCUMENT_NAME))
DOCUMENT_TEXT_NAME:=$(strip $(DOCUMENT_TEXT_NAME))

ifeq ($(INTERNAL_doc_NAME)$(INTERNAL_textdoc_NAME),)
# This part is included the first time make is invoked.

internal-all:: $(DOCUMENT_NAME:=.all.doc.variables) \
               $(DOCUMENT_TEXT_NAME:=.all.textdoc.variables)

internal-install:: all $(DOCUMENT_NAME:=.install.doc.variables) \
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

internal-doc-all:: before-all before-$(TARGET)-all \
                   $(INTERNAL_doc_NAME).info \
                   $(INTERNAL_doc_NAME).ps \
                   $(INTERNAL_doc_NAME)_toc.html \
                   after-$(TARGET)-all after-all

internal-textdoc-all:: before-all before-$(TARGET)-all \
                   $(INTERNAL_textdoc_NAME) \
                   after-$(TARGET)-all after-all

$(INTERNAL_doc_NAME).info: $(TEXI_FILES)
	$(GNUSTEP_MAKEINFO) $(GNUSTEP_MAKEINFO_FLAGS) \
		-o $@ $(INTERNAL_doc_NAME).texi

$(INTERNAL_doc_NAME).dvi: $(TEXI_FILES)
	$(GNUSTEP_TEXI2DVI) $(GNUSTEP_TEXI2DVI_FLAGS) $(INTERNAL_doc_NAME).texi

$(INTERNAL_doc_NAME).ps: $(INTERNAL_doc_NAME).dvi
	$(GNUSTEP_DVIPS) $(GNUSTEP_DVIPS_FLAGS) \
		$(INTERNAL_doc_NAME).dvi -o $@

$(INTERNAL_doc_NAME)_toc.html: $(TEXI_FILES)
	$(GNUSTEP_TEXI2HTML) $(GNUSTEP_TEXI2HTML_FLAGS) \
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

internal-doc-all:: before-all before-$(TARGET)-all \
                   $(INTERNAL_doc_NAME).html \
                   after-$(TARGET)-all after-all

$(INTERNAL_doc_NAME).html: $(GSDOC_FILES)
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

internal-doc-all:: before-all before-$(TARGET)-all \
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

internal-doc-all:: after-$(TARGET)-all after-all

endif # LATEX_FILES

#
# Install and uninstall targets
#

#
# Installation directory - always created
#
internal-doc-install:: internal-install-dirs

internal-install-dirs::
	$(MKDIRS) $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)

#
# texi installation
#
ifneq ($(TEXI_FILES),)
internal-doc-install::
	$(INSTALL_DATA) $(INTERNAL_doc_NAME).ps \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
	$(INSTALL_DATA) $(INTERNAL_doc_NAME).info \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
	$(INSTALL_DATA) $(INTERNAL_doc_NAME)_*.html \
	                $(GNUSTEP_DOCUMENTATION)/$(DOC_INSTALL_DIR)
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

GSDOC_OBJECT_FILES = $(patsubst %.gsdoc,%.html,$(GSDOC_FILES))

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
		rm -f `basename $$i .gsdoc`.html ; \
	done
endif
ifneq ($(LATEX_FILES),)
	for i in $(LATEX_FILES); do \
		rm -f `basename $$i .tex`.aux ; \
	done
endif

internal-textdoc-clean::
	rm -f $(INTERNAL_textdoc_NAME)
ifneq ($(GSDOC_FILES),)
	for i in $(GSDOC_FILES); do \
		rm -f `basename $$i .gsdoc`.html ; \
	done
endif

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
