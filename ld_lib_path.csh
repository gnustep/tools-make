#!/bin/csh
#
#   ld_lib_path.csh
#
#   Set up the LD_LIBRARY_PATH (or similar env variable for your system)
#
#   Copyright (C) 1998 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
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
# operating system name.

if ( "$GNUSTEP_FLATTENED" == "" ) then
  set last_path_part="Libraries/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}/${LIBRARY_COMBO}"
  set tool_path_part="Libraries/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}"
else
  set last_path_part="Libraries"
  set tool_path_part="Libraries"
endif

set host_os=${GNUSTEP_HOST_OS}

if ( "${host_os}" == "" ) then
  set host_os=${1}
endif

switch ( "${host_os}" )

  case *nextstep4* :
    if ( $?DYLD_LIBRARY_PATH == 0 ) then
	setenv DYLD_LIBRARY_PATH "${GNUSTEP_USER_ROOT}/${last_path_part}:${GNUSTEP_USER_ROOT}/${tool_path_part}:${GNUSTEP_LOCAL_ROOT}/${last_path_part}:${GNUSTEP_LOCAL_ROOT}/${tool_path_part}:${GNUSTEP_NETWORK_ROOT}/${last_path_part}:${GNUSTEP_NETWORK_ROOT}/${tool_path_part}:${GNUSTEP_SYSTEM_ROOT}/${last_path_part}:${GNUSTEP_SYSTEM_ROOT}/${tool_path_part}"
    else
	setenv DYLD_LIBRARY_PATH "${GNUSTEP_USER_ROOT}/${last_path_part}:${GNUSTEP_USER_ROOT}/${tool_path_part}:${GNUSTEP_LOCAL_ROOT}/${last_path_part}:${GNUSTEP_LOCAL_ROOT}/${tool_path_part}:${GNUSTEP_NETWORK_ROOT}/${last_path_part}:${GNUSTEP_NETWORK_ROOT}/${tool_path_part}:${GNUSTEP_SYSTEM_ROOT}/${last_path_part}:${GNUSTEP_SYSTEM_ROOT}/${tool_path_part}:${DYLD_LIBRARY_PATH}"
    endif
    if ( $?additional_lib_paths == 1) then
      foreach dir (${additional_lib_paths})
	set additional="${additional}${dir}:"
      end
    endif

    if ( "${?additional}" == "1" ) then
       setenv DYLD_LIBRARY_PATH="${additional}${DYLD_LIBRARY_PATH}"
    endif
    breaksw

  case *hpux* :
    if ( $?SHLIB_PATH == 0 ) then
	setenv SHLIB_PATH "${GNUSTEP_USER_ROOT}/${last_path_part}:${GNUSTEP_USER_ROOT}/${tool_path_part}:${GNUSTEP_LOCAL_ROOT}/${last_path_part}:${GNUSTEP_LOCAL_ROOT}/${tool_path_part}:${GNUSTEP_NETWORK_ROOT}/${last_path_part}:${GNUSTEP_NETWORK_ROOT}/${tool_path_part}:${GNUSTEP_SYSTEM_ROOT}/${last_path_part}:${GNUSTEP_SYSTEM_ROOT}/${tool_path_part}"
    else
	setenv SHLIB_PATH "${GNUSTEP_USER_ROOT}/${last_path_part}:${GNUSTEP_USER_ROOT}/${tool_path_part}:${GNUSTEP_LOCAL_ROOT}/${last_path_part}:${GNUSTEP_LOCAL_ROOT}/${tool_path_part}:${GNUSTEP_NETWORK_ROOT}/${last_path_part}:${GNUSTEP_NETWORK_ROOT}/${tool_path_part}:${GNUSTEP_SYSTEM_ROOT}/${last_path_part}:${GNUSTEP_SYSTEM_ROOT}/${tool_path_part}:${SHLIB_PATH}"
    endif
    if ( $?additional_lib_paths == 1) then
      foreach dir (${additional_lib_paths})
	set additional="${additional}${dir}:"
      end
    endif

    if ( "${?additional}" == "1" ) then
       setenv SHLIB_PATH="${additional}${SHLIB_PATH}"
    endif

    if ( $?LD_LIBRARY_PATH == 0 ) then
	setenv LD_LIBRARY_PATH "${GNUSTEP_USER_ROOT}/${last_path_part}:${GNUSTEP_USER_ROOT}/${tool_path_part}:${GNUSTEP_LOCAL_ROOT}/${last_path_part}:${GNUSTEP_LOCAL_ROOT}/${tool_path_part}:${GNUSTEP_NETWORK_ROOT}/${last_path_part}:${GNUSTEP_NETWORK_ROOT}/${tool_path_part}:${GNUSTEP_SYSTEM_ROOT}/${last_path_part}:${GNUSTEP_SYSTEM_ROOT}/${tool_path_part}"
    else
	setenv LD_LIBRARY_PATH "${GNUSTEP_USER_ROOT}/${last_path_part}:${GNUSTEP_USER_ROOT}/${tool_path_part}:${GNUSTEP_LOCAL_ROOT}/${last_path_part}:${GNUSTEP_LOCAL_ROOT}/${tool_path_part}:${GNUSTEP_NETWORK_ROOT}/${last_path_part}:${GNUSTEP_NETWORK_ROOT}/${tool_path_part}:${GNUSTEP_SYSTEM_ROOT}/${last_path_part}:${GNUSTEP_SYSTEM_ROOT}/${tool_path_part}:${LD_LIBRARY_PATH}"
    endif

    if ( $?additional_lib_paths == 1) then
      foreach dir (${additional_lib_paths})
	set additional="${additional}${dir}:"
      end
    endif

    if ( "${?additional}" == "1" ) then
       setenv LD_LIBRARY_PATH="${additional}${LD_LIBRARY_PATH}"
    endif
    breaksw

  case * :
    if ( $?LD_LIBRARY_PATH == 0 ) then
	setenv LD_LIBRARY_PATH "${GNUSTEP_USER_ROOT}/${last_path_part}:${GNUSTEP_USER_ROOT}/${tool_path_part}:${GNUSTEP_LOCAL_ROOT}/${last_path_part}:${GNUSTEP_LOCAL_ROOT}/${tool_path_part}:${GNUSTEP_NETWORK_ROOT}/${last_path_part}:${GNUSTEP_NETWORK_ROOT}/${tool_path_part}:${GNUSTEP_SYSTEM_ROOT}/${last_path_part}:${GNUSTEP_SYSTEM_ROOT}/${tool_path_part}"
    else
	setenv LD_LIBRARY_PATH "${GNUSTEP_USER_ROOT}/${last_path_part}:${GNUSTEP_USER_ROOT}/${tool_path_part}:${GNUSTEP_LOCAL_ROOT}/${last_path_part}:${GNUSTEP_LOCAL_ROOT}/${tool_path_part}:${GNUSTEP_NETWORK_ROOT}/${last_path_part}:${GNUSTEP_NETWORK_ROOT}/${tool_path_part}:${GNUSTEP_SYSTEM_ROOT}/${last_path_part}:${GNUSTEP_SYSTEM_ROOT}/${tool_path_part}:${LD_LIBRARY_PATH}"
    endif
    if ( $?additional_lib_paths == 1) then
      foreach dir (${additional_lib_paths})
	set additional="${additional}${dir}:"
      end
    endif

    if ( "${?additional}" == "1" ) then
       setenv LD_LIBRARY_PATH="${additional}${LD_LIBRARY_PATH}"
    endif
    breaksw

endsw

unset tool_path_part last_path_part host_os additional dir lib_paths

if ( $?GUILE_LOAD_PATH == 0 ) then
    setenv GUILE_LOAD_PATH "${GNUSTEP_USER_ROOT}/Libraries/Guile:${GNUSTEP_LOCAL_ROOT}/Libraries/Guile:${GNUSTEP_NETWORK_ROOT}/Libraries/Guile:${GNUSTEP_SYSTEM_ROOT}/Libraries/Guile"
else
    setenv GUILE_LOAD_PATH "${GNUSTEP_USER_ROOT}/Libraries/Guile:${GNUSTEP_LOCAL_ROOT}/Libraries/Guile:${GNUSTEP_NETWORK_ROOT}/Libraries/Guile:${GNUSTEP_SYSTEM_ROOT}/Libraries/Guile:${GUILE_LOAD_PATH}"
endif
