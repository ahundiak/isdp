#
#Copyright 1993, Intergraph Corporation, All Rights Reserved
#
#
#	Note: This is Microsoft NMAKE style makefile (nmake -f risnt.mak)
#
.SUFFIXES: .rc

!include <ntwin32.mak>

#
#	MACROS set for risnt.mak
#
RISDIR=c:\Program Files\risdp
RISCPP="$(RISDIR)\bin\riscpp.exe"

fast: \
		async1.exe \
		async2.exe \
		asynctrn.exe \
		blob1.exe \
		blob2.exe \
		cleanup.exe \
		datetime.exe \
		dclar.exe \
		dynamic.exe \
		extern.exe \
		loccli.exe \
		multiple.exe \
		setup.exe \
		static.exe \
		sharedic.exe \
		securent.exe \
		transact.exe \
		union.exe

.rc.exe:
	@echo. 
	@echo 	Making $@
	@$(RISCPP) $*.rc 
	@-del $*.obj
