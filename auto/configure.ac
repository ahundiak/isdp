# Process this file with autoconf to create configure.

AC_PREREQ(2.59)

AC_INIT([isdpbase], [0.1], [ahundiak@gmail.com])

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([auxx])

# Assume need this before othe AM macros

AM_INIT_AUTOMAKE([1.9 foreign])

# Changed from AC for automake, AM does not work
AC_CONFIG_HEADERS([config.h:config-h.in])

AC_PROG_CC
AC_PROG_CC_STDC

# Shared library support
# These two are depreciated
# AC_LIBTOOL_DLOPEN
# AC_PROG_LIBTOOL
#
LT_PREREQ([2.2.6])
LT_INIT([dlopen win32-dll pic-only disable-static])

AC_PROG_YACC
AM_PROG_LEX

# Syntax is wrong
# AC_DEFINE([ISDP],[1])

# ENV variable available as @DISPLAY@
# AC_SUBST([DISPLAY])

AC_CHECK_HEADERS([math.h])
AC_CHECK_HEADERS([string.h strings.h], [break])

AC_CHECK_FUNCS([strrchr])

PKG_CHECK_MODULES([glib_DEPS],   [glib-2.0 >= 2.24.1])
PKG_CHECK_MODULES([gmodule_DEPS],[glib-2.0 >= 2.24.1 gmodule-2.0 >= 2.24.1])
PKG_CHECK_MODULES([gio_DEPS],    [gio-2.0 >= 2.24.1])

AC_CONFIG_FILES([Makefile])

AC_CONFIG_FILES([exec/Makefile])

AC_CONFIG_FILES([glib/Makefile glib/lib/Makefile glib/basic/Makefile glib/dload/Makefile])

AC_OUTPUT
