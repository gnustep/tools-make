#
#   messages.make
#
#   Prepare messages
#
#   Copyright (C) 2002 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <n.pero@mi.flashnet.it>
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

ifneq ($(messages),yes)

  # General messages
  ECHO_COMPILING = @(echo " Compiling file $< ...";
  ECHO_LINKING   = @(echo " Linking $(GNUSTEP_TYPE) $(GNUSTEP_INSTANCE) ...";
  ECHO_JAVAHING  = @(echo " Running javah on $< ...";
  ECHO_INSTALLING = @(echo " Installing $(GNUSTEP_TYPE) $(GNUSTEP_INSTANCE)...";

  # Instance/Shared/bundle.make
  ECHO_COPYING_RESOURCES = @(echo " Copying resources into the $(GNUSTEP_TYPE) wrapper...";
  ECHO_COPYING_LOC_RESOURCES = @(echo " Copying localized resources into the $(GNUSTEP_TYPE) wrapper...";
  ECHO_CREATING_LOC_RESOURCE_DIRS = @(echo " Creating localized resource dirs into the $(GNUSTEP_TYPE) wrapper...";
  ECHO_COPYING_RESOURCES_FROM_SUBPROJS = @(echo " Copying resources from subprojects into the $(GNUSTEP_TYPE) wrapper...";
  ECHO_COPYING_WEBSERVER_RESOURCES = @(echo " Copying webserver resources into the $(GNUSTEP_TYPE) wrapper...";
  ECHO_COPYING_WEBSERVER_LOC_RESOURCES = @(echo " Copying localized webserver resources into the $(GNUSTEP_TYPE) wrapper...";
  ECHO_CREATING_WEBSERVER_LOC_RESOURCE_DIRS = @(echo " Creating localized webserver resource dirs into the $(GNUSTEP_TYPE) wrapper...";

  # Instance/Shared/headers.make
  ECHO_INSTALLING_HEADERS = @(echo " Installing headers...";

  # Instance/Shared/java.make
  ECHO_INSTALLING_CLASS_FILES = @(echo " Installing class files...";
  ECHO_INSTALLING_ADD_CLASS_FILES = @(echo " Installing nested class files...";
  ECHO_INSTALLING_PROPERTIES_FILES = @(echo " Installing property files...";

  END_ECHO = )

#
# Translation of messages:
#
# In case a translation is appropriate (FIXME - decide how to
# determine if this is the case), here we will determine which
# translated messages.make file to use, and include it here; this file
# can override any of the ECHO_XXX variables providing new definitions
# which print out the translated messages.  (if it fails to provide a
# translation of any variable, the original untranslated message would
# then be automatically print out).
#

else

  ECHO_COMPILING = 
  ECHO_LINKING = 
  ECHO_JAVAHING = 
  ECHO_INSTALLING =

  ECHO_COPYING_RESOURCES = 
  ECHO_COPYING_LOC_RESOURCES =
  ECHO_CREATING_LOC_RESOURCE_DIRS =
  ECHO_COPYING_RESOURCES_FROM_SUBPROJS =
  ECHO_COPYING_WEBSERVER_RESOURCES =
  ECHO_COPYING_WEBSERVER_LOC_RESOURCES = 
  ECHO_CREATING_WEBSERVER_LOC_RESOURCE_DIRS =

  ECHO_INSTALLING_HEADERS =

  ECHO_INSTALLING_CLASS_FILES = 
  ECHO_INSTALLING_ADD_CLASS_FILES = 
  ECHO_INSTALLING_PROPERTIES_FILES = 

  END_ECHO = 

endif

