#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.59])
AC_INIT([makefoo-autoconf-test],[0.0.1],[z.zagorski@gmail.com])
AC_CONFIG_AUX_DIR([../../autoconf_helpers])
AC_CONFIG_SRCDIR([Makefile.in])

m4_include([../../makefoo.m4])
AC_MAKEFOO

# Checks for programs.
AC_PROG_CXX
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_RANLIB
AC_CONFIG_FILES([Makefile libbar-config libbar.pc])
AC_OUTPUT

