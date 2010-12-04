# Process this file with autoconf to create configure.

AC_PREREQ(2.59)

AC_INIT([isdpbase], [0.1], [ahundiak@gmail.com])

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([aux])

AC_CONFIG_HEADERS([config.h:config-h.in])


AM_INIT_AUTOMAKE([1.9 foreign])

AC_PROG_CC
AC_PROG_LIBTOOL

AC_CHECK_HEADERS([math.h])
AC_CHECK_HEADERS([string.h strings.h], [break])

AC_CHECK_FUNCS([strrchr])

AC_CONFIG_FILES([exec/Makefile Makefile])
AC_OUTPUT
