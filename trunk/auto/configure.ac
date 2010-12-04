# Process this file with autoconf to create configure.

AC_PREREQ(2.59)

AC_INIT([isdpbase], [0.1], [ahundiak@gmail.com])

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([auxx])

# Assume need this before othe AM macros

AM_INIT_AUTOMAKE([1.9 foreign])

# Changed from AC for automake, AM does not work
AC_CONFIG_HEADERS([config.h:config-h.in])

# Indicates want support for dlopen
AC_LIBTOOL_DLOPEN

AC_PROG_CC
AC_PROG_CC_STDC

AC_PROG_LIBTOOL

AC_PROG_YACC
AM_PROG_LEX

# Syntax is wrong
# AC_DEFINE([ISDP],[1])

# ENV variable available as @DIDPLAY@
# AC_SUBST([DISPLAY])

AC_CHECK_HEADERS([math.h])
AC_CHECK_HEADERS([string.h strings.h], [break])

AC_CHECK_FUNCS([strrchr])

AC_CONFIG_FILES([exec/Makefile Makefile])

AC_OUTPUT
