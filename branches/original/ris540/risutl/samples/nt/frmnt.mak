#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

# Nmake macros for building Windows 32-Bit apps

!include <ntwin32.mak>

RISDIR=c:\Program Files\risdp
SHAMROCKDIR=c:\Program Files\shamrock
MSTOOLSDIR=c:\msvc20

LIBS=\
	"$(RISDIR)\lib\risforms.lib" \
	"$(SHAMROCKDIR)\lib\shamrock.lib" \
	"$(MSTOOLSDIR)\lib\advapi32.lib"

IPATH=\
	-I"$(RISDIR)\include" \
	-I"$(SHAMROCKDIR)\include"

all: frmsamp1.exe frmsamp2.exe

.c.exe:
	@echo Making $@
    @$(cc) -c $(IPATH) $(cdebug) $(cflags) $(cvars) $*.c
    @$(link) $(linkdebug) $(guiflags) -ignore:505 -out:$@ $*.obj $(guilibsdll) $(LIBS)
    @del $*.obj
