/*
   user_home.c
   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: February 2002

   This file is part of the GNUstep Makefile Package.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   You should have received a copy of the GNU General Public
   License along with this library; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */

#include "config.h"

#include <stdio.h>

#if HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif

#if HAVE_STDLIB_H
# include <stdlib.h>
#endif

#if HAVE_UNISTD_H
# include <unistd.h>
#endif

#if HAVE_STRING_H
# include <string.h>
#endif

#if HAVE_PWD_H
# include <pwd.h>
#endif


/* NOTE FOR DEVELOPERS.
 * If you change the behavior of this method you must also change
 * NSUser.m in the base library package to match.
 */
int main (int argc, char** argv)
{
#if defined(__MINGW__)
  char		buf0[1024];
  char		buf1[1024];
  int		len0;
  int		len1;
#else
  struct passwd *pw;
#endif
  const char *loginName = 0;

  if (loginName == 0)
    {
#if defined(__WIN32__)
      /* The GetUserName function returns the current user name */
      DWORD	n = 1024;

      len0 = GetEnvironmentVariable("LOGNAME", buf0, 1024);
      if (len0 > 0 && len0 < 1024)
	{
	  loginName = buf0;
	  loginName[len0] = '\0';
	}
      else if (GetUserName(buf0, &n))
	{
	  loginName = buf0;
	}
#else
      loginName = getenv("LOGNAME");
#if	HAVE_GETPWNAM
      /*
       * Check that LOGNAME contained legal name.
       */
      if (loginName != 0 && getpwnam(loginName) == 0)
	{
	  loginName = 0;
	}
#endif	/* HAVE_GETPWNAM */
#if	HAVE_GETLOGIN
      /*
       * Try getlogin() if LOGNAME environmentm variable didn't work.
       */
      if (loginName == 0)
	{
	  loginName = getlogin();
	}
#endif	/* HAVE_GETLOGIN */
#if HAVE_GETPWUID
      /*
       * Try getting the name of the effective user as a last resort.
       */
      if (loginName == 0)
	{
#if HAVE_GETEUID
	  int uid = geteuid();
#else
	  int uid = getuid();
#endif /* HAVE_GETEUID */
	  struct passwd *pwent = getpwuid (uid);
	  loginName = pwent->pw_name;
	}
#endif /* HAVE_GETPWUID */
#endif
      if (loginName == 0)
	{
	  fprintf(stderr, "Unable to determine current user name.\n");
	  return 1;
	}
    }

#if !defined(__MINGW__)
  pw = getpwnam (loginName);
  if (pw == 0)
    {
      fprintf(stderr, "Unable to locate home directory for '%s'\n", loginName);
      return 1;
    }
  printf("%s", pw->pw_dir);
  return 0;
#else
  /* Then environment variable HOMEPATH holds the home directory
     for the user on Windows NT; Win95 has no concept of home. */
  len0 = GetEnvironmentVariable("HOMEPATH", buf0, 1024);
  if (len0 > 0 && len0 < 1024)
    {
      buf0[len0] = '\0';
      len1 = GetEnvironmentVariable("HOMEDRIVE", buf1, 1024);
      if (len1 > 0 && len1 < 1024)
	{
	  buf1[len1] = '\0';
	  printf("%s%s", buf0, buf1);
	  return 0;
	}
    }
  fprintf(stderr, "Unable to determine HOMEDRIVE or HOMEPATH\n");
  return 1;
#endif
}

