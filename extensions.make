#
#  extensions.make
#
#  Makefile include segment which handles linking to the extensions
#  library; requires the GNUstep makefile package.
#
#  Copyright (C) 1997 NET-Community
#
#  Author: Scott Christley <scottc@net-community.com>
#
#  This file is part of Foundation Extensions Library.
#
#  Permission to use, copy, modify, and distribute this software and
#  its documentation for any purpose and without fee is hereby
#  granted, provided that the above copyright notice appear in all
#  copies and that both that copyright notice and this permission
#  notice appear in supporting documentation.
#
#  We disclaim all warranties with regard to this software, including
#  all implied warranties of merchantability and fitness, in no event
#  shall we be liable for any special, indirect or consequential
#  damages or any damages whatsoever resulting from loss of use, data
#  or profits, whether in an action of contract, negligence or other
#  tortious action, arising out of or in connection with the use or
#  performance of this software.

#
# libFoundation already has the extensions so only need to link
# with extensions library when using a different Foundation library.
#
ifneq ($(FOUNDATION_LIB),fd)
AUXILIARY_LIBS += -lFoundationExt
endif
