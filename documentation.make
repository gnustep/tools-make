#
#   documentation.make
#
#   Makefile rules to build GNUstep-based texinfo documentation.
#
#   Copyright (C) 1998 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
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
	for i in $(TEXI_FILES); do \
           cp $$i `basename $$i .tmpl.texi`.texi ; \
	done
	$(GNUSTEP_MAKEINFO) $(GNUSTEP_MAKEINFO_FLAGS) \
		-o $@ $(INTERNAL_doc_NAME).texi

$(INTERNAL_doc_NAME).dvi: $(TEXI_FILES)
	for i in $(TEXI_FILES); do \
	  -cp $$i `basename $$i .tmpl.texi`.texi ; \
	done
	$(GNUSTEP_TEXI2DVI) $(GNUSTEP_TEXI2DVI_FLAGS) $(INTERNAL_doc_NAME).texi

$(INTERNAL_doc_NAME).ps: $(INTERNAL_doc_NAME).dvi
	$(GNUSTEP_DVIPS) $(GNUSTEP_DVIPS_FLAGS) \
		$(INTERNAL_doc_NAME).dvi -o $@

$(INTERNAL_doc_NAME)_toc.html: $(TEXI_FILES)
	for i in $(TEXI_FILES); do \
	   sed -e 's,@email{\([^}]*\)},<A HREF="mailto:\1">\1</A>,g' \
		$$i \
		| sed -e 's,@url{\([^}]*\)},<A HREF="\1">\1</A>,g' \
		| sed -e 's,^ *$$,@br{},g' \
		> `basename $$i .tmpl.texi`.texi ; \
	done
	$(GNUSTEP_TEXI2HTML) $(GNUSTEP_TEXI2HTML_FLAGS) \
		$(INTERNAL_doc_NAME).texi

$(INTERNAL_textdoc_NAME): $(TEXI_FILES) $(TEXT_MAIN)
	for i in $(TEXI_FILES) $(TEXT_MAIN); do \
           -cp $$i `basename $$i .tmpl.texi`.texi ; \
	done
	$(GNUSTEP_MAKETEXT) $(GNUSTEP_MAKETEXT_FLAGS) \
		-o $@ `basename $(TEXT_MAIN) .tmpl.texi`.texi

endif

before-$(TARGET)-all::

after-$(TARGET)-all::


ifneq ($(GSDOC_FILES),)

internal-doc-all:: before-all before-$(TARGET)-all \
                   $(INTERNAL_doc_NAME).html \
                   after-$(TARGET)-all after-all

$(INTERNAL_doc_NAME).html: $(GSDOC_FILES)
	gsdoc $(GSDOC_FILES)

endif


#
# Install and uninstall targets
#
internal-doc-install:: internal-install-dirs

internal-textdoc-install::
   
internal-install-dirs::
	$(MKDIRS) $(GNUSTEP_DOCUMENTATION)

internal-doc-uninstall:: 

internal-textdoc-uninstall:: 

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
ifneq ($(TEXI_FILES),)
	for i in $(TEXI_FILES); do \
		rm -f `basename $$i .tmpl.texi`.texi ; \
	done
endif
ifneq ($(GSDOC_FILES),)
	for i in $(GSDOC_FILES); do \
		rm -f `basename $$i .gsdoc`.html ; \
	done
endif

internal-textdoc-clean::
	rm -f $(INTERNAL_textdoc_NAME)
ifneq ($(TEXI_FILES),)
	for i in $(TEXI_FILES) $(TEXT_MAIN); do \
		rm -f `basename $$i .tmpl.texi`.texi ; \
	done
endif
ifneq ($(GSDOC_FILES),)
	for i in $(GSDOC_FILES); do \
		rm -f `basename $$i .gsdoc`.html ; \
	done
endif

internal-doc-distclean::

internal-textdoc-distclean::

#
# Testing targets
#
internal-doc-check::

internal-textdoc-check::

endif

endif
# documentation.make loaded
