#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

# Nmake macros for building Windows 32-Bit apps

!include <ntwin32.mak>

RISDIR=c:\Program Files\risdp
MSTOOLSDIR=c:\msvc20

LIBS=\
	"$(RISDIR)\lib\rislduld.lib"  \
	"$(MSTOOLSDIR)\lib\advapi32.lib" \
	"$(MSTOOLSDIR)\lib\user32.lib"

IPATH=\
	-I"$(RISDIR)\include"

all: \
	uldsamp1.exe \
	uldsamp2.exe \
	uldsamp3.exe

.c.exe:
	@echo Making $@
    @$(cc) -c $(IPATH) $(cdebug) $(cflags) $(cvars) $*.c
    @$(link) $(linkdebug) $(conflags) -ignore:505 -out:$@ $*.obj $(conlibsdll) $(LIBS)
    @del $*.obj
