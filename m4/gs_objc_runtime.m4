AC_DEFUN([GS_OBJ_DIR], [
    AC_CACHE_CHECK([for object subdirectory],[_gs_cv_obj_dir], [
        if test "$GNUSTEP_IS_FLATTENED" != yes; then
            clean_target_os=`$srcdir/clean_os.sh $target_os`
            clean_target_cpu=`$srcdir/clean_cpu.sh $target_cpu`
            _gs_cv_obj_dir="$clean_target_cpu/$clean_target_os"
        else
            _gs_cv_obj_dir="(none)"
        fi
    ])
    AS_VAR_IF([_gs_cv_obj_dir], ["(none)"], AS_UNSET(gs_cv_obj_dir), [AS_VAR_SET([gs_cv_obj_dir], [${_gs_cv_obj_dir}])])
])

AC_DEFUN([GS_DOMAIN_DIR],[
    AC_REQUIRE([GS_OBJ_DIR])
    m4_pushdef([search_dir], [m4_join([],[gs_cv_], $1, [_], $2, [_dir])])
    AC_CACHE_VAL(search_dir,[
       search_dir=m4_join([],[$GNUSTEP_], $1, [_], $2)
    
        if test ! "$GNUSTEP_IS_FLATTENED" = yes; then
            search_dir="${search_dir}/m4_case([$2], [HEADERS], [${LIBRARY_COMBO}], [LIBRARIES], [${gs_cv_obj_dir}])"
        fi
    ])
    m4_popdef([search_dir])
])

AC_DEFUN([GS_DOMAINS_FOR_FILES],[
    m4_pushdef([cache_var], [m4_join([], [gs_cv_], $1,  [_domains])])
    AC_REQUIRE([GS_OBJ_DIR])
    AC_CACHE_CHECK(m4_join([ ], [for domains containing], m4_tolower($2), m4_join([, ], [$3])), cache_var, [
    cache_var=""
    INFIX=""
    m4_foreach([domain], [SYSTEM, NETWORK, LOCAL, USER], [
        m4_pushdef([search_dir], [m4_join([],[gs_cv_], domain, [_], $2, [_dir])])
        GS_DOMAIN_DIR([domain],[$2])
        if test -d  $search_dir; then
            if test -f "$search_dir/m4_combine(m4_join([], [-o -f "$], search_dir, [/]), [$3], [" ], []); then
                cache_var="${cache_var}${INFIX}domain"
                INFIX=", "
            fi
        fi
        m4_popdef([search_dir])
    ])
    if test x"${cache_var}" = x""; then
        cache_var="(none)"
    fi
    ])
    AS_VAR_IF(cache_var, ["(none)"], AS_UNSET(m4_join([_], $1, [DOMAINS])), [AS_VAR_SET(m4_join([_], $1, [DOMAINS]), [${cache_var}])])
    m4_popdef([cache_var])
])

AC_DEFUN([_GS_LIBOJC_DOMAINS],[
    GS_DOMAINS_FOR_FILES([LIBOBJC], [LIBRARIES], [libobjc.a, libobjc.so, libobjc.dll.a, libobjc-gnu.dylib])
])

AC_DEFUN([_GS_OBJC_HEADER_DOMAINS],[
    GS_DOMAINS_FOR_FILES([OBJC_HEADERS], [HEADERS], [objc/objc.h])
])

AC_DEFUN([GS_CUSTOM_OBJC_RUNTIME_DOMAIN], [
    AC_REQUIRE([AC_PROG_SED])
    AC_REQUIRE([_GS_LIBOJC_DOMAINS])
    AC_REQUIRE([_GS_OBJC_HEADER_DOMAINS])
    AC_CACHE_CHECK([for custom shared objc library domain], [gs_cv_libobjc_domain], [
        gs_cv_libobjc_domain=""
        for i in $(echo ${LIBOBJC_DOMAINS}| $SED "s/, / /g"); do
            for j in $(echo ${OBJC_HEADERS_DOMAINS}| $SED "s/, / /g"); do
                if test x"$i" = x"$j"; then
                    gs_cv_libobjc_domain=$i
                    break
                fi
            done
            if test ! x"$gs_cv_libobjc_domain" = x""; then
                break
            fi
        done
    ])
])

AC_DEFUN([GS_LIBOBJC_PKG], [
    AC_REQUIRE([GS_OBJC_LIB_FLAG])
    libobjc_SUPPORTS_ABI20=""
    if test x"$GNUSTEP_HAS_PKGCONFIG" = x"yes" -a x"$OBJC_LIB_FLAG" = x""; then
        PKG_CHECK_MODULES([libobjc], [libobjc >= 2], [
            dnl we already know that this
            AS_VAR_SET([libobjc_SUPPORTS_ABI20], ["yes"])
        ], [
            PKG_CHECK_EXISTS([libobjc], [
                PKG_CHECK_MODULES([libobjc], [libobjc])
            ])
        ])
    fi
])


AC_DEFUN([GS_OBJC_LIB_FLAG], [
    AC_MSG_CHECKING(for the flag to link libobjc)
    AC_ARG_WITH([objc-lib-flag],
        [AS_HELP_STRING([--with-objc-lib-flag], [
            Specify a different flag to link libobjc (the Objective-C runtime
            library).  The default is -lobjc.  In some situations you may have
            multiple versions of libobjc installed and if your linker supports
            it you may want to specify exactly which one must be used; for
            example on GNU/Linux you should be able to use
            --with-objc-lib-flag=-l:libobjc.so.1
            to request libobjc.so.1 (as opposed to, say, libobjc.so.2) to be
            linked.
        ])],,
        [with_objc_lib_flag=]"")
    AS_VAR_SET([OBJC_LIB_FLAG], [${with_objc_lib_flag}])
    AC_SUBST(OBJC_LIB_FLAG)
    if test x"${with_objc_lib_flag}" = x""; then
        effective_flag=-lobjc
    else
        effective_flag=${with_objc_lib_flag}
    fi
    AC_MSG_RESULT(${effective_flag})
])

AC_DEFUN([GS_CHECK_OBJC_RUNTIME], [
    AC_REQUIRE([AC_CANONICAL_TARGET])
    AC_REQUIRE([GS_OBJ_DIR])
    AC_REQUIRE([GS_CHECK_CC_IS_CLANG])
    AC_REQUIRE([GS_CUSTOM_OBJC_RUNTIME_DOMAIN])
    AC_REQUIRE([GS_OBJC_LIB_FLAG])
    AC_REQUIRE([GS_LIBOBJC_PKG])

    dnl pkg-config makes it easy for us to configure the flags
    if test ! x"$libobjc_LIBS" = x""; then
        OBJC_CPPFLAGS=$libobjc_CFLAGS
        OBCJ_LDFLAGS=""
        OBJC_FINAL_LIB_FLAG=$libobjc_LIBS
    dnl we need to invest more smarts if
    elif test ! x"$gs_cv_libobjc_domain" = x""; then
        if test x"$gs_cv_libobjc_domain" = x"SYSTEM"; then
            GNUSTEP_LDIR="$GNUSTEP_SYSTEM_LIBRARIES"
            GNUSTEP_HDIR="$GNUSTEP_SYSTEM_HEADERS"
            gs_cv_objc_tools="$GNUSTEP_SYSTEM_TOOLS"
        elif test x"$gs_cv_libobjc_domain" = x"NETWORK"; then
            GNUSTEP_LDIR="$GNUSTEP_NETWORK_LIBRARIES"
            GNUSTEP_HDIR="$GNUSTEP_NETWORK_HEADERS"
            gs_cv_objc_tools="$GNUSTEP_NETWORK_TOOLS"
        elif test x"$gs_cv_libobjc_domain" = x"LOCAL"; then
            GNUSTEP_LDIR="$GNUSTEP_LOCAL_LIBRARIES"
            GNUSTEP_HDIR="$GNUSTEP_LOCAL_HEADERS"
            gs_cv_objc_tools="$GNUSTEP_LOCAL_TOOLS"
        elif test x"$gs_cv_libobjc_domain" = x"USER"; then
            GNUSTEP_LDIR="$GNUSTEP_USER_LIBRARIES"
            GNUSTEP_HDIR="$GNUSTEP_USER_HEADERS"
            gs_cv_objc_tools="$GNUSTEP_USER_TOOLS"
        fi
        if  test x"$GNUSTEP_IS_FLATTENED" = x"yes"; then
            GNUSTEP_LDIR="$GNUSTEP_LDIR/$gs_cv_obj_dir"
            GNUSTEP_HDIR="$GNUSTEP_HDIR/$LIBRARY_COMBO"
        fi
        gs_cv_objc_incdir=$GNUSTEP_HDIR
        gs_cv_objc_libdir=$GNUSTEP_LDIR
        # The following are needed to compile the test programs
        OBJC_CPPFLAGS="$CPPFLAGS $INCLUDES -I$gs_cv_objc_incdir"
        OBJC_LDFLAGS="$LDFLAGS $LIB_DIR -L$gs_cv_objc_libdir"
        OBJC_FINAL_LIB_FLAG="$OBJC_LIB_FLAG"

        # And the following to execute them
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$gs_cv_objc_libdir"
        export LD_LIBRARY_PATH
        # Need to also add the Tools library on mingw
        case $host_os in
            *mingw32* )
            PATH=$PATH:$gs_cv_objc_tools;;
            * )
            ;;
        esac
    fi
    if test x"$OBJC_FINAL_LIB_FLAG" = x""; then
        OBJC_FINAL_LIB_FLAG="-lobjc"
    fi
    OBJC_LDFLAGS="$OBJC_LDFLAGS $OBJC_FINAL_LIB_FLAG"
    saved_CFLAGS="$CFLAGS"
    saved_LIBS="$LIBS"
    CFLAGS="$CFLAGS -x objective-c -I$srcdir $OBJC_CPPFLAGS $OBJC_LDFLAGS"
    if test "$OBJC_RUNTIME_LIB" = "gnu"; then
        if test x"$CLANG_CC" = x"yes"; then
            CFLAGS="$CFLAGS -fobjc-runtime=gcc"
        fi
        CFLAGS="$CFLAGS -DGNU_RUNTIME"
    elif test "$OBJC_RUNTIME_LIB" = "nx"; then
        CFLAGS="$CFLAGS -DNeXT_RUNTIME"
    elif test "$OBJC_RUNTIME_LIB" = "apple"; then
        CFLAGS="$CFLAGS -DAPPLE_RUNTIME"
    fi
    OBJCRT="$OBJC_FINAL_LIB_FLAG"
])

AC_DEFUN([_GS_HAVE_OBJC_LOAD], [
    AC_REQUIRE([GS_CHECK_OBJC_RUNTIME])
    AC_CHECK_FUNC([__objc_load])
])

AC_DEFUN([GS_CHECK_RUNTIME_ABI20_SUPPORT], [
    AC_REQUIRE([GS_CHECK_OBJC_RUNTIME])
    AC_REQUIRE([_GS_HAVE_OBJC_LOAD])
    AC_CACHE_CHECK([whether runtime library supports the gnustep-2.0 ABI],
        [gs_cv_libobjc_abi_20], [
            if test x"$libobjc_SUPPORTS_ABI20" = x""; then
                gs_cv_libobjc_abi_20=$ac_cv_func___objc_load
            else
                gs_cv_libobjc_abi_20=$libobjc_SUPPORTS_ABI20
            fi
    ])
    AS_VAR_SET([libobjc_SUPPORTS_ABI20], [${gs_cv_libobjc_abi_20}])
])