#! /bin/sh
#
#   ld_lib_path.sh
#
#   Set up the LD_LIBRARY_PATH (or similar env variable for your system)
#
#   Copyright (C) 1997-2002 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#   Rewrite: Richard Frith-Macdonald <richard@brainstorm.co.uk>
#   Author: Nicola Pero <n.pero@mi.flashnet.it>
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

# This file is sourced.  This means extra care is needed when changing
# it.  Please read the comments on GNUstep.sh.in before touching it.

# The first (and only) parameter to this script is the canonical
# operating system name.

host_os=$GNUSTEP_HOST_OS

if [ -z "$host_os" ]; then
  host_os=$1
fi


old_IFS="$IFS"
IFS=:
lib_paths=
fw_paths=
for dir in $GNUSTEP_PATHLIST; do

  # prepare the path_fragment for libraries and this dir
  if [ -z "$GNUSTEP_FLATTENED" ]; then
    path_fragment="$dir/Library/Libraries/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/$LIBRARY_COMBO:$dir/Library/Libraries/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS"
  else
    path_fragment="$dir/Library/Libraries"
  fi

  # Append the path_fragment to lib_paths
  if [ -z "$lib_paths" ]; then
    lib_paths="$path_fragment"
  else
    lib_paths="$lib_paths:$path_fragment"
  fi

  # prepare the path_fragment for frameworks and this dir
  path_fragment="$dir/Library/Frameworks"

  # Append the path_fragment to fw_paths
  if [ -z "$fw_paths" ]; then
    fw_paths="$path_fragment"
  else
    fw_paths="$fw_paths:$path_fragment"
  fi

  unset path_fragment

done
IFS="$old_IFS"
unset old_IFS
unset dir


if [ -n "$additional_library_paths" ]; then
  old_IFS="$IFS"
  IFS=" 
"
  additional=""
  for dir in $additional_library_paths; do
    additional="${additional}${dir}:"
  done
  unset dir

  lib_paths="${additional}${lib_paths}"

  unset additional
  IFS="$old_IFS"
  unset old_IFS
fi

if [ -n "$additional_framework_paths" ]; then
  old_IFS="$IFS"
  IFS="
"
  additional=""
  for dir in $additional_framework_paths; do
    additional="${additional}${dir}:"
  done
  unset dir

  fw_paths="${additional}${fw_paths}"

  unset additional
  IFS="$old_IFS"
  unset old_IFS
fi

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

  *darwin*)
    if [ -z "$DYLD_LIBRARY_PATH" ]; then
      DYLD_LIBRARY_PATH="$lib_paths"
    else
      if ( echo ${DYLD_LIBRARY_PATH}|fgrep -v "${lib_paths}" >/dev/null ); then
	DYLD_LIBRARY_PATH="$lib_paths:$DYLD_LIBRARY_PATH"
      fi
    fi
    export DYLD_LIBRARY_PATH
    if [ -z "$DYLD_FRAMEWORK_PATH" ]; then
      DYLD_FRAMEWORK_PATH="$fw_paths"
    else
      if ( echo ${DYLD_FRAMEWORK_PATH}|
           fgrep -v "${fw_paths}" >/dev/null ); then
        DYLD_FRAMEWORK_PATH="$fw_paths:$DYLD_FRAMEWORK_PATH"
      fi
    fi
    export DYLD_FRAMEWORK_PATH;;

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
      if ( echo ${LD_LIBRARY_PATH}| grep -v "${lib_paths}" >/dev/null ); then
	LD_LIBRARY_PATH="$lib_paths:$LD_LIBRARY_PATH"
      fi
    fi
    export LD_LIBRARY_PATH;;

  *)
    if [ -z "$LD_LIBRARY_PATH" ]; then
      LD_LIBRARY_PATH="$lib_paths"
    else
      if ( echo ${LD_LIBRARY_PATH}| grep -v "${lib_paths}" >/dev/null ); then
	LD_LIBRARY_PATH="$lib_paths:$LD_LIBRARY_PATH"
      fi
    fi
    export LD_LIBRARY_PATH;;

esac

unset host_os
unset lib_paths
unset fw_paths

