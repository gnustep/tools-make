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
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
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
# operating system name.

last_path_part=Libraries/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/$LIBRARY_COMBO
tool_path_part=Libraries/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS

host_os=$GNUSTEP_HOST_OS

if [ -z "$host_os" ]; then
  host_os=$1
fi

old_IFS="$IFS"
IFS=" 
"

case "$host_os" in

  *nextstep4*)
    if [ -z "$DYLD_LIBRARY_PATH" ]; then
	DYLD_LIBRARY_PATH="$GNUSTEP_USER_ROOT/$last_path_part:$GNUSTEP_USER_ROOT/$tool_path_part:$GNUSTEP_LOCAL_ROOT/$last_path_part:$GNUSTEP_LOCAL_ROOT/$tool_path_part:$GNUSTEP_SYSTEM_ROOT/$last_path_part:$GNUSTEP_SYSTEM_ROOT/$tool_path_part"
    else
	DYLD_LIBRARY_PATH="$GNUSTEP_USER_ROOT/$last_path_part:$GNUSTEP_USER_ROOT/$tool_path_part:$GNUSTEP_LOCAL_ROOT/$last_path_part:$GNUSTEP_LOCAL_ROOT/$tool_path_part:$GNUSTEP_SYSTEM_ROOT/$last_path_part:$GNUSTEP_SYSTEM_ROOT/$tool_path_part:$DYLD_LIBRARY_PATH"
    fi
    if [ -n "$additional_library_paths" ]; then
      for dir in $additional_library_paths; do
	additional="${additional}${dir}:"
      done
    fi
    DYLD_LIBRARY_PATH="${additional}${DYLD_LIBRARY_PATH}"
    export DYLD_LIBRARY_PATH
    ;;

  *)
    if [ -z "$LD_LIBRARY_PATH" ]; then
	LD_LIBRARY_PATH="$GNUSTEP_USER_ROOT/$last_path_part:$GNUSTEP_USER_ROOT/$tool_path_part:$GNUSTEP_LOCAL_ROOT/$last_path_part:$GNUSTEP_LOCAL_ROOT/$tool_path_part:$GNUSTEP_SYSTEM_ROOT/$last_path_part:$GNUSTEP_SYSTEM_ROOT/$tool_path_part"
    else
	LD_LIBRARY_PATH="$GNUSTEP_USER_ROOT/$last_path_part:$GNUSTEP_USER_ROOT/$tool_path_part:$GNUSTEP_LOCAL_ROOT/$last_path_part:$GNUSTEP_LOCAL_ROOT/$tool_path_part:$GNUSTEP_SYSTEM_ROOT/$last_path_part:$GNUSTEP_SYSTEM_ROOT/$tool_path_part:$LD_LIBRARY_PATH"
    fi
    if [ -n "$additional_library_paths" ]; then
      for dir in $additional_library_paths; do
	additional="${additional}${dir}:"
      done
    fi
    LD_LIBRARY_PATH="${additional}${LD_LIBRARY_PATH}"
    export LD_LIBRARY_PATH;;

esac

IFS="$old_IFS"
