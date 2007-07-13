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
#   License along with this library; see the file COPYING.
#   If not, write to the Free Software Foundation,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#

# The modern version of this file basically expects you to execute it
# inside GNUstep.sh.  If not, you need to have at least the
# GNUSTEP_MAKEFILES, GNUSTEP_HOST_*, GNUSTEP_SYSTEM_LIBRARIES,
# GNUSTEP_LOCAL_LIBRARIES, etc.  GNUSTEP_SYSTEM_LIBRARY,
# GNUSTEP_LOCAL_LIBRARY, etc. variables defined.

# FIXME/TODO: Update all callers to source GNUstep.sh and not this file.

# This file is sourced.  This means extra care is needed when changing
# it.  Please read the comments on GNUstep.sh.in before touching it.

lib_paths=
fw_paths=

# Determine the library paths
GNUSTEP_LIBRARIES_PATHLIST=`$GNUSTEP_MAKEFILES/print_unique_pathlist.sh "$GNUSTEP_USER_LIBRARIES" "$GNUSTEP_LOCAL_LIBRARIES" "$GNUSTEP_NETWORK_LIBRARIES" "$GNUSTEP_SYSTEM_LIBRARIES" $fixup_paths`

if [ "$GNUSTEP_IS_FLATTENED" = "yes" ]; then
  lib_paths="$GNUSTEP_LIBRARIES_PATHLIST"
else
  old_IFS="$IFS"
  IFS=:
    for dir in $GNUSTEP_LIBRARIES_PATHLIST; do

      # prepare the path_fragment for libraries and this dir
      path_fragment="$dir/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/$LIBRARY_COMBO:$dir/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS"

      # Append the path_fragment to lib_paths
      if [ -z "$lib_paths" ]; then
        lib_paths="$path_fragment"
      else
        lib_paths="$lib_paths:$path_fragment"
      fi

      unset path_fragment
    done
  IFS="$old_IFS"
  unset old_IFS
  unset dir
fi

unset GNUSTEP_LIBRARIES_PATHLIST

# Determine the framework paths
fw_paths=`$GNUSTEP_MAKEFILES/print_unique_pathlist.sh "$GNUSTEP_USER_LIBRARY/Frameworks" "$GNUSTEP_LOCAL_LIBRARY/Frameworks" "$GNUSTEP_NETWORK_LIBRARY/Frameworks" "$GNUSTEP_SYSTEM_LIBRARY/Frameworks" $fixup_paths`


case "$GNUSTEP_HOST_OS" in

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
    
# The code below has been temporarily removed, because...
# Frameworks in GNUstep-make are supported by creating a link like
# 
#   Libraries/libMyFramework.dylib ->
#      Frameworks/MyFramework.framework/Versions/Current/libMyFramework.dylib,
#
# to mitigate the fact that FSF GCC does not support a -framework flag.
#
# On Darwin, however, we partially emulate -framework by setting the
# "install_name" to the framework name during linking. The dynamic
# linker (dyld) is smart enough to find the framework under this name,
# but only if DYLD_FRAMEWORK_PATH is set (unless we set the
# "install_name" to an absolute path, which we don't). We'd really like
# to fully support -framework, though.
#
# Use otool -L MyApplication.app/MyApplication, for instance, to see
# how the shared libraries/frameworks are linked.
#
#    if [ "$LIBRARY_COMBO" = "apple-apple-apple" -o \
#         "$LIBRARY_COMBO" = "apple" ]; then
    
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

unset lib_paths
unset fw_paths

