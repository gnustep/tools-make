#
#   Master/palette.make
#
#   Master Makefile rules to build GNUstep-based palettes.
#
#   Copyright (C) 1999 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#   Author:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
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

PALETTE_NAME:=$(strip $(PALETTE_NAME))

internal-all:: $(PALETTE_NAME:=.all.palette.variables)

internal-install:: $(PALETTE_NAME:=.install.palette.variables)

internal-uninstall:: $(PALETTE_NAME:=.uninstall.palette.variables)

_PSWRAP_C_FILES = $(foreach palette,$(PALETTE_NAME),$($(palette)_PSWRAP_FILES:.psw=.c))
_PSWRAP_H_FILES = $(foreach palette,$(PALETTE_NAME),$($(palette)_PSWRAP_FILES:.psw=.h))

internal-clean::
	rm -rf $(GNUSTEP_OBJ_DIR) $(_PSWRAP_C_FILES) $(_PSWRAP_H_FILES)

internal-distclean:: $(PALETTE_NAME:=.distclean.palette.variables)

PALETTES_WITH_SUBPROJECTS = $(strip $(foreach palette,$(PALETTE_NAME),$(patsubst %,$(palette),$($(palette)_SUBPROJECTS))))
ifneq ($(PALETTES_WITH_SUBPROJECTS),)
internal-clean:: $(PALETTES_WITH_SUBPROJECTS:=.clean.palette.subprojects)
endif

$(PALETTE_NAME):
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory \
		$@.all.palette.variables

## Local variables:
## mode: makefile
## End:
