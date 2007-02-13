#
#   filesystem.make
#
#   Sets up the filesystem paths
#
#   Copyright (C) 2007 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola.pero@meta-innovation.com>,
#            Matt Rice <ratmice@gmail.com>, 
#            
#   Date:  February 2007
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
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

#
# We make sure that all the interesting paths in all domains are
# defined.  Having this is a great help in iterating over header dirs,
# for example.
#
# PS: If you change this list, make sure that top update the list of
# paths used in common.make when GNUSTEP_INSTALLATION_DIR is set.
#

#
# We use '?=' to only set variables that have not already been set
# by the user in the config files (that should be read before
# this file).  So, this describes the GNUstep filesystem default
# that is automatically used when the config file is missing some
# settings.
#
# We keep the list in this simple format (instead of generating it
# from functions, for example) to make it very easy to read for
# everyone.
#

#
# SYSTEM domain
#
GNUSTEP_SYSTEM_APPS                 ?= $(GNUSTEP_SYSTEM_ROOT)/Applications
GNUSTEP_SYSTEM_TOOLS                ?= $(GNUSTEP_SYSTEM_ROOT)/Tools
GNUSTEP_SYSTEM_LIBRARY              ?= $(GNUSTEP_SYSTEM_ROOT)/Library
GNUSTEP_SYSTEM_SERVICES             ?= $(GNUSTEP_SYSTEM_LIBRARY)/Services
ifeq ($(GNUSTEP_IS_FLATTENED),yes)
  GNUSTEP_SYSTEM_HEADERS            ?= $(GNUSTEP_SYSTEM_ROOT)/Library/Headers
else
  GNUSTEP_SYSTEM_HEADERS            ?= $(GNUSTEP_SYSTEM_ROOT)/Library/Headers/$(LIBRARY_COMBO)
endif
GNUSTEP_SYSTEM_APPLICATION_SUPPORT  ?= $(GNUSTEP_SYSTEM_LIBRARY)/ApplicationSupport
GNUSTEP_SYSTEM_BUNDLES              ?= $(GNUSTEP_SYSTEM_LIBRARY)/Bundles
GNUSTEP_SYSTEM_FRAMEWORKS           ?= $(GNUSTEP_SYSTEM_LIBRARY)/Frameworks
GNUSTEP_SYSTEM_PALETTES             ?= $(GNUSTEP_SYSTEM_LIBRARY)/ApplicationSupport/Palettes
GNUSTEP_SYSTEM_LIBRARIES            ?= $(GNUSTEP_SYSTEM_ROOT)/Library/Libraries
GNUSTEP_SYSTEM_RESOURCES            ?= $(GNUSTEP_SYSTEM_LIBRARY)/Libraries/Resources
GNUSTEP_SYSTEM_JAVA                 ?= $(GNUSTEP_SYSTEM_LIBRARY)/Libraries/Java
GNUSTEP_SYSTEM_DOCUMENTATION        ?= $(GNUSTEP_SYSTEM_LIBRARY)/Documentation
GNUSTEP_SYSTEM_DOCUMENTATION_MAN    ?= $(GNUSTEP_SYSTEM_DOCUMENTATION)/man
GNUSTEP_SYSTEM_DOCUMENTATION_INFO   ?= $(GNUSTEP_SYSTEM_DOCUMENTATION)/info

#
# LOCAL domain
#
GNUSTEP_LOCAL_APPS                 ?= $(GNUSTEP_LOCAL_ROOT)/Applications
GNUSTEP_LOCAL_TOOLS                ?= $(GNUSTEP_LOCAL_ROOT)/Tools
GNUSTEP_LOCAL_LIBRARY              ?= $(GNUSTEP_LOCAL_ROOT)/Library
GNUSTEP_LOCAL_SERVICES             ?= $(GNUSTEP_LOCAL_LIBRARY)/Services
ifeq ($(GNUSTEP_IS_FLATTENED),yes)
  GNUSTEP_LOCAL_HEADERS              ?= $(GNUSTEP_LOCAL_ROOT)/Library/Headers
else
  GNUSTEP_LOCAL_HEADERS              ?= $(GNUSTEP_LOCAL_ROOT)/Library/Headers/$(LIBRARY_COMBO)
endif
GNUSTEP_LOCAL_APPLICATION_SUPPORT  ?= $(GNUSTEP_LOCAL_LIBRARY)/ApplicationSupport
GNUSTEP_LOCAL_BUNDLES              ?= $(GNUSTEP_LOCAL_LIBRARY)/Bundles
GNUSTEP_LOCAL_FRAMEWORKS           ?= $(GNUSTEP_LOCAL_LIBRARY)/Frameworks
GNUSTEP_LOCAL_PALETTES             ?= $(GNUSTEP_LOCAL_LIBRARY)/ApplicationSupport/Palettes
GNUSTEP_LOCAL_LIBRARIES            ?= $(GNUSTEP_LOCAL_ROOT)/Library/Libraries
GNUSTEP_LOCAL_RESOURCES            ?= $(GNUSTEP_LOCAL_LIBRARY)/Libraries/Resources
GNUSTEP_LOCAL_JAVA                 ?= $(GNUSTEP_LOCAL_LIBRARY)/Libraries/Java
GNUSTEP_LOCAL_DOCUMENTATION        ?= $(GNUSTEP_LOCAL_LIBRARY)/Documentation
GNUSTEP_LOCAL_DOCUMENTATION_MAN    ?= $(GNUSTEP_LOCAL_DOCUMENTATION)/man
GNUSTEP_LOCAL_DOCUMENTATION_INFO   ?= $(GNUSTEP_LOCAL_DOCUMENTATION)/info

#
# NETWORK domain
#
GNUSTEP_NETWORK_APPS                 ?= $(GNUSTEP_NETWORK_ROOT)/Applications
GNUSTEP_NETWORK_TOOLS                ?= $(GNUSTEP_NETWORK_ROOT)/Tools
GNUSTEP_NETWORK_LIBRARY              ?= $(GNUSTEP_NETWORK_ROOT)/Library
GNUSTEP_NETWORK_SERVICES             ?= $(GNUSTEP_NETWORK_LIBRARY)/Services
ifeq ($(GNUSTEP_IS_FLATTENED),yes)
  GNUSTEP_NETWORK_HEADERS            ?= $(GNUSTEP_NETWORK_ROOT)/Library/Headers
else
  GNUSTEP_NETWORK_HEADERS              ?= $(GNUSTEP_NETWORK_ROOT)/Library/Headers/$(LIBRARY_COMBO)
endif
GNUSTEP_NETWORK_APPLICATION_SUPPORT  ?= $(GNUSTEP_NETWORK_LIBRARY)/ApplicationSupport
GNUSTEP_NETWORK_BUNDLES              ?= $(GNUSTEP_NETWORK_LIBRARY)/Bundles
GNUSTEP_NETWORK_FRAMEWORKS           ?= $(GNUSTEP_NETWORK_LIBRARY)/Frameworks
GNUSTEP_NETWORK_PALETTES             ?= $(GNUSTEP_NETWORK_LIBRARY)/ApplicationSupport/Palettes
GNUSTEP_NETWORK_LIBRARIES            ?= $(GNUSTEP_NETWORK_ROOT)/Library/Libraries
GNUSTEP_NETWORK_RESOURCES            ?= $(GNUSTEP_NETWORK_LIBRARY)/Libraries/Resources
GNUSTEP_NETWORK_JAVA                 ?= $(GNUSTEP_NETWORK_LIBRARY)/Libraries/Java
GNUSTEP_NETWORK_DOCUMENTATION        ?= $(GNUSTEP_NETWORK_LIBRARY)/Documentation
GNUSTEP_NETWORK_DOCUMENTATION_MAN    ?= $(GNUSTEP_NETWORK_DOCUMENTATION)/man
GNUSTEP_NETWORK_DOCUMENTATION_INFO   ?= $(GNUSTEP_NETWORK_DOCUMENTATION)/info

#
# USER domain
#
GNUSTEP_USER_APPS                 ?= $(GNUSTEP_USER_ROOT)/Applications
GNUSTEP_USER_TOOLS                ?= $(GNUSTEP_USER_ROOT)/Tools
GNUSTEP_USER_LIBRARY              ?= $(GNUSTEP_USER_ROOT)/Library
GNUSTEP_USER_SERVICES             ?= $(GNUSTEP_USER_LIBRARY)/Services
ifeq ($(GNUSTEP_IS_FLATTENED),yes)
  GNUSTEP_USER_HEADERS            ?= $(GNUSTEP_USER_ROOT)/Library/Headers
else
  GNUSTEP_USER_HEADERS            ?= $(GNUSTEP_USER_ROOT)/Library/Headers/$(LIBRARY_COMBO)
endif
GNUSTEP_USER_APPLICATION_SUPPORT  ?= $(GNUSTEP_USER_LIBRARY)/ApplicationSupport
GNUSTEP_USER_BUNDLES              ?= $(GNUSTEP_USER_LIBRARY)/Bundles
GNUSTEP_USER_FRAMEWORKS           ?= $(GNUSTEP_USER_LIBRARY)/Frameworks
GNUSTEP_USER_PALETTES             ?= $(GNUSTEP_USER_LIBRARY)/ApplicationSupport/Palettes
GNUSTEP_USER_LIBRARIES            ?= $(GNUSTEP_USER_ROOT)/Library/Libraries
GNUSTEP_USER_RESOURCES            ?= $(GNUSTEP_USER_LIBRARY)/Libraries/Resources
GNUSTEP_USER_JAVA                 ?= $(GNUSTEP_USER_LIBRARY)/Libraries/Java
GNUSTEP_USER_DOCUMENTATION        ?= $(GNUSTEP_USER_LIBRARY)/Documentation
GNUSTEP_USER_DOCUMENTATION_MAN    ?= $(GNUSTEP_USER_DOCUMENTATION)/man
GNUSTEP_USER_DOCUMENTATION_INFO   ?= $(GNUSTEP_USER_DOCUMENTATION)/info
