#! /bin/sh
#
# rootuninstall.sh
# Undo the root installation tasks
#
# Copyright (C) 1999 Free Software Foundation, Inc.
#
# Author: Scott Christley <scottc@net-community.com>
# Date: February 1999
# 
# This file is part of the GNUstep Makefile Package.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# You should have received a copy of the GNU General Public
# License along with this library; see the file COPYING.LIB.
# If not, write to the Free Software Foundation,
# 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#
# Perform all of the root de-installation tasks
# whoami is not completely portable
if [ "`whoami`" != "root" ]; then
   echo ERROR: You must be root to run this script
   exit 1;
fi;

GNUSTEP_TARGET_DIR=$GNUSTEP_TARGET_CPU/$GNUSTEP_TARGET_OS

# Uninstall the gdomap executable
# TODO: automatically handle GDOMAP_PORT_OVERRIDE
echo Uninstalling gdomap

rm -f $GNUSTEP_SYSTEM_ROOT/Tools/$GNUSTEP_TARGET_DIR/gdomap

if [ "$INSTALL_ROOT_DIR" = "" ]; then
  services=/etc/services;
else
  services=$INSTALL_ROOT_DIR/etc/services.add;
fi;
if [ "`fgrep gdomap $services 2>/dev/null`" != "" ]; then
    echo "ATTENTION: Manually remove these lines from your $services file"
    echo "gdomap 538/tcp # GNUstep distrib objects"
    echo "gdomap 538/udp # GNUstep distrib objects"
fi
