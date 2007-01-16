#! /bin/sh
#
#   Test for Objective-C precompiled headers
#
#   Copyright (C) 2007 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola.pero@meta-innovation.com>
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
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#

# Check if GCC supports precompiled headers for Objective-C or not.

# You should execute this shell scripts after setting the following
# environment variables:
#
#  CC, CFLAGS, CPPFLAGS, LDFLAGS, LIBS
#
# ./configure at the top-level will set them for us; you need to
# set them manually if you want to run the test manually.

# The script will execute and:
#   return 0 if gcc supports ObjC precompiled headers
#   return 1 if gcc does not

# It will also log everything it does to a log file that can be
# specified as the first argument to the script.  If there is
# no log file specified, ./log will be used.

# This is the file where everything will be logged
gs_logfile="$1"

if test "$gs_logfile" = ""; then
  gs_logfile="./log"
fi

# Clear logs
rm -f $gs_logfile

# Clear compilation results
rm -f gs_precomp_test.h.gch a.out *~

echo "** Environment" >>$gs_logfile 2>&1
echo " CC: $CC" >>$gs_logfile 2>&1
echo " CFLAGS: $CFLAGS" >>$gs_logfile 2>&1
echo " CPPFLAGS: $CPPFLAGS" >>$gs_logfile 2>&1
echo " LDFLAGS: $LDFLAGS" >>$gs_logfile 2>&1
echo " LIBS: $LIBS" >>$gs_logfile 2>&1
echo "" >>$gs_logfile 2>&1
echo " current directory: `pwd`" >>$gs_logfile 2>&1
echo " log file: $gs_logfile" >>$gs_logfile 2>&1
echo "" >>$gs_logfile 2>&1

# Get rid of '-x objective-c' in CFLAGS that we don't need and would
# prevent our '-x objective-c-headers' flag from working.
CFLAGS=`echo $CFLAGS | sed -e 's/-x objective-c//'`
echo " CFLAGS without -x objective-c: $CFLAGS" >>$gs_logfile 2>&1

echo "" >>$gs_logfile 2>&1

if test "$CC" = ""; then
  echo "CC is not set: failure" >>$gs_logfile 2>&1
  exit 1
fi

# Try to compile the file first
echo "** Compile the file without precompiled headers" >>$gs_logfile 2>&1
echo "$CC -o a.out $CFLAGS $CPPFLAGS $LDFLAGS $LIBS gs_precomp_test.m" >>$gs_logfile 2>&1
$CC -o a.out $CFLAGS $CPPFLAGS $LDFLAGS $LIBS gs_precomp_test.m >>$gs_logfile 2>&1
if test ! "$?" = "0"; then
  echo "Failure" >>$gs_logfile 2>&1
  rm -f a.out
  exit 1
fi
echo "Success" >>$gs_logfile 2>&1
echo "" >>$gs_logfile 2>&1

# Now try to preprocess the header
echo "** Preprocess the header" >>$gs_logfile 2>&1
echo "$CC -c -x objective-c-header $CFLAGS $CPPFLAGS $LDFLAGS gs_precomp_test.h" >>$gs_logfile 2>&1
$CC -x objective-c-header $CFLAGS $CPPFLAGS $LDFLAGS gs_precomp_test.h >>$gs_logfile 2>&1
if test ! "$?" = "0"; then
  echo "Failure" >>$gs_logfile 2>&1
  rm -f a.out gs_precomp_test.h.gch
  exit 1
fi
echo "Success" >>$gs_logfile 2>&1
echo "" >>$gs_logfile 2>&1

# Now try to compile again with the preprocessed header
echo "** Compile the file with precompiled headers" >>$gs_logfile 2>&1
echo "$CC -o a.out $CFLAGS $CPPFLAGS $LDFLAGS $LIBS gs_precomp_test.m" >>$gs_logfile 2>&1
$CC -o a.out $CFLAGS $CPPFLAGS $LDFLAGS $LIBS gs_precomp_test.m >>$gs_logfile 2>&1
if test ! "$?" = "0"; then
  echo "Failure" >>$gs_logfile 2>&1
  rm -f a.out gs_precomp_test.h.gch
  exit 1
fi
echo "Success" >>$gs_logfile 2>&1

# Everything looks OK.
exit 0
