#
#   file-list.make
#
#   Makefile rules to build the list of files installed by *any*
#   GNUstep software controlled by the GNUstep make package
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

#
# To create the file-list for your package, just type: 
#   make filelist=yes install
# This will run `install' but, instead of installing, build the file list.
#
# Warning: this is alpha design as of Jan 2001.  In the near future the
# mechanism could be changed if we see it doesn't work or a better solution
# is found.
#

# prevent multiple inclusions
ifeq ($(FILE_LIST_MAKE_LOADED),)
FILE_LIST_MAKE_LOADED=yes

# If filelist=yes, redefine all installation programs to log what they
# are installing/creating into the file-list.
ifeq ($(filelist),yes)
  INSTALL_DATA    = $(GNUSTEP_MAKEFILES)/log_install.sh
  INSTALL_PROGRAM = $(GNUSTEP_MAKEFILES)/log_install.sh
  INSTALL_COMPLETE_DIR = $(GNUSTEP_MAKEFILES)/log_install_dir.sh
  INSTALL_LN_S     = $(GNUSTEP_MAKEFILES)/log_install_ln_s.sh
  # Disabled not to remove anything
  REMOVE_INSTALLED_LN_S = echo > /dev/null 

  # Mkdirs does no harm, rather it allows our log_install.sh to determine
  # whether something is a directory or a file, and this is needed
  #  MKDIRS          = 

  # The logging programs can get which file to log to by reading the
  # environment variable `FILE_LIST'.

  # Set it once for all at the top-level
  ifeq ($(MAKELEVEL),0)
    FILE_LIST = $(shell pwd)/file-list
    # and then pass it down to sub-makes and to the logging programs
    export FILE_LIST

    # Finally, remove file-list at the very beginning
    before-install::
	-rm -f file-list

  endif # MAKELEVEL == 0
endif # filelist == yes


endif # file-list.make loaded

## Local variables:
## mode: makefile
## End:




