#! /bin/sh
#
# rootinstall.sh
# Perform all of the root installation tasks
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
# Perform all of the root installation tasks
# whoami is not completely portable
if [ "`whoami`" != "root" ]; then
   echo ERROR: You must be root to run this script
   exit 1;
fi;

GNUSTEP_TARGET_DIR=$GNUSTEP_TARGET_CPU/$GNUSTEP_TARGET_OS

# taken from base/Tools/Makefile.postamble
# Install the gdomap executables
# TODO: automatically handle GDOMAP_PORT_OVERRIDE
echo Installing gdomap
echo "WARNING: gdomap MUST be installed owned by rooot and with";
echo "the 's-bit' set unless you defined 'GDOMAP_PORT_OVERRIDE' in";
echo "gdomap.h before compiling gdomap.c and NSPortNameServer.m";
echo "in which case you should install it by hand.";

chmod 05755 $GNUSTEP_SYSTEM_ROOT/Tools/$GNUSTEP_TARGET_DIR/gdomap
chown root $GNUSTEP_SYSTEM_ROOT/Tools/$GNUSTEP_TARGET_DIR/gdomap

#
if [ "$INSTALL_ROOT_DIR" = "" ]; then
  services=/etc/services;
  echo "GNUstep addons written to /etc/services";
else
  mkdir -p $INSTALL_ROOT_DIR/etc;
  services=$INSTALL_ROOT_DIR/etc/services.add;
  echo "GNUstep addons for /etc/services written to $services";
fi;
if [ "`fgrep gdomap $services 2>/dev/null`" = "" ]; then
    set -x;
    echo "gdomap 538/tcp # GNUstep distrib objects" >> $services;
    echo "gdomap 538/udp # GNUstep distrib objects" >> $services;
fi
