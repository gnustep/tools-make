#! /bin/sh
#
#   MediaBook.sh
#
#   Variable initialization for the MediaBook environment
#
#   Copyright (C) 1997 NET-Community
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
#

if [ -z $1 ]; then
	MB_ROOT=~
else
        MB_ROOT=$1
fi

export MB_ROOT

#
# Save the original environment variables
#
MB_ORIG_PATH=$PATH
MB_ORIG_LD_LIBRARY_PATH=$LD_LIBRARY_PATH

export MB_ORIG_PATH MB_PROD_LD_LIBRARY_PATH

#
# GCC environment variables
# we will use this for hosting Project Center
#
#GCC_EXEC_PREFIX=$GNUSTEP_SYSTEM_ROOT/Libraries/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/gcc-lib/
#export GCC_EXEC_PREFIX

#
# variables for current system directories
#
MB_SYS=
MB_CUR=
MB_CUR_SYS=
MB_CUR_TOP=
MB_CUR_VER=
MB_CUR_SOU=
MB_CUR_H=
MB_CUR_TST=
MB_CUR_DOC=
MB_CUR_BIN=
# specialized systems
MB_GNUSTEP_SOURCE=
MB_FINANCE_SOURCE=

export MB_SYS MB_CUR
export MB_CUR_SYS MB_CUR_TOP
export MB_CUR_VER MB_CUR_SOU MB_CUR_H MB_CUR_TST MB_CUR_DOC MB_CUR_BIN
export MB_GNUSTEP_SOURCE
export MB_FINANCE_SOURCE

#
# Perform any user initialization
#
if [ -e $GNUSTEP_USER_ROOT/Library/MediaBook/MBinit.sh ]
then
	. $GNUSTEP_USER_ROOT/Library/MediaBook/MBinit.sh
fi
