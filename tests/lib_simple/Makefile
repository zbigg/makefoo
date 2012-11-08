srcdir = .
top_srcdir = .
top_builddir = .

libx_SOURCES = lib.c
STATIC_LIBRARIES += libx

prog_SOURCES = prog.cpp
prog_LINK_DEPS = libx
PROGRAMS += prog

MAKEFOO=$(top_srcdir)/../../main.mk
MAKEFOO_USE += native
include $(MAKEFOO)

