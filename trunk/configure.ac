#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.59])
AC_INIT([igexnuc], [3.4.11.0], [igsupport])

AC_CONFIG_SRCDIR([configure.ac])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([auxx])

AC_CONFIG_HEADERS([config.h:config-h.in])

# Do the config stuff before this
AM_INIT_AUTOMAKE([1.9 foreign])
AM_SILENT_RULES
# AM_PROG_LEX

# Checks for programs.
AC_PROG_AWK
AC_PROG_CC
AC_PROG_CC_STDC
AC_PROG_YACC
AM_PROG_LEX

# Libtool
LT_PREREQ([2.2.6])
LT_INIT([dlopen win32-dll pic-only disable-static])

# ENV variable available as @DISPLAY@
# AC_SUBST([BS])
# AC_SUBST([UMS])
# AC_SUBST([EXNUC])
# AC_SUBST([LIBXC])
# AC_SUBST([FORMS])

AC_SUBST([IG_CPP])
AC_SUBST([IG_OPP])
AC_SUBST([IG_OPP_FLAGS])
AC_SUBST([IG_OPP_DEFINES])
AC_SUBST([IG_OPP_INCLUDES])

# Checks for libraries.
# FIXME: Replace `main' with a function in `-ldl':
# AC_CHECK_LIB([dl], [main])

# Checks for header files.
AC_CHECK_HEADERS([stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL

# Checks for library functions.
AC_FUNC_MALLOC
AC_FUNC_REALLOC
AC_CHECK_FUNCS([memset strchr])

# Packages
PKG_CHECK_MODULES([glib_DEPS],   [glib-2.0 >= 2.24.1])
PKG_CHECK_MODULES([gmodule_DEPS],[glib-2.0 >= 2.24.1 gmodule-2.0 >= 2.24.1])
PKG_CHECK_MODULES([gio_DEPS],    [gio-2.0 >= 2.24.1])

# Output
AC_CONFIG_FILES([
  xforms/source/xfi/src10/Makefile
])

AC_OUTPUT
