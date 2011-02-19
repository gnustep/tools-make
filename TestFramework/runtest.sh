#!/bin/sh
#
#  run tests script for the GNUstep Testsuite
#
#  Copyright (C) 2005-2011 Free Software Foundation, Inc.
#
#  Written by:  Alexander Malmberg <alexander@malmberg.org>
#  Updated by:  Richard Frith-Macdonald <rfm@gnu.org>
#
#  This package is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public
#  License as published by the Free Software Foundation; either
#  version 3 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#
# Usage: ./runtest.sh test_name.m
#
# Compiles and runs the test test_name. Detailed logging should go to stdout;
# only summary information should go to stderr.

USEDEBUG=YES
# Argument checking
while test $# != 0
do
  gs_option=
  case $1 in
    --help | -h)
      echo "$0: Script to run a test a GNUstep testsuite program"
      echo "Usage: ./runtest.sh test_name.m"
      echo "Options:"
      echo "  --help	- Print help"
      echo
      exit 0
      ;;
    --debug | -d)	# ignore for backward compatibility
      ;;
    *)
      break
      ;;
  esac
  shift
done

if test x"$BASH_VERSION" = x
then
# In some shells the built in test command actually only implements a subset
# of the normally expected functionality (or is partially broken), so we
# define a function to call a real program to do the job.
test()
{
  /bin/test $@
}
fi

if test x$1 = x
then
  echo "ERROR: $0: No test given"
  exit 1
fi

if test $# != 1
then
  echo "ERROR: $0: Too many arguments (single test file name expected)"
  exit 1
fi

if test -e $1
then

  if test ! -f $1
  then
    echo "ERROR: $0: Argument ($1) is not the name of a regular file"
    exit 1
  fi

  if test ! -r $1
  then
    echo "ERROR: $0: Test file ($1) is not readable by you"
    exit 1
  fi

else
  echo "ERROR: $0: Test file ($1) does not exist"
  exit 1
fi

if test -z "$GNUSTEP_MAKEFILES"
then
  GNUSTEP_MAKEFILES=`gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null`
  if test -z "$GNUSTEP_MAKEFILES"
  then
    echo "You need to have GNUstep-make installed and set up."
    echo "Did you remember to source GNUstep.sh?"
  else
    . $GNUSTEP_MAKEFILES/GNUstep.sh
  fi
fi

TOP=$GNUSTEP_MAKEFILES/TestFramework

# Move to the test's directory.
DIR=`dirname $1`
if test ! -d $DIR
then
  echo "Unable to proceed ... $DIR is not a directory"
  exit 1
fi
cd $DIR
DIR=`pwd`

if test ! "$MAKE_CMD"
then
  MAKE_CMD=`gnustep-config --variable=GNUMAKE`
  $MAKE_CMD --version > /dev/null 2>&1
  if test $? != 0
  then
    MAKE_CMD=gmake
    $MAKE_CMD --version > /dev/null 2>&1
    if test $? != 0
    then
      MAKE_CMD=make
    fi
  fi
fi

NAME=`basename $1`

if test ! -f IGNORE
then

  # remove any leftover makefile from a previous test
  rm -f GNUmakefile.tmp

  # Remove the extension, if there is one. If there is no extension, add
  # .obj .
  TESTNAME=`echo $NAME | sed -e"s/^\(test^.]*\)$/\1.obj./;s/\.[^.]*//g"`

  # Check for a custom makefile template, if it exists use it.
  # Custom.mk is deprecated ... for backward compatibility only.
  if test -r GNUmakefile.template
  then
    TEMPLATE=GNUmakefile.template
  elif test -r Custom.mk
  then
    TEMPLATE=Custom.mk
  else
    TEMPLATE=$TOP/GNUmakefile.in
  fi

  # Create the GNUmakefile by filling in the name of the test,
  # the name of the file, the include directory, and the failfast
  # option if needed.
  if test "$GSTESTMODE" = "failfast"
  then
    sed -e "s/@TESTNAME@/$TESTNAME/;s/@FILENAME@/$NAME/;s/@FAILFAST@/-DFAILFAST=1/;s^@INCLUDEDIR@^$TOP^" < $TEMPLATE > GNUmakefile.tmp
  else
    sed -e "s/@TESTNAME@/$TESTNAME/;s/@FILENAME@/$NAME/;s/@FAILFAST@//;s^@INCLUDEDIR@^$TOP^" < $TEMPLATE > GNUmakefile.tmp
  fi

  rm -f GNUmakefile.bck
  if test -e GNUmakefile
  then
    mv GNUmakefile GNUmakefile.bck
  fi
  mv GNUmakefile.tmp GNUmakefile

  # Clean up to avoid contamination by previous tests. (Optimistically) assume
  # that	this will never fail in any interesting way.
  $MAKE_CMD clean >/dev/null 2>&1

  # Compile it. Redirect errors to stdout so it shows up in the log, but not
  # in the summary.
  $MAKE_CMD $MAKEFLAGS debug=yes 2>&1
  if test $? != 0
  then
    echo "Failed build:     $1" >&2
    if test "$GSTESTMODE" = "failfast"
    then
      mv GNUmakefile GNUmakefile.tmp
      if test -e GNUmakefile.bck
      then
        mv GNUmakefile.bck GNUmakefile
      fi
      exit 99
    fi
  else
    # We want aggressive memory checking.

    # Tell glibc to check for malloc errors, and to crash if it detects
    # any.
    MALLOC_CHECK_=2
    export MALLOC_CHECK

    # Tell GNUstep-base to check for messages sent to deallocated objects
    # and crash if it happens.
    NSZombieEnabled=YES
    CRASH_ON_ZOMBIE=YES
    export NSZombieEnabled CRASH_ON_ZOMBIE

    echo Running $1...
    # Run it. If it terminates abnormally, mark it as a crash (unless we have
    # a special file to mark it as being expected to abort).
    $MAKE_CMD -s test
    if test $? != 0
    then
      if test -r $NAME.abort
      then
        echo "Completed file:  $1" >&2
      else
        echo "Failed file:     $1 aborted without running all tests!" >&2
        if test "$GSTESTMODE" = "failfast"
        then
          mv GNUmakefile GNUmakefile.tmp
          if test -e GNUmakefile.bck
          then
            mv GNUmakefile.bck GNUmakefile
          fi
          exit 99
        fi
      fi
    else
      echo "Completed file:  $1" >&2
    fi
  fi

  # Restore any old makefile
  mv GNUmakefile GNUmakefile.tmp
  if test -e GNUmakefile.bck
  then
    mv GNUmakefile.bck GNUmakefile
  fi

  # Clean up any core dump.
  rm -f core
fi
