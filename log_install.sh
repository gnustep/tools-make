#!/bin/sh
#
#   log-install.sh
#
#   Shell script accepting arguments in the way install traditionally
#   does, but logging what has to be installed to the file $FILE_LIST
#   rather than really installing it
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

last_read=""
src=""
dst=""

while test $# -gt 0; do
  case $1 in
    # ignore -c, -s:
    -[cs])  ;; 
    # ignore -m, -o, -g and skip their argument:
    -[mog]) shift;; 
    # record everything but the last argument as source
    *) if [ "$last_read" = "" ]; then 
         last_read=$1 
       else # not the first file in the list
         src="$src $last_read"
         last_read=$1
       fi
  esac
  shift
done

# the last one is the destionation
dst=$last_read

if [ "$last_read" = "" ]; then
  echo "error - no input file specified"
  exit 1
fi

if [ "$src" = "" ]; then
  echo "error - no destination specified"
  exit 1
fi

#
# Now, `dst' is the destination, and `src' is the list of source files
#

# If destination is a directory, append the input filename; 
if [ -d $dst ]; then
  for file in $src; do
    echo "$dst"/`basename $file` >> "$FILE_LIST" ;
  done
else
# otherwise, simply output the destination
  echo "$dst" >> "$FILE_LIST" 
fi





