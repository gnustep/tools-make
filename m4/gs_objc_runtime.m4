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
    if test x"$GNUSTEP_HAS_PKGCONFIG" = x"yes"; then
        PKG_CHECK_MODULES([libobjc], [libobjc >= 2], [
            AS_VAR_SET([libobjc_SUPPORTS_ABI2], ["yes"])
        ], [
            PKG_CHECK_MODULES([libobjc], [libobjc])
            AS_VAR_SET([libobjc_SUPPORTS_ABI2], ["no"])
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

AC_DEFUN([GS_OBJC_RUNTIME], [
    AC_REQUIRE([GS_CUSTOM_OBJC_RUNTIME_DOMAIN])
    AC_REQUIRE([GS_OBJC_LIB_FLAG])
    AC_REQUIRE([GS_LIBOBJC_PKG])
])