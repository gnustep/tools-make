#! /bin/sh
#
#   ld_lib_path.sh
#
#   Return the name of the environment variable for the operating
#   system that is used by the dynamic loader.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
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

# The first (and only) parameter to this script is the canonical
# operating system name

# LD_LIBRARY_PATH is the default name
ld_lib_path="LD_LIBRARY_PATH"

case "$1" in

    *nextstep4*)
	ld_lib_path="DYLD_LIBRARY_PATH"
	;;

esac   

echo $ld_lib_path
