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
#   Rewrite: Richard Frith-Macdoanld <richard@brainstorm.co.uk>
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
for dir in $GNUSTEP_PATHPREFIX_LIST; do

  # prepare the path_fragment for this dir
  if [ -z "$GNUSTEP_FLATTENED" ]; then
    path_fragment="$dir/Libraries/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/$LIBRARY_COMBO:$dir/Libraries/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS"
  else
    path_fragment="$dir/Libraries"
  fi

  # Append the path_fragment to lib_paths
  if [ -z "$lib_paths" ]; then
    lib_paths="$path_fragment"
  else
    lib_paths="$lib_paths:$path_fragment"
  fi

  unset path_fragment

done
IFS="$tmp_IFS"
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

#
# Setup path for loading guile modules too.
#
old_IFS="$IFS"
IFS=:
guile_paths=
for dir in $GNUSTEP_PATHPREFIX_LIST; do

  if [ -z "$guile_paths" ]; then
    guile_paths="$dir/Libraries/Guile"
  else
    guile_paths="$guile_paths:$dir/Libraries/Guile"
  fi

done
IFS="$tmp_IFS"
unset old_IFS
unset dir

if [ -z "$GUILE_LOAD_PATH" ]; then
  GUILE_LOAD_PATH="$guile_paths"
else
  if ( echo ${GUILE_LOAD_PATH}| grep -v "${guile_paths}" >/dev/null ); then
    GUILE_LOAD_PATH="$guile_paths:$GUILE_LOAD_PATH"
  fi
fi
export GUILE_LOAD_PATH
unset guile_paths
