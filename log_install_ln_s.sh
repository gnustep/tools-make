#!/bin/sh
#
#   log-install_ln_s.sh
#
#   Shell script accepting arguments in the way ln -s traditionally
#   does, but logging the new symbolic link into to the file $FILE_LIST
#   rather than really creating it
#
#   Copyright (C) 2001 Free Software Foundation, Inc.
#
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

if [ -z "$FILE_LIST" ]; then
  echo "error - FILE_LIST shell variable not set"
  exit 1
fi

link_file=""

while test $# -gt 0; do
  case $1 in
    # ignore -f, -v:
    -[fv])  ;; 
    # discard everything but the last argument 
    *) link_file=$1 ;;
  esac
  shift
done

if [ "$link_file" = "" ]; then
  echo "error - no link file specified"
  exit 1
fi

#
# Now, `link_link' is the link to be created, add
# it to the file list
#
echo `pwd`/"$link_file" >> "$FILE_LIST" 



