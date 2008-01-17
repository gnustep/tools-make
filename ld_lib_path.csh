#   This file must be sourced inside csh using: source
#
#   ld_lib_path.csh
#
#   Set up the LD_LIBRARY_PATH (or similar env variable for your system)
#
#   Copyright (C) 1998-2007 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#   Author:  Nicola Pero <nicola.pero@meta-innovation.com>
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 3
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.
#   If not, write to the Free Software Foundation,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#

if ( "$GNUSTEP_IS_FLATTENED" == "yes" ) then
  set lib_paths=`$GNUSTEP_MAKEFILES/print_unique_pathlist.sh "$GNUSTEP_USER_LIBRARIES" "$GNUSTEP_LOCAL_LIBRARIES" "$GNUSTEP_NETWORK_LIBRARIES" "$GNUSTEP_SYSTEM_LIBRARIES" $fixup_paths`
else
  set lib_paths=`$GNUSTEP_MAKEFILES/print_unique_pathlist.sh "$GNUSTEP_USER_LIBRARIES/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/$LIBRARY_COMBO" "$GNUSTEP_USER_LIBRARIES/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS" "$GNUSTEP_LOCAL_LIBRARIES/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/$LIBRARY_COMBO" "$GNUSTEP_LOCAL_LIBRARIES/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS" $fixup_paths`

 set lib_paths="$lib_paths":`$GNUSTEP_MAKEFILES/print_unique_pathlist.sh "$GNUSTEP_NETWORK_LIBRARIES/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/$LIBRARY_COMBO" "$GNUSTEP_NETWORK_LIBRARIES/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS" "$GNUSTEP_SYSTEM_LIBRARIES/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/$LIBRARY_COMBO" "$GNUSTEP_SYSTEM_LIBRARIES/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS" $fixup_paths`:
endif

set fw_paths=`$GNUSTEP_MAKEFILES/print_unique_pathlist.sh "$GNUSTEP_USER_LIBRARY/Frameworks" "$GNUSTEP_LOCAL_LIBRARY/Frameworks" "$GNUSTEP_NETWORK_LIBRARY/Frameworks" "$GNUSTEP_SYSTEM_LIBRARY/Frameworks" $fixup_paths`

switch ( "${GNUSTEP_HOST_OS}" )

  case *nextstep4* :
    if ( $?DYLD_LIBRARY_PATH == 0 ) then
	setenv DYLD_LIBRARY_PATH "${lib_paths}"
    else if ( { (echo "${DYLD_LIBRARY_PATH}" | fgrep -v "${lib_paths}" >/dev/null) } ) then
	setenv DYLD_LIBRARY_PATH "${lib_paths}:${DYLD_LIBRARY_PATH}"
    endif
    breaksw

  case *darwin* :
    if ( $?DYLD_LIBRARY_PATH == 0 ) then
	setenv DYLD_LIBRARY_PATH "${lib_paths}"
    else if ( { (echo "${DYLD_LIBRARY_PATH}" | fgrep -v "${lib_paths}" >/dev/null) } ) then
	setenv DYLD_LIBRARY_PATH "${lib_paths}:${DYLD_LIBRARY_PATH}"
    endif
    
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

    if ( $?DYLD_FRAMEWORK_PATH == 0 ) then
      setenv DYLD_FRAMEWORK_PATH "${fw_paths}"
    else if ( { (echo "${DYLD_FRAMEWORK_PATH}" | fgrep -v "${fw_paths}" >/dev/null) } ) then
      setenv DYLD_FRAMEWORK_PATH "${fw_paths}:${DYLD_FRAMEWORK_PATH}"
    endif

    breaksw

  case *hpux* :
    if ( $?SHLIB_PATH == 0 ) then
	setenv SHLIB_PATH "${lib_paths}"
    else if ( { (echo "${SHLIB_PATH}" | fgrep -v "${lib_paths}" >/dev/null) } ) then
	setenv SHLIB_PATH "${lib_paths}:${SHLIB_PATH}"
    endif

    if ( $?LD_LIBRARY_PATH == 0 ) then
	setenv LD_LIBRARY_PATH "${lib_paths}"
    else if ( { (echo "${LD_LIBRARY_PATH}" | fgrep -v "${lib_paths}" >/dev/null) } ) then
	setenv LD_LIBRARY_PATH "${lib_paths}:${LD_LIBRARY_PATH}"
    endif

    breaksw

  case * :
    if ( $?LD_LIBRARY_PATH == 0 ) then
	setenv LD_LIBRARY_PATH "${lib_paths}"
    else if ( { (echo "${LD_LIBRARY_PATH}" | fgrep -v "${lib_paths}" >/dev/null) } ) then
	setenv LD_LIBRARY_PATH "${lib_paths}:${LD_LIBRARY_PATH}"
    endif

    breaksw

endsw

unset tool_path_part last_path_part host_os dir lib_paths fw_paths

