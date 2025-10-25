# SYNOPSIS
#
#   GS_BLOCKS_SUPPORT()
#
# DESCRIPTION
#
# This macro determines whether and how blocks are used
#
AC_DEFUN([GS_BLOCKS_SUPPORT],dnl
  [
    AC_REQUIRE([GS_LIBRARY_COMBO])
    AC_REQUIRE([GS_CHECK_OBJC_RUNTIME])
    BLOCKS_LIBS=""
    if test "$OBJC_RUNTIME_LIB" = ng; then
    #
    # Detect compiler support for Blocks; perhaps someday -fblocks won't be
    # required, in which case we'll need to change this.
    #
    saveCFLAGS="$CFLAGS"
    CFLAGS="$CFLAGS -fblocks"

    AC_LANG_PUSH(C)
    AC_MSG_CHECKING([for blocks support in compiler])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([],[(void)^{int i; i = 0; }();])], [
      ac_cv_blocks="yes"
    ], [
      ac_cv_blocks="no"
    ])
    AC_MSG_RESULT([$ac_cv_blocks])
    CFLAGS="$saveCFLAGS"
    if test "$ac_cv_blocks" = yes; then
      saveLIBS="$LIBS"
      LIBS="$LIBS $OBJC_FINAL_LIB_FLAG"
      AC_CHECK_FUNC([_Block_copy])
      LIBS="$saveLIBS"
      if test "$ac_cv_func__Block_copy" = no; then
        AC_CHECK_LIB([BlocksRuntime], [_Block_copy])
        if test "$ac_cv_lib_BlocksRuntime__Block_copy" = yes; then
          BLOCKS_LIBS="-lBlocksRuntime"
        else
          AC_MSG_ERROR([Your compiler supports blocks, but the symbols required for blocks support are found neither in libobjc nor in libBlocksRuntime. To fix this, recompile libobjc2 with an embedded blocks runtime, or install libBlocksRuntime/libdispatch with private headers.])
        fi
      fi
    else
      AC_MSG_ERROR([Your compiler doesn't appear to support blocks. To fix this use the CC environment varibale to specify a different compiler (or use a different library-combo)]);
    fi
    AC_LANG_POP(C)
  fi
  AC_SUBST(BLOCKS_LIBS)
])
