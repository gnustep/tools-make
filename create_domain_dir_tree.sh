#!/bin/sh
# create_domain_dir_tree.sh
#
# Copyright (C) 2002 Free Software Foundation, Inc.
#
# Author: Nicola Pero <n.pero@mi.flashnet.it>
# Date: October 2002
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

# Take a single argument - a directory name -, and create the GNUstep
# domain directory structure inside the directory.

# It is automatically called with argument ${GNUSTEP_SYSTEM_ROOT} when
# gnustep-make is installed; you can call it with argument
# ${GNUSTEP_LOCAL_ROOT} or ${GNUSTEP_NETWORK_ROOT} (or your own
# GNUstep user dir) if you need to create manually a GNUstep domain
# directory tree in there.

if [ -z "$*" ]; then
  echo "No arguments specified" >&2
  exit 0
fi

mydir=$(dirname "$0")
basepath="$1"

${mydir}/mkinstalldirs  "$basepath" \
		"$basepath"/Applications \
		"$basepath"/Libraries/${GNUSTEP_TARGET_LDIR} \
		"$basepath"/Libraries/Resources \
		"$basepath"/Libraries/Java \
		"$basepath"/Headers/${GNUSTEP_TARGET_DIR} \
		"$basepath"/Tools/${GNUSTEP_TARGET_LDIR} \
		"$basepath"/Tools/Resources \
		"$basepath"/Tools/Java \
		"$basepath"/Library/Bundles \
		"$basepath"/Library/Colors \
		"$basepath"/Library/Frameworks \
		"$basepath"/Library/PostScript \
		"$basepath"/Library/Services \
		"$basepath"/Documentation/Developer \
		"$basepath"/Documentation/User \
		"$basepath"/Documentation/info \
		"$basepath"/Documentation/man \
		"$basepath"/Developer/Palettes
