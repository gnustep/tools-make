#! /bin/echo This file must be sourced inside (ba)sh using: .
#   filesystem.sh
#
#   Sets up the GNUstep filesystem paths for shell scripts
#
#   Copyright (C) 2007 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola.pero@meta-innovation.com>,
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
# This does the same that filesystem.make does, but for GNUstep.sh.
# Include this file after reading your config to make sure that all
# the paths are available.
#
# PS: If you change this list, make sure that top update the list of
# paths used in all other filesystem.*, and in common.make when
# GNUSTEP_INSTALLATION_DIR is set.
#

# PS: We don't want to define these variables to avoid extreme
# environment pollution. :-) They are fixed subdirs of LIBRARY if you
# need them.
#GNUSTEP_SYSTEM_APPLICATION_SUPPORT  = $GNUSTEP_SYSTEM_LIBRARY/ApplicationSupport
#GNUSTEP_SYSTEM_BUNDLES              = $GNUSTEP_SYSTEM_LIBRARY/Bundles
#GNUSTEP_SYSTEM_FRAMEWORKS           = $GNUSTEP_SYSTEM_LIBRARY/Frameworks
#GNUSTEP_SYSTEM_PALETTES             = $GNUSTEP_SYSTEM_LIBRARY/ApplicationSupport/Palettes
#GNUSTEP_SYSTEM_SERVICES             = $GNUSTEP_SYSTEM_LIBRARY/Services

#
# SYSTEM domain
#
if [ -z "$GNUSTEP_SYSTEM_APPS" ]; then GNUSTEP_SYSTEM_APPS="$GNUSTEP_SYSTEM_ROOT/Applications"; fi
if [ -z "$GNUSTEP_SYSTEM_TOOLS" ]; then GNUSTEP_SYSTEM_TOOLS="$GNUSTEP_SYSTEM_ROOT/Tools"; fi
if [ -z "$GNUSTEP_SYSTEM_LIBRARY" ]; then GNUSTEP_SYSTEM_LIBRARY="$GNUSTEP_SYSTEM_ROOT/Library"; fi
if [ "$GNUSTEP_IS_FLATTENED" = "yes" ]; then
  if [ -z "$GNUSTEP_SYSTEM_HEADERS" ]; then GNUSTEP_SYSTEM_HEADERS="$GNUSTEP_SYSTEM_ROOT/Library/Headers"; fi
else
  if [ -z "$GNUSTEP_SYSTEM_HEADERS" ]; then GNUSTEP_SYSTEM_HEADERS="$GNUSTEP_SYSTEM_ROOT/Library/Headers/$LIBRARY_COMBO"; fi
fi
if [ -z "$GNUSTEP_SYSTEM_LIBRARIES" ]; then GNUSTEP_SYSTEM_LIBRARIES="$GNUSTEP_SYSTEM_LIBRARY/Libraries/"; fi
if [ -z "$GNUSTEP_SYSTEM_RESOURCES" ]; then GNUSTEP_SYSTEM_RESOURCES="$GNUSTEP_SYSTEM_LIBRARY/Libraries/Resources"; fi
if [ -z "$GNUSTEP_SYSTEM_JAVA" ]; then GNUSTEP_SYSTEM_JAVA="$GNUSTEP_SYSTEM_LIBRARY/Libraries/Java"; fi
if [ -z "$GNUSTEP_SYSTEM_DOCUMENTATION" ]; then GNUSTEP_SYSTEM_DOCUMENTATION="$GNUSTEP_SYSTEM_LIBRARY/Documentation"; fi
if [ -z "$GNUSTEP_SYSTEM_DOCUMENTATION_MAN" ]; then GNUSTEP_SYSTEM_DOCUMENTATION_MAN="$GNUSTEP_SYSTEM_DOCUMENTATION/man"; fi
if [ -z "$GNUSTEP_SYSTEM_DOCUMENTATION_INFO" ]; then GNUSTEP_SYSTEM_DOCUMENTATION_INFO="$GNUSTEP_SYSTEM_DOCUMENTATION/info"; fi


#
# LOCAL domain
#
if [ -z "$GNUSTEP_LOCAL_APPS" ]; then GNUSTEP_LOCAL_APPS="$GNUSTEP_LOCAL_ROOT/Applications"; fi
if [ -z "$GNUSTEP_LOCAL_TOOLS" ]; then GNUSTEP_LOCAL_TOOLS="$GNUSTEP_LOCAL_ROOT/Tools"; fi
if [ -z "$GNUSTEP_LOCAL_LIBRARY" ]; then GNUSTEP_LOCAL_LIBRARY="$GNUSTEP_LOCAL_ROOT/Library"; fi
if [ "$GNUSTEP_IS_FLATTENED" = "yes" ]; then
  if [ -z "$GNUSTEP_LOCAL_HEADERS" ]; then GNUSTEP_LOCAL_HEADERS="$GNUSTEP_LOCAL_ROOT/Library/Headers"; fi
else
  if [ -z "$GNUSTEP_LOCAL_HEADERS" ]; then GNUSTEP_LOCAL_HEADERS="$GNUSTEP_LOCAL_ROOT/Library/Headers/$LIBRARY_COMBO"; fi
fi
if [ -z "$GNUSTEP_LOCAL_LIBRARIES" ]; then GNUSTEP_LOCAL_LIBRARIES="$GNUSTEP_LOCAL_LIBRARY/Libraries/"; fi
if [ -z "$GNUSTEP_LOCAL_RESOURCES" ]; then GNUSTEP_LOCAL_RESOURCES="$GNUSTEP_LOCAL_LIBRARY/Libraries/Resources"; fi
if [ -z "$GNUSTEP_LOCAL_JAVA" ]; then GNUSTEP_LOCAL_JAVA="$GNUSTEP_LOCAL_LIBRARY/Libraries/Java"; fi
if [ -z "$GNUSTEP_LOCAL_DOCUMENTATION" ]; then GNUSTEP_LOCAL_DOCUMENTATION="$GNUSTEP_LOCAL_LIBRARY/Documentation"; fi
if [ -z "$GNUSTEP_LOCAL_DOCUMENTATION_MAN" ]; then GNUSTEP_LOCAL_DOCUMENTATION_MAN="$GNUSTEP_LOCAL_DOCUMENTATION/man"; fi
if [ -z "$GNUSTEP_LOCAL_DOCUMENTATION_INFO" ]; then GNUSTEP_LOCAL_DOCUMENTATION_INFO="$GNUSTEP_LOCAL_DOCUMENTATION/info"; fi

#
# NETWORK domain
#
if [ -z "$GNUSTEP_NETWORK_APPS" ]; then GNUSTEP_NETWORK_APPS="$GNUSTEP_NETWORK_ROOT/Applications"; fi
if [ -z "$GNUSTEP_NETWORK_TOOLS" ]; then GNUSTEP_NETWORK_TOOLS="$GNUSTEP_NETWORK_ROOT/Tools"; fi
if [ -z "$GNUSTEP_NETWORK_LIBRARY" ]; then GNUSTEP_NETWORK_LIBRARY="$GNUSTEP_NETWORK_ROOT/Library"; fi
if [ "$GNUSTEP_IS_FLATTENED" = "yes" ]; then
  if [ -z "$GNUSTEP_NETWORK_HEADERS" ]; then GNUSTEP_NETWORK_HEADERS="$GNUSTEP_NETWORK_ROOT/Library/Headers"; fi
else
  if [ -z "$GNUSTEP_NETWORK_HEADERS" ]; then GNUSTEP_NETWORK_HEADERS="$GNUSTEP_NETWORK_ROOT/Library/Headers/$LIBRARY_COMBO"; fi
fi
if [ -z "$GNUSTEP_NETWORK_LIBRARIES" ]; then GNUSTEP_NETWORK_LIBRARIES="$GNUSTEP_NETWORK_LIBRARY/Libraries/"; fi
if [ -z "$GNUSTEP_NETWORK_RESOURCES" ]; then GNUSTEP_NETWORK_RESOURCES="$GNUSTEP_NETWORK_LIBRARY/Libraries/Resources"; fi
if [ -z "$GNUSTEP_NETWORK_JAVA" ]; then GNUSTEP_NETWORK_JAVA="$GNUSTEP_NETWORK_LIBRARY/Libraries/Java"; fi
if [ -z "$GNUSTEP_NETWORK_DOCUMENTATION" ]; then GNUSTEP_NETWORK_DOCUMENTATION="$GNUSTEP_NETWORK_LIBRARY/Documentation"; fi
if [ -z "$GNUSTEP_NETWORK_DOCUMENTATION_MAN" ]; then GNUSTEP_NETWORK_DOCUMENTATION_MAN="$GNUSTEP_NETWORK_DOCUMENTATION/man"; fi
if [ -z "$GNUSTEP_NETWORK_DOCUMENTATION_INFO" ]; then GNUSTEP_NETWORK_DOCUMENTATION_INFO="$GNUSTEP_NETWORK_DOCUMENTATION/info"; fi


#
# USER domain
#
if [ -z "$GNUSTEP_USER_APPS" ]; then GNUSTEP_USER_APPS="$GNUSTEP_USER_ROOT/Applications"; fi
if [ -z "$GNUSTEP_USER_TOOLS" ]; then GNUSTEP_USER_TOOLS="$GNUSTEP_USER_ROOT/Tools"; fi
if [ -z "$GNUSTEP_USER_LIBRARY" ]; then GNUSTEP_USER_LIBRARY="$GNUSTEP_USER_ROOT/Library"; fi
if [ "$GNUSTEP_IS_FLATTENED" = "yes" ]; then
  if [ -z "$GNUSTEP_USER_HEADERS" ]; then GNUSTEP_USER_HEADERS="$GNUSTEP_USER_ROOT/Library/Headers"; fi
else
  if [ -z "$GNUSTEP_USER_HEADERS" ]; then GNUSTEP_USER_HEADERS="$GNUSTEP_USER_ROOT/Library/Headers/$LIBRARY_COMBO"; fi
fi
if [ -z "$GNUSTEP_USER_LIBRARIES" ]; then GNUSTEP_USER_LIBRARIES="$GNUSTEP_USER_LIBRARY/Libraries/"; fi
if [ -z "$GNUSTEP_USER_RESOURCES" ]; then GNUSTEP_USER_RESOURCES="$GNUSTEP_USER_LIBRARY/Libraries/Resources"; fi
if [ -z "$GNUSTEP_USER_JAVA" ]; then GNUSTEP_USER_JAVA="$GNUSTEP_USER_LIBRARY/Libraries/Java"; fi
if [ -z "$GNUSTEP_USER_DOCUMENTATION" ]; then GNUSTEP_USER_DOCUMENTATION="$GNUSTEP_USER_LIBRARY/Documentation"; fi
if [ -z "$GNUSTEP_USER_DOCUMENTATION_MAN" ]; then GNUSTEP_USER_DOCUMENTATION_MAN="$GNUSTEP_USER_DOCUMENTATION/man"; fi
if [ -z "$GNUSTEP_USER_DOCUMENTATION_INFO" ]; then GNUSTEP_USER_DOCUMENTATION_INFO="$GNUSTEP_USER_DOCUMENTATION/info"; fi
