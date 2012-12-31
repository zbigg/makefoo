  makefoo - gnu make more declarative
  ===================================

  makefoo is set of makefile templates that does similar
  job to automake, cmake, bakefile and other makefile generation
  tools. 

  You just declare high level description of C/C++ program
  and makefoo will build it for you.

  Features implemented:
   - declarative language for defining components
      - native C/C++ programs, static & dynamic libraries
      - static files installed in varioud places
      - test components
   - installation of these
   - making of packages
     - source distribution
     - rpm
   - integration
     - lcov
     - cppcheck
     - 
   - support one makefile for several components
   - autoconf & pkg-config integration of makefoo itself

  Platforms tested:
   - Linux 
     x86-64 gcc4.7
     i686   gcc4.4
   - Darwin, x86_64, gcc-4.2 (in-progress)
   - FreeBSD8, x86_64, gcc-4.2
   - Mingw32, i686, gcc-4.7
   - MSVS 2010 Express (in-progress)

  Features on target:
   - automatic dependency generation using gcc -MMD
   - pkg_config support as client 
   - precompiled headers
   - deb generation

  Automatic source scan for needed objects:
   - i.e each source is tagged with // uses: component name or something
     and build system create object list from that
