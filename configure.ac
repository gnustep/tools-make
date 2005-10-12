#
#   configure.ac
#
#   Copyright (C) 1997-2004 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#	     Ovidiu Predescu <ovidiu@net-community.com>
#   Rewrite: Adam Fedor <fedor@gnu.org>
#            Nicola Pero <n.pero@mi.flashnet.it>
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
AC_INIT
AC_PREREQ(2.57)
AC_CONFIG_SRCDIR([application.make])
AC_CONFIG_HEADER(config.h)

#--------------------------------------------------------------------
# Setup the library combination
#--------------------------------------------------------------------
targetArgument=${target}
AC_PROG_CC
AC_PROG_CPP
AC_CANONICAL_TARGET([])

AC_MSG_CHECKING(for library combo)
AC_ARG_WITH(library-combo,[
--with-library-combo		Define the default library combination
],
ac_cv_library_combo=$withval,
ac_cv_library_combo=$ac_cv_library_combo
)

if test "$ac_cv_library_combo" = ""; then
  case "$host_os" in
    darwin*)   ac_cv_library_combo=apple-apple-apple ;;
    nextstep4) ac_cv_library_combo=nx-nx-nx          ;;
    openstep4) ac_cv_library_combo=nx-nx-nx          ;;
    *)         ac_cv_library_combo=gnu-gnu-gnu       ;;
  esac
fi

case "$ac_cv_library_combo" in
  apple) ac_cv_library_combo=apple-apple-apple ;;
  gnu)   ac_cv_library_combo=gnu-gnu-gnu ;;
  nx)    ac_cv_library_combo=nx-nx-nx ;;
esac

AC_SUBST(ac_cv_library_combo)
AC_MSG_RESULT($ac_cv_library_combo)

OBJC_RUNTIME_LIB=`echo $ac_cv_library_combo | awk -F- '{print $1}'`

#--------------------------------------------------------------------
# Check if we are using Apple cc
#--------------------------------------------------------------------
cc_cppprecomp=0
cc_byndle=0
AC_MSG_CHECKING([for apple compiler flags])
cc_cppprecomp=`${CC} -no-cpp-precomp 2>&1 | grep -c "unrecognized"`
cc_bundle=`${CC} -bundle 2>&1 | grep -c "couldn"`
# 0 means we have the flag
if test $cc_cppprecomp = 0; then
  cc_cppprecomp=yes
else
  cc_cppprecomp=no
fi
if test $cc_bundle = 0; then
  cc_bundle=yes
else
  cc_bundle=no
fi
AC_MSG_RESULT($cc_bundle)
AC_SUBST(cc_cppprecomp)
AC_SUBST(cc_bundle)

#--------------------------------------------------------------------
# specific target_os options
#--------------------------------------------------------------------
case "$target_os" in
  freebsd* | openbsd* )	
	        INCLUDES="$INCLUDES -I/usr/local/include"
		LIB_DIR="$LIB_DIR -L/usr/local/lib";;
  netbsd*)	INCLUDES="$INCLUDES -I/usr/pkg/include"
		LIB_DIR="$LIB_DIR -Wl,-R/usr/pkg/lib -L/usr/pkg/lib";;
esac

#--------------------------------------------------------------------
# Determine the host, build, and target systems
#--------------------------------------------------------------------
case $host_os in
  *cygwin*  ) CYGWIN=yes;;
  *mingw32* ) MINGW32=yes;;
          * ) MINGW32=no
              CYGWIN=no;;
esac
AC_SUBST(CYGWIN)

AC_EXEEXT
AC_OBJEXT
if test "$MINGW32" = yes; then
  echo "hosted on mingw32 .."
  export INSTALL=install
  export SHELL=sh
  export CC=${CC:-gcc}
  export AR=${AR:-ar}
  export RANLIB=${RANLIB:-ranlib}
  export DLLTOOL=${DLLTOOL:-dlltool}
elif test "$CYGWIN" = yes; then
  echo "hosted on cygwin .."
  export CC=${CC:-gcc}
  export AR=${AR:-ar}
  export RANLIB=${RANLIB:-ranlib}
  export DLLTOOL=${DLLTOOL:-dlltool}
fi

#--------------------------------------------------------------------
# Find the binary and compile tools
#--------------------------------------------------------------------
if test "x$target" != "x$host"; then
  echo "cross compiling from $host to $target .."
  cross_compiling="yes"
  AC_CHECK_PROG(CC,      "${targetArgument}-gcc",     dnl
                         "${targetArgument}-gcc",     gcc)
  AC_CHECK_PROG(RANLIB,  "${targetArgument}-ranlib",  dnl
                         "${targetArgument}-ranlib",  ranlib)
  AC_CHECK_PROG(AR,      "${targetArgument}-ar",      dnl
                         "${targetArgument}-ar",      ar)
  AC_CHECK_PROG(DLLTOOL, "${targetArgument}-dlltool", dnl
                         "${targetArgument}-dlltool", dlltool)
else
  AC_CHECK_PROG(AR,      ar,      ar)
  AC_CHECK_PROG(DLLTOOL, dlltool, dlltool)
  AC_PROG_RANLIB
fi

AC_PROG_INSTALL
AC_PROG_LN_S([])

AC_CHECK_PROGS(TAR, gnutar gtar, tar)
AC_ARG_WITH(tar,
[--with-tar                      Set the name of the tar program to use],
  TAR="$withval",)

AC_CHECK_PROG(CHOWN, chown, chown, none)
if test "$MINGW32" = no; then
  if test "$CHOWN" = "none"; then
    AC_MSG_ERROR("Could not find chown.");
  fi
fi

#-------------------------------------------------------------------
# GNUstep specific options follow
#-------------------------------------------------------------------

#---------------------------------------------------------------------
# Location of the GNUstep.conf config file (--with-config-file)
#---------------------------------------------------------------------
AC_MSG_CHECKING([for the location of GNUstep configuration file])
AC_ARG_WITH(config-file,
  [--with-config-file=PATH  path to GNUstep configuration file],
  gnustep_config_file="$withval", gnustep_config_file="no")
if test "$gnustep_config_file" = no; then
  if test ! "$GNUSTEP_CONFIG_FILE" = ""; then
    gnustep_config_file="$GNUSTEP_CONFIG_FILE";
  else
    case "$target_os" in
      freebsd* | openbsd* ) gnustep_config_file=/usr/etc/GNUstep.conf ;;
      netbsd* )             gnustep_config_file=/usr/pkg/etc/GNUstep.conf ;;
      *)	            gnustep_config_file=/etc/GNUstep/GNUstep.conf;;
    esac
  fi
fi
AC_MSG_RESULT($gnustep_config_file);
AC_SUBST(gnustep_config_file)

#---------------------------------------------------------------------
# Now read/import the existing configuration file, if any
#---------------------------------------------------------------------

# Reading/importing the existing configuration file is good as a
# default because it means that you don't have to type in your
# GNUSTEP_SYSTEM_ROOT, GNUSTEP_LOCAL_ROOT, etc. settings every time
# you configure gnustep-make.

# It can be annoying in certain cases though; this option lets you
# turn it off
AC_MSG_CHECKING([if we should import an existing GNUstep configuration file])
AC_ARG_ENABLE(importing-config-file, 
[--disable-importing-config-file		Disable importing the existing GNUstep configuration file], 
  ac_cv_importing_config_file=$enableval,
  ac_cv_importing_config_file="yes")

# If importing the file is disabled, don't import it.
if test "$ac_cv_importing_config_file" = "no"; then
  AC_MSG_RESULT([no: disabled from the command-line])
else

 # Check that the file exists
 if test ! -f "$gnustep_config_file"; then
  AC_MSG_RESULT([no: file "$gnustep_config_file" does not exist])
 else
  AC_MSG_RESULT([yes: trying to import "$gnustep_config_file"])
  AC_MSG_NOTICE([If this fails, please run configure again with the --disable-importing-config-file option])
  . "$gnustep_config_file"
 fi
fi

#--------------------------------------------------------------------
# Important - from now on, any variable that is set in the
# configuration file (eg, GNUSTEP_SYSTEM_ROOT) could already have a
# value that we have imported from the previous file.  ./configure
# command line options should override those values, but otherwise we
# should keep them!
#
# Those could also be env variables, which is really a backwards
# compatibility hack that won't be kept in the future.
#--------------------------------------------------------------------

#--------------------------------------------------------------------
# Process --prefix
#--------------------------------------------------------------------

#
# In practice,
#
# ./configure --prefix=/usr/GNUstep
#
# is equivalent to:
#
# ./configure --with-system-root=/usr/GNUstep/System
#             --with-local-root=/usr/GNUstep/Local
#
# (TODO finish corner details)

#--------------------------------------------------------------------
# The GNUstep root directory.
# The user should have the GNUSTEP_SYSTEM_ROOT environment variable
# defined, but if not then we have a global default.
# Also test for the C: directory, which means we're on Windows
#--------------------------------------------------------------------
AC_MSG_CHECKING([for root of GNUstep installation to use (if any)])
AC_PREFIX_DEFAULT(`if test "x$GNUSTEP_SYSTEM_ROOT" = "x"; then 
  if test -d C: ; then
    echo C:/GNUstep;
  else
    echo /usr/GNUstep ;
  fi
else
  echo "$GNUSTEP_SYSTEM_ROOT" ;
fi`)
if test "x$prefix" = "xNONE"; then
  prefix="$ac_default_prefix" ;
fi
#
# GNUSTEP_ROOT is only used to build GNUSTEP_SYSTEM_ROOT /
# GNUSTEP_LOCAL_ROOT if no --with-system-root= / --with-local-root=
# option is used.
#
GNUSTEP_ROOT="$prefix"
if test "x`basename $prefix`" = xSystem; then
  GNUSTEP_ROOT=`dirname $prefix`
else
  if test "x$prefix" = "x/"; then
    prefix=/System
  else
    prefix="$prefix/System"
  fi
fi
AC_MSG_RESULT($GNUSTEP_ROOT)

#--------------------------------------------------------------------
# Process --with-system-root
#--------------------------------------------------------------------
AC_MSG_CHECKING(for GNUSTEP_SYSTEM_ROOT to use)
AC_ARG_WITH(system-root,
[--with-system-root
    Set the GNUSTEP_SYSTEM_ROOT directory.  Use this option if you want 
to have the GNUSTEP_SYSTEM_ROOT directory in a non-standard place.  Example:
--with-system-root=/usr/GNUstep/System
],
GNUSTEP_SYSTEM_ROOT="$withval",
if test "$GNUSTEP_SYSTEM_ROOT" = ""; then 
  GNUSTEP_SYSTEM_ROOT="$GNUSTEP_SYSROOT/System"
fi
)
AC_MSG_RESULT($GNUSTEP_SYSTEM_ROOT)
AC_SUBST(GNUSTEP_SYSTEM_ROOT)

#--------------------------------------------------------------------
# Process --with-local-root
#--------------------------------------------------------------------
AC_MSG_CHECKING(for GNUSTEP_LOCAL_ROOT to use)
AC_ARG_WITH(local-root,
[--with-local-root
    Set the GNUSTEP_LOCAL_ROOT directory.  Use this option if you want 
to have the GNUSTEP_LOCAL_ROOT directory in a non-standard place.  Example:
--with-local-root=/usr/local/GNUstep/Local
],
GNUSTEP_LOCAL_ROOT="$withval",
if test "$GNUSTEP_LOCAL_ROOT" = ""; then 
  GNUSTEP_LOCAL_ROOT="$GNUSTEP_ROOT/Local"
fi
)
AC_MSG_RESULT($GNUSTEP_LOCAL_ROOT)
AC_SUBST(GNUSTEP_LOCAL_ROOT)

#--------------------------------------------------------------------
# Process --with-network-root
#--------------------------------------------------------------------
AC_MSG_CHECKING(for GNUSTEP_NETWORK_ROOT to use)
AC_ARG_WITH(network-root,
[--with-network-root
    Set the GNUSTEP_NETWORK_ROOT directory.  Use this option if you want 
to have the GNUSTEP_NETWORK_ROOT directory.  Example:
--with-network-root=/usr/local/GNUstep/Network
],
GNUSTEP_NETWORK_ROOT="$withval",
# By default we disable network root, by setting GNUSTEP_NETWORK_ROOT
# to be the same as GNUSTEP_LOCAL_ROOT.  GNUSTEP_NETWORK_ROOT is very
# rarely used, and most users prefer simpler systems with shorter
# paths and shorter command lines.  To turn on GNUSTEP_NETWORK_ROOT
# again, you can use the --with-network-root=xxx option; pass
# something like --with-network-root=/usr/GNUstep/Network on the
# configure command line.
if test "$GNUSTEP_NETWORK_ROOT" = ""; then 
  GNUSTEP_NETWORK_ROOT="$GNUSTEP_LOCAL_ROOT"
fi
)
AC_MSG_RESULT($GNUSTEP_NETWORK_ROOT)
AC_SUBST(GNUSTEP_NETWORK_ROOT)

#--------------------------------------------------------------------
# Process --with-defaults-root and --with-user-root
#--------------------------------------------------------------------
AC_MSG_CHECKING(for GNUSTEP_USER_ROOT to use)
AC_ARG_WITH(user-root,
[--with-user-root
    Set the GNUSTEP_USER_ROOT directory for all users.  '~' is allowed
    at the beginning to mean the user's home directory.  Use this
    option if you want to have the GNUSTEP_USER_ROOT directory in a non
    default place for all users.
    Example: --with-user-root='~/gnustep'
],
GNUSTEP_USER_ROOT="$withval",
# The default is to have user roots in ~/GNUstep
if test "$GNUSTEP_USER_ROOT" = ""; then 
  GNUSTEP_USER_ROOT="~/GNUstep"
fi
)
AC_MSG_RESULT($GNUSTEP_USER_ROOT)
AC_SUBST(GNUSTEP_USER_ROOT)

#--------------------------------------------------------------------
# Setting up GNUSTEP_MAKEFILES
#--------------------------------------------------------------------
AC_MSG_CHECKING(for GNUSTEP_MAKEFILES to use)
if test "$GNUSTEP_MAKEFILES" = ""; then 
  GNUSTEP_MAKEFILES="$GNUSTEP_SYSTEM_ROOT/Library/Makefiles"
fi
AC_SUBST(GNUSTEP_MAKEFILES)
AC_MSG_RESULT($GNUSTEP_MAKEFILES)

#--------------------------------------------------------------------
# Setting up the install-sh script
#--------------------------------------------------------------------

# HOST_INSTALL is the name of the install program in config.make so set it up
# to point to the install-sh script in the GNUstep tree if no system install is
# found.
AC_SUBST(HOST_INSTALL)
if test "$INSTALL" = "$ac_install_sh"; then
  HOST_INSTALL="$GNUSTEP_MAKEFILES/$INSTALL"
else
  HOST_INSTALL="$INSTALL"
fi

#--------------------------------------------------------------------
# Is the system flattened?
#--------------------------------------------------------------------
AC_MSG_CHECKING(for flattened directory structure)
AC_ARG_ENABLE(flattened, 
[--disable-flattened		Disable flattened directory structure], 
  ac_cv_flattened=$enableval,
  ac_cv_flattened="undefined")

if test "$ac_cv_flattened" = "no"; then
  GNUSTEP_FLATTENED=;
else
  GNUSTEP_FLATTENED=yes;
fi
AC_SUBST(GNUSTEP_FLATTENED)

if test "$GNUSTEP_FLATTENED" = "yes"; then
  AC_MSG_RESULT(yes);
else
  AC_MSG_RESULT(no);
fi


#--------------------------------------------------------------------
# Is the system multi-platform?
#--------------------------------------------------------------------
#
# Multi-platform means that GNUstep.sh will determine the host
# platform (by running config.guess) each time that it is sourced.
# This is good if you are sharing your GNUstep.sh across your network
# (for example, mounting the makefiles via NFS), but it requires you
# to be able to run config.guess on your machine(s), which usually
# requires a development environment (compiler, libc etc).
#
# The default instead is not using multi-platform, which means the
# local host os, cpu and version is hardcoded in GNUstep.sh.  This
# works nicely for a single machine using this gnustep-make
# installation, and it works even if you don't have development
# packages (gcc, binutils, libc-dev etc) installed.  We had to make
# this the default after end-users (with no development packages
# installed) complained that binary packages wouldn't work (and the
# reason turned out to be that GNUstep.sh was running config.guess
# which was returning the wrong platform because the development
# tools needed/used to determine the platform were not available).
#
# Unless you know what you are doing, stick with the default, which is
# also much faster when sourcing GNUstep.sh.
#
AC_ARG_ENABLE(multi-platform, 
[--enable-multi-platform		Use run time multi-platform support], 
  ac_cv_multi_platform=$enableval,
  ac_cv_multi_platform="undefined")

if test "$ac_cv_multi_platform" = "yes"; then
  GNUSTEP_MULTI_PLATFORM=yes;
else
  GNUSTEP_MULTI_PLATFORM=;
fi
AC_SUBST(GNUSTEP_MULTI_PLATFORM)

#--------------------------------------------------------------------
# Build backend bundles (on by default)
#--------------------------------------------------------------------
AC_ARG_ENABLE(backend-bundle, [
--disable-backend-bundle	Compile gui backend as a library], 
  ac_cv_backend=$enableval,  
  ac_cv_backend="yes")

if test "$ac_cv_backend" = "yes"; then
  BACKEND_BUNDLE=yes;
else
  BACKEND_BUNDLE=;
fi
AC_SUBST(BACKEND_BUNDLE)

#--------------------------------------------------------------------
# Miscellaneous flags and setup
#--------------------------------------------------------------------
# Strip '-g' off of CFLAGS, since debug=yes adds that anyway
CFLAGS=`echo $CFLAGS | sed -e 's/-g //'`

# Set location of GNUstep dirs for later use
if test "$GNUSTEP_FLATTENED" = yes; then
  GNUSTEP_LDIR="$GNUSTEP_SYSTEM_ROOT/Library/Libraries"
  GNUSTEP_HDIR="$GNUSTEP_SYSTEM_ROOT/Library/Headers"
else
  clean_target_os=`$srcdir/clean_os.sh $target_os`
  clean_target_cpu=`$srcdir/clean_cpu.sh $target_cpu`
  obj_dir="$clean_target_cpu/$clean_target_os"
  GNUSTEP_LDIR="$GNUSTEP_SYSTEM_ROOT/Library/Libraries/$obj_dir"
  GNUSTEP_HDIR="$GNUSTEP_SYSTEM_ROOT/Library/Headers/${ac_cv_library_combo}"
fi

# Check to see if the libobjc library is in our GNUSTEP_SYSTEM_ROOT.
# If so, there are probably other libraries that we want there also, so
# leave the proper includes in CPPFLAGS and LDFLAGS
AC_MSG_CHECKING(for custom shared objc library)
AC_CACHE_VAL(gs_cv_objc_libdir,
[dnl
gs_cv_objc_libdir=NONE
if test -f "$GNUSTEP_HDIR/objc/objc.h"; then
  if test -f "$GNUSTEP_LDIR/libobjc.a" -o -f "$GNUSTEP_LDIR/libobjc.so" -o -f "$GNUSTEP_LDIR/libobjc.dll.a"; then
    gs_cv_objc_libdir="$GNUSTEP_LDIR"
  else
    gs_cv_objc_libdir=NONE
  fi
fi
#gcc_shared_libobjc=`gcc -print-file-name=libobjc.so`
#if test -f "$gcc_shared_libobjc"; then
#  gs_cv_objc_libdir=`dirname $gcc_shared_libobjc`
#fi
])
AC_MSG_RESULT($gs_cv_objc_libdir)

# The following are needed to compile the test programs
if test "$gs_cv_objc_libdir" = "$GNUSTEP_LDIR"; then
  if test "$GNUSTEP_FLATTENED" = yes; then
    OBJC_CPPFLAGS="$CPPFLAGS $INCLUDES -I$GNUSTEP_SYSTEM_ROOT/Library/Headers"
  else
    OBJC_CPPFLAGS="$CPPFLAGS $INCLUDES -I$GNUSTEP_SYSTEM_ROOT/Library/Headers/${ac_cv_library_combo}"
  fi
  OBJC_LDFLAGS="$LDFLAGS $LIB_DIR -L$gs_cv_objc_libdir"
fi

# And the following to execute them
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$gs_cv_objc_libdir"
export LD_LIBRARY_PATH

#--------------------------------------------------------------------
# Miscellaneous headers (only used for compiling which_lib.c and user_home.c)
#--------------------------------------------------------------------
AC_HEADER_DIRENT
AC_CHECK_HEADERS(sys/param.h sys/file.h dir.h string.h stdlib.h sys/types.h dnl
		fcntl.h limits.h utime.h sys/stat.h pwd.h unistd.h)
AC_CHECK_FUNCS(getpwnam getpwuid geteuid getlogin strchr)

#--------------------------------------------------------------------
# Check if libobjc was compiled with thread support.
#--------------------------------------------------------------------
OBJC_THREAD=
AC_ARG_WITH(thread-lib,
[--with-thread-lib		Specify alternate thread library],
OBJC_THREAD=$withval,
OBJC_THREAD=
)


AC_MSG_CHECKING(whether objc has thread support)
saved_CFLAGS="$CFLAGS"
saved_LIBS="$LIBS"
CFLAGS="$CFLAGS -x objective-c -I$srcdir $OBJC_CPPFLAGS $OBJC_LDFLAGS"
if test "$OBJC_RUNTIME_LIB" = "gnu"; then
  CFLAGS="$CFLAGS -fgnu-runtime"
fi
if test "$OBJC_RUNTIME_LIB" = "nx"; then
  CFLAGS="$CFLAGS -DNeXT_RUNTIME"
fi
if test "$OBJC_RUNTIME_LIB" = "apple"; then
  CFLAGS="$CFLAGS -DNeXT_RUNTIME"
fi
if test "$OBJC_THREAD" != ""; then
  LIBS="-lobjc $LIBS $OBJC_THREAD"
  AC_TRY_RUN([#include "config_thread.m"], 
	objc_threaded="$OBJC_THREAD",
	objc_threaded="", objc_threaded="")
elif test "$host_os" = linux-gnu; then
  LIBS="-lobjc -lpthread"
  AC_TRY_RUN([#include "config_thread.m"], objc_threaded="-lpthread",
	objc_threaded="", objc_threaded="-lpthread")
elif test "`echo $host_os|sed 's/[[0-9]].*//'|sed s/elf//`" = freebsd; then
  LIBS="-pthread -lobjc"
  AC_TRY_RUN([#include "config_thread.m"], objc_threaded="-pthread",
       objc_threaded="", objc_threaded="-pthread")
  if test x"$objc_threaded" = x""; then
    LIBS="-lpthread -lobjc"
    AC_TRY_RUN([#include "config_thread.m"], objc_threaded="-lpthread",
	objc_threaded="", objc_threaded="-lpthread")
  fi
  if test x"$objc_threaded" = x""; then
    LIBS="-lobjc -lpcthread"
    AC_TRY_RUN([#include "config_thread.m"], objc_threaded="-lpcthread",
	objc_threaded="", objc_threaded="-lpcthread")
  fi
elif test "$MINGW32" = yes; then
  # Mingw doesn't need anything extra for threads
  LIBS="-lobjc $LIBS"
  AC_TRY_RUN([#include "config_thread.m"], 
	objc_threaded="works",
	objc_threaded="", objc_threaded="works")
else
  LIBS="-lobjc $LIBS"
  AC_TRY_RUN([#include "config_thread.m"], 
	objc_threaded="works",
	objc_threaded="", objc_threaded="")
  if test x"$objc_threaded" = x""; then
    LIBS="-lobjc $saved_LIBS -lpthread "
    AC_TRY_RUN([#include "config_thread.m"], 
    	objc_threaded="-lpthread", 
	objc_threaded="", objc_threaded="")
  fi
  if test x"$objc_threaded" = x""; then
    # Solaris, OpenBSD/sparc
    LIBS="-lobjc $saved_LIBS -lpthread -lposix4"
    AC_TRY_RUN([#include "config_thread.m"], 
    	objc_threaded="-lpthread -lposix4", 
	objc_threaded="", objc_threaded="")
  fi
  if test x"$objc_threaded" = x""; then
    LIBS="-lobjc $saved_LIBS -lthread "
    AC_TRY_RUN([#include "config_thread.m"], 
    	objc_threaded="-lthread", 
	objc_threaded="", objc_threaded="")
  fi
fi
if test x"$objc_threaded" = x""; then
  AC_MSG_RESULT(no)
else
  if test x"$objc_threaded" = x"works"; then
    objc_threaded=""
  fi
  AC_MSG_RESULT(yes: $objc_threaded)
fi
ac_cv_objc_threaded="$objc_threaded"
AC_SUBST(objc_threaded)
AC_SUBST(ac_cv_objc_threaded)

# Do not restore LIBS and CFLAGS yet as we need to test if the
# compiler supports native exceptions.

#--------------------------------------------------------------------
# Check if GCC supports -fobjc-exceptions, and if so, turn it on!
#--------------------------------------------------------------------

AC_ARG_ENABLE(native-objc-exceptions,
	AC_HELP_STRING([--enable-native-objc-exceptions],
		       [use native objective-c exceptions]),
	USE_OBJC_EXCEPTIONS=$enableval,
	USE_OBJC_EXCEPTIONS=no)

AC_MSG_CHECKING(whether we should use native ObjC exceptions)
if test x"$USE_OBJC_EXCEPTIONS" = x"yes"; then
  # What we want to do: set USE_OBJC_EXCEPTIONS to yes if we can compile
  # something with @try/@catch/@finally in it.
  if test ! ${GCC} = "yes" ; then
    USE_OBJC_EXCEPTIONS=no
    AC_MSG_RESULT(no: compiler isn't gcc)
  else
    CFLAGS="$CFLAGS -fobjc-exceptions"
    AC_RUN_IFELSE([[
#include <stdlib.h>
#include <objc/Object.h>

int main(int argc, char **argv)
{
	Object *o=nil;
	@try
	{
		o=[Object new];
		@throw o;
	}
	@catch (id foo)
	{
		if (o!=foo)
			return 1;
	}
	return 0;
}
  ]], USE_OBJC_EXCEPTIONS=yes, USE_OBJC_EXCEPTIONS=no)
    AC_MSG_RESULT($USE_OBJC_EXCEPTIONS)
  fi
  if test x$USE_OBJC_EXCEPTIONS = xno; then
    AC_MSG_NOTICE([Native objective-c exceptions were requested, but the compiler])
    AC_MSG_NOTICE([doesn't support them.])
    AC_MSG_ERROR([compiler doesn't support native objective-c exceptions])
  fi
else
  AC_MSG_RESULT(not requested by user)
fi

AC_SUBST(USE_OBJC_EXCEPTIONS)

# Restore LIBS and CFLAGS - we are going to compile C code in the next
# test.
LIBS="$saved_LIBS"
CFLAGS="$saved_CFLAGS"

#--------------------------------------------------------------------
# Check if compiler supports -MMD -MP to generate %.d files ...
#--------------------------------------------------------------------

AC_MSG_CHECKING(if the compiler supports autodependencies)

# What we want to do: set AUTO_DEPENDENCIES to yes if gcc => 3.x

if test ! ${GCC} = "yes" ; then
  AUTO_DEPENDENCIES=""
  AC_MSG_RESULT(no: it's not gcc)
else
  # Running gcc -dumpversion we get something like 2.95.4 or
  #  egcs-2.91.66 or 3.0.2 or 3.1 20011211
  # We want to discard anything but the major number.
  # Explanation of the regexp -
  # \(^[^0-9]*\) matches beginning of line and following non numeric chars
  # \([0-9][0-9]*\) matches 1 or more numeric chars (this is the 2^nd
  #  subpattern)
  # \([^0-9].*\) matches a non numeric char followed by anything
  # /\2/ replace the whole lot with the 2^nd subpattern
  gs_cv_gcc_major_version=`${CC} -dumpversion | sed "s/\([[^0-9]]*\)\([[0-9]][[0-9]]*\)\([[^0-9]].*\)/\2/"`;

  if test "${gs_cv_gcc_major_version}" -ge "3" ; then
    AUTO_DEPENDENCIES=yes
    AC_MSG_RESULT(yes: gcc major version is ${gs_cv_gcc_major_version})
  else
    AUTO_DEPENDENCIES=""
    AC_MSG_RESULT(no: gcc major version is ${gs_cv_gcc_major_version})
  fi
fi

AC_SUBST(AUTO_DEPENDENCIES)
AC_SUBST(INCLUDES)
AC_SUBST(LIB_DIR)
AC_SUBST(OBJCFLAGS)

#--------------------------------------------------------------------
# Shall we strip makefiles upon installation ?
#--------------------------------------------------------------------

# Stripping makefiles removes comments and newlines from them.  The
# resulting stripped makefiles execute around 5% faster on average.
# Too little for it to be worth for the common user who's more
# interested in the comments :-) so it's disabled by default.
AC_MSG_CHECKING(if we should strip makefiles after installation)
AC_ARG_ENABLE(strip-makefiles, 
[--enable-strip-makefiles	Enable stripping makefiles after installation], 
  ac_cv_strip_makefiles=$enableval,
  ac_cv_strip_makefiles="undefined")

if test "$ac_cv_strip_makefiles" = "yes"; then
  GNUSTEP_STRIP_MAKEFILES=strip;
  AC_MSG_RESULT(yes);
else
  GNUSTEP_STRIP_MAKEFILES=;
  AC_MSG_RESULT(no);
fi
AC_SUBST(GNUSTEP_STRIP_MAKEFILES)

#--------------------------------------------------------------------
# Disable updating the obsolete directory structure
#--------------------------------------------------------------------
gs_move_obsolete=yes
AC_ARG_ENABLE(move-obsolete, 
[--disable-move-obsolete		Disable moving obsolete dir structure], 
  gs_move_obsolete=$enableval,
  gs_move_obsolete=yes)

if test "$gs_move_obsolete" = "yes"; then
  GNUSTEP_MOVE_OBSOLETE=move_obsolete;
else
  GNUSTEP_MOVE_OBSOLETE=
  AC_MSG_NOTICE(Old GNUstep directories will not be moved)
fi
AC_SUBST(GNUSTEP_MOVE_OBSOLETE)

#--------------------------------------------------------------------
# Record the version
#--------------------------------------------------------------------
AC_MSG_CHECKING(for the version of gnustep-make we are compiling)
. "$srcdir/Version"
AC_MSG_RESULT($GNUSTEP_MAKE_VERSION)
AC_SUBST(GNUSTEP_MAKE_VERSION)
AC_SUBST(GNUSTEP_MAKE_MAJOR_VERSION)
AC_SUBST(GNUSTEP_MAKE_MINOR_VERSION)
AC_SUBST(GNUSTEP_MAKE_SUBMINOR_VERSION)

#-------------------------------------------------------------------
# Record the 'clean' target_os, target_cpu and target_vendor
#-------------------------------------------------------------------
# This is just for efficiency, so that core/make/GNUmakefile does not
# have to compute clean_target_os from target_os (and similar) by
# running shell scripts each time you 'make' something inside
# gnustep-make.  We basically compute them once now, and cache them
# forever.  It is also used by GNUstep.sh when multi-platform is
# disabled.
clean_target_os=`$srcdir/clean_os.sh $target_os`
clean_target_cpu=`$srcdir/clean_cpu.sh $target_cpu`
clean_target_vendor=`$srcdir/clean_cpu.sh $target_vendor`
AC_SUBST(clean_target_os)
AC_SUBST(clean_target_cpu)
AC_SUBST(clean_target_vendor)
AC_SUBST(target)

#--------------------------------------------------------------------
# Produce the output files
#--------------------------------------------------------------------
AC_CONFIG_FILES([config.make openapp debugapp opentool 
executable.template GNUmakefile GNUstep.conf GNUstep.sh GNUstep.csh fixpath.sh
gnustep-make.spec GNUsteprc])
AC_CONFIG_COMMANDS([default],
	[[chmod a+x openapp debugapp opentool fixpath.sh executable.template]],
	[[]])
AC_OUTPUT
