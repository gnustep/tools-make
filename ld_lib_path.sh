#! /bin/sh
#
#   ld_lib_path.sh
#
#   Return the name of the environment variable for the operating
#   system that is used by the dynamic loader.
#
#   Copyright (C) 1997,1999 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#   Rewrite: Richard Frith-Macdoanld <richard@brainstorm.co.uk>
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

lib_paths="$GNUSTEP_USER_ROOT/$last_path_part:$GNUSTEP_USER_ROOT/$tool_path_part:$GNUSTEP_LOCAL_ROOT/$last_path_part:$GNUSTEP_LOCAL_ROOT/$tool_path_part:$GNUSTEP_SYSTEM_ROOT/$last_path_part:$GNUSTEP_SYSTEM_ROOT/$tool_path_part"

if [ -n "$additional_library_paths" ]; then
  for dir in $additional_library_paths; do
    additional="${additional}${dir}:"
  done
fi
lib_paths="${additional}${lib_paths}"

case "$host_os" in

  *nextstep4*)
    if [ -z "$DYLD_LIBRARY_PATH" ]; then
      DYLD_LIBRARY_PATH="$lib_paths"
    else
      if ( echo ${DYLD_LIBRARY_PATH}|fgrep -v "${lib_paths}" >/dev/null ); then
	DYLD_LIBRARY_PATH="$lib_paths:$DYLD_LIBRARY_PATH"
      fi
    fi
    export DYLD_LIBRARY_PATH
    ;;

  *hpux*)
    if [ -z "$SHLIB_PATH" ]; then
      SHLIB_PATH="$lib_paths"
    else
      if ( echo ${SHLIB_PATH}|fgrep -v "${lib_paths}" >/dev/null ); then
	SHLIB_PATH="$lib_paths:$SHLIB_PATH"
      fi
    fi
    export SHLIB_PATH;
    if [ -z "$LD_LIBRARY_PATH" ]; then
      LD_LIBRARY_PATH="$lib_paths"
    else
      if ( echo ${LD_LIBRARY_PATH}|fgrep -v "${lib_paths}" >/dev/null ); then
	LD_LIBRARY_PATH="$lib_paths:$LD_LIBRARY_PATH"
      fi
    fi
    export LD_LIBRARY_PATH;;

  *)
    if [ -z "$LD_LIBRARY_PATH" ]; then
      LD_LIBRARY_PATH="$lib_paths"
    else
      if ( echo ${LD_LIBRARY_PATH}|fgrep -v "${lib_paths}" >/dev/null ); then
	LD_LIBRARY_PATH="$lib_paths:$LD_LIBRARY_PATH"
      fi
    fi
    export LD_LIBRARY_PATH;;

esac

IFS="$old_IFS"
