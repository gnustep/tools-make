/*
   which_lib.c
   Copyright (C) 1997 Free Software Foundation, Inc.

   Author: Ovidiu Predescu <ovidiu@net-community.com>
   Date: October 1997

   This file is part of the GNUstep Makefile Package.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   You should have received a copy of the GNU General Public
   License along with this library; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

/*
  Takes the name of the library, a list of search paths in the gcc notation
  (using -Lpath) and the type of the library needed using the debug, profile,
  static and shared variables.
 
  It searches into the list of directories for a library matching the name and
  the type required. If a library of that type is not found in a directory,
  a similar one is tried. If no library is found at all then the next directory
  will be searched. If no library is found in the list of libraries passed as
  arguments, the user, then the local and finally the system GNUstep libraries
  are searched.
*/

#include "config.h"

#include <stdio.h>

#include <errno.h>

#if HAVE_SYS_ERRNO_H
# include <sys/errno.h>
#endif

#if HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif

#if HAVE_STDLIB_H
# include <stdlib.h>
#endif

#if HAVE_STRING_H
# include <string.h>
#endif

#if HAVE_SYS_STAT_H
# include <sys/stat.h>
#endif

#include <fcntl.h>

#if defined(HAVE_DIRENT_H)
# include <dirent.h>
#elif defined(HAVE_SYS_DIR_H)
# include <sys/dir.h>
#elif defined(HAVE_SYS_NDIR_H)
# include <sys/ndir.h>
#elif defined(HAVE_NDIR_H)
# include <ndir.h>
#elif defined(HAVE_DIR_H)
# include <dir.h>
#endif

#if !defined(_POSIX_VERSION)
# if defined(NeXT)
#  define DIR_enum_item struct direct
# endif
#endif

#if !defined(DIR_enum_item)
# define DIR_enum_item struct dirent
#endif

#define DIR_enum_state DIR

/* determine filesystem max path length */

# include <limits.h>			/* for PATH_MAX */

#ifdef _POSIX_VERSION
# include <utime.h>
#else
# if HAVE_SYS_PARAM_H
#  include <sys/param.h>		/* for MAXPATHLEN */
# endif
#endif

#ifndef PATH_MAX
# ifdef _POSIX_VERSION
#  define PATH_MAX _POSIX_PATH_MAX
# else
#  ifdef MAXPATHLEN
#   define PATH_MAX MAXPATHLEN
#  else
#   define PATH_MAX 1024
#  endif
# endif
#endif

#if HAVE_SYS_FILE_H
#include <sys/file.h>
#endif

#define PATH_SEP "/"

/* Array of strings that are the library paths passed to compiler */
int paths_no = 0;
char** library_paths = NULL;

/* The list of libraries */
int libraries_no = 0;
char** all_libraries = NULL;

int library_name_len;
char* library_name = NULL;
char *libname_suffix;
int debug = 0;
int profile = 0;
int shared = 0;
char* libext = ".a";
char* shared_libext = ".so";
char* extension;

void get_arguments (int argc, char** argv)
{
  int i;

  for (i = 0; i < argc; i++) {
    if (!strncmp (argv[i], "-l", 2)) {
      if (all_libraries)
        all_libraries = realloc (all_libraries,
			       (libraries_no + 1) * sizeof (char*));
      else
        all_libraries = malloc ((libraries_no + 1) * sizeof (char*));
      all_libraries[libraries_no] = malloc (strlen (argv[i]) - 1);
      strcpy (all_libraries[libraries_no], argv[i] + 2);
      libraries_no++;
    }
    else if (!strncmp (argv[i], "-L", 2)) {
      if (library_paths)
        library_paths = realloc (library_paths, (paths_no + 1) * sizeof(char*));
      else
        library_paths = malloc ((paths_no + 1) * sizeof(char*));
      library_paths[paths_no] = malloc (strlen (argv[i]) - 1);
      strcpy (library_paths[paths_no], argv[i] + 2);
      paths_no++;
    }
    else if (!strncmp (argv[i], "shared=", 7)) {
      shared = !strncmp (argv[i] + 7, "yes", 3);
    }
    else if (!strncmp (argv[i], "debug=", 6)) {
      debug = !strncmp (argv[i] + 6, "yes", 3);
    }
    else if (!strncmp (argv[i], "profile=", 8)) {
      profile = !strncmp (argv[i] + 8, "yes", 3);
    }
    else if (!strncmp (argv[i], "libext=", 7)) {
      libext = malloc (strlen (argv[i] + 7) + 1);
      strcpy (libext, argv[i] + 7);
    }
    else if (!strncmp (argv[i], "shared_libext=", 14)) {
      shared_libext = malloc (strlen (argv[i] + 14) + 1);
      strcpy (shared_libext, argv[i] + 14);
    }
  }

  /* Setup the exact prefix of the library we are looking for */
  libname_suffix = malloc (5);
  *libname_suffix = 0;

  if (!shared)
    strcat (libname_suffix, "s");
  if (profile)
    strcat (libname_suffix, "p");
  if (debug)
    strcat (libname_suffix, "d");

  if (*libname_suffix) {
    char tmp[5];

    strcpy (tmp, libname_suffix);
    strcpy (libname_suffix, "_");
    strcat (libname_suffix, tmp);
  }

  /* Setup the extension */
  extension = shared ? shared_libext : libext;
}

void show_all (void)
{
  int i;

  printf ("shared = %d\n", shared);
  printf ("debug = %d\n", debug);
  printf ("profile = %d\n", profile);
  printf ("libext = %s\n", libext);
  printf ("shared_libext = %s\n", shared_libext);
  printf ("library name = %s\n", library_name);
  puts ("library paths:");

  for (i = 0; i < paths_no; i++)
    printf ("    %s\n", library_paths[i]);
}

/*  Search for a library whose type is defined in 'type' as
      'd' for debug
      'p' for profile
      's' for static
      0 for the first library that matches library_name
    Return 1 if a library with this type matches in 'path' and print to stdout
  the name of the library. */

int search_for_library_with_type_in_directory(char type, char* path, char* ext)
{
  DIR_enum_state* dir;
  DIR_enum_item* dirbuf;
  int i, found = 0;

  dir = opendir (path);

  while ((dirbuf = readdir (dir))) {
    int filelen, extlen;

    /* Skip "." and ".." directory entries */
    if (strcmp(dirbuf->d_name, ".") == 0 
	|| strcmp(dirbuf->d_name, "..") == 0)
      continue;

    /* Skip it if the prefix does not match the library name. */
    if (strncmp (dirbuf->d_name + 3, library_name, library_name_len))
      continue;

    filelen = strlen (dirbuf->d_name);

    /* Now check if the extension matches */
    if (ext && (extlen = strlen (ext)) && filelen - extlen > 0) {
      int dfound = 0, sfound = 0, pfound = 0, dash = 0;

      if (strcmp (dirbuf->d_name + filelen - extlen, ext))
	/* No luck, skip this file */
	continue;

      /* The extension matches. Do a check to see if the suffix of the
	 library matches the library type we are looking for. */
      for (i = library_name_len + 3; i < filelen - extlen; i++) {
	/* Possibly a match */
	if (type == dirbuf->d_name[i])
	  found = 1;

	if (dirbuf->d_name[i] == '_') { /* Only one dash allowed */
	  /* Found another dash or one of the letters first */
	  if (dash || dfound || sfound || pfound) {
	    found = 0;
	    break;
	  }
	  else {
	    dash = 1;
	    continue;
	  }
	}
	else if (dirbuf->d_name[i] == 'd') { /* Only one d allowed */
	  /* We must have found the dash already */
	  if (!dash || dfound) {
	    found = 0;
	    break;
	  }
	  else {
	    dfound = 1;
	    continue;
	  }
	}
	else if (dirbuf->d_name[i] == 'p') { /* Only one p allowed */
	  /* We must have found the dash already */
	  if (!dash || pfound) {
	    found = 0;
	    break;
	  }
	  else {
	    pfound = 1;
	    continue;
	  }
	}
	else if (dirbuf->d_name[i] == 's') { /* Only one s allowed */
	  /* We must have found the dash already */
	  if (!dash || sfound) {
	    found = 0;
	    break;
	  }
	  else {
	    sfound = 1;
	    continue;
	  }
	}
	else {
	  /* Skip the libraries that begin with the same name but have
	     different suffix, eg libobjc.a libobjc-test.a. */
	  found = 0;
	  break;
	}
      }

      if (found) {
	char filename[PATH_MAX + 1];

	/* Copy the name of the library without the "lib" prefix and the
	   extension. */
	strncpy (filename, dirbuf->d_name + 3, filelen - extlen - 3);
	filename[filelen - extlen - 3] = 0;
	printf (" -l%s", filename);
	break;
      }
    }
  }

  closedir (dir);
  return found;
}

/* Returns 1 if found the library in path and prints to stdout the name of the
   library. */
int search_for_library_in_directory (char* path)
{
  struct stat statbuf;
  char full_filename[PATH_MAX + 1];

  if (stat (path, &statbuf) < 0) /* An error occured or the dir doesn't exist */
    return 0;
  else if ((statbuf.st_mode & S_IFMT) != S_IFDIR) /* Not a directory */
    return 0;

  strcpy (full_filename, path);
  strcat (full_filename, PATH_SEP);
  strcat (full_filename, "lib");
  strcat (full_filename, library_name);
  strcat (full_filename, libname_suffix);
  strcat (full_filename, extension);

  if (stat (full_filename, &statbuf) < 0 && errno != ENOENT) /* Error */
    return 0;

  if ((statbuf.st_mode & S_IFMT) == S_IFREG) { /* Found it! */
    printf (" -l%s", library_name);
    if (*libname_suffix)
      printf ("%s", libname_suffix);
    return 1;
  }

  /* The library was not found. If the library needed is a debug version try
     to find a library with debugging info. */
  if (debug && search_for_library_with_type_in_directory('d', path, extension))
    return 1;

  /* The library was still not found. If the library needed is a profile
     version try to find one that has profile info in it. */
  if (profile && search_for_library_with_type_in_directory('p',path,extension))
    return 1;

  /* The library was still not found. Try to get whatever library we have
     there. */

  /* If a shared library is needed try to find a shared one first. */
  if (shared
      && search_for_library_with_type_in_directory (0, path, shared_libext))
    return 1;

  /* Return a static library that matches the 'library_name' */
  if (search_for_library_with_type_in_directory (0, path, libext))
    return 1;

  return 0;
}

int main(int argc, char** argv)
{
  int i, j, found;

  if (argc == 1) {
    printf ("usage: %s [-Lpath ...] -llibrary shared=yes|no debug=yes|no "
	    "profile=yes|no libext=string shared_libext=string\n", argv[0]);
    exit (1);
  }

  get_arguments (argc, argv);

  if (!libraries_no)
    exit (0);

/*  show_all ();*/

  for (i = 0; i < libraries_no; i++) {
    library_name = all_libraries[i];
    library_name_len = strlen (library_name);
    found = 0;
    for (j = 0; j < paths_no; j++)
      if (search_for_library_in_directory (library_paths[j])) {
	found = 1;
	break;
      }

    if (!found) {
      /* The library was not found. Assume there is somewhere else in the
         linker library path and it will find the library. Otherwise a linking
	 error will happen but this is not our fault ;-). */
      printf (" -l%s", library_name);
    }
  }

  puts ("");

  exit (0);
  return 0;
}
