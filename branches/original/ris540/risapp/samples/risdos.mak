
#Copyright 1993, Intergraph Corporation, All Rights Reserved
#

#
#		SAMPLE MAKEFILE FOR DOS TO GENERATE EXECUTABLE FROM *.RC FILE
#		-------------------------------------------------------------
#
# Steps:
#	1.	Set environment variable RISDP to the directory where RIS DEVELOPEMENT 
#		PLATFORM was installed.
#
# 	2.	This makefile is also dependent on following environment variables:
#		 UMSDIR  (UMS directory)
#		 HIGHCDIR (HIGHC compiler directory)
#		 PHARLAPDIR (PHARLAP extender directory)
# 		Each of the above variables indicate their respective installation 
#		directory.
#
#	Note: This is MetaWare Mwmake style makefile (mwmake -f risdos.mak)
#

#
#	MACROS set for risdos.mak
#
RISCPP=$(RISDP)\bin\riscpp.exe
RISLIB=$(RISDP)\lib\ris.lib
UMSLIB=$(UMSDIR)\lib\ums.lib

CC=$(HIGHCDIR)\bin\hc386
DOSLIB=$(PHARLAPDIR)\bin\386lib.exe
BIND=$(PHARLAPDIR)\bin\bind386.exe
LINK=$(PHARLAPDIR)\bin\386link.exe
RUN386B=$(PHARLAPDIR)\bin\run386b.exe

IPATH= -I$(RISDP)\include 

CFLAGS=-c -g \
		-DDOS \
		-386 \
		-fsoft \
		-Hoff=Char_default_unsigned \
		-Hnocopyr \
		-Hunixerr \
		-Hoff=Recognize_library

CLIBS=-lib $(HIGHCDIR)\small\hc386 \
 		$(HIGHCDIR)\small\hcsoft \
		$(HIGHCDIR)\small\hcna 
LFLAGS= -nomap \
	-stack 100000 \
	-twocase \
	-cvsym \
	-maxreal 0ffffh


fast:   async1.exe \
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
	sharedic.exe \
	secure.exe \
	static.exe \
	setup.exe \
	transact.exe \
	union.exe

%.exe   : %.rc
	@echo 	Making $@
	@$(RISCPP) $*.rc
	@echo $(CDEBUG) > cargs
	@echo $(CFLAGS) >> cargs
	@echo $(IPATH) >> cargs
	@$(CC) @cargs $*.c
	@-del cargs

	@echo $(CLIBS) > linkarg.lnk
	@echo $(LFLAGS) >> linkarg.lnk
	@echo -lib $(RISLIB) $(UMSLIB) >> linkarg.lnk
	@$(LINK) @linkarg.lnk $*.obj -exe $*.exp
	@-del linkarg.lnk

	@$(BIND) $(RUN386B) $*
	@-del $*.c
	@-del $*.obj
	@-del $*.exp

