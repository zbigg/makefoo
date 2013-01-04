srcdir = .
top_srcdir = .
top_builddir = .

libx_DIR     = .
libx_SOURCES = lib.c
STATIC_LIBRARIES += libx

prog_DIR      = .
prog_SOURCES  = prog.cpp
prog_LINK_DEPS = libx
PROGRAMS += prog

MAKEFOO=$(top_srcdir)/../../main.mk
MAKEFOO_USE += native
include $(MAKEFOO)

