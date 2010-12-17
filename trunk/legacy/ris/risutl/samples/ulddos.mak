#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
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
#	Note: This is Microsoft NMAKE style makefile (nmake -f risdos.mak)
#

#
#	MACROS set for risdos.mak
#
RISLIB=$(RISDP)\lib\ris.lib
LDULDLIB=$(RISDP)\lib\rislduld.lib
UMSLIB=$(UMSDIR)\lib\ums.lib

CC=$(HIGHCDIR)\bin\hc386
DOSLIB=$(PHARLAPDIR)\bin\386lib.exe
BIND=$(PHARLAPDIR)\bin\bind386.exe
LINK=$(PHARLAPDIR)\bin\386link.exe
RUN386B=$(PHARLAPDIR)\bin\run386b.exe

CFLAGS=-c -g \
		-DDOS \
		-386 \
		-fsoft \
		-Hoff=Char_default_unsigned \
		-Hnocopyr \
		-Hunixerr \
		-Hoff=Recognize_library

LFLAGS=-lib $(HIGHCDIR)\small\hc386 \
 		$(HIGHCDIR)\small\hcsoft \
		$(HIGHCDIR)\small\hcna \
		-386 \
		-nobanner \
		-nomap \
		-stack 100000 \
		-nowarn \
		-twocase \
		-cvsym \
		-maxreal 0ffffh

IPATH= -I$(RISDP)\include

fast: \
	uldsamp1.exe \
	uldsamp2.exe \
	uldsamp3.exe

.c.exe:
	@echo. 
	@echo 	Making $@
	@$(CC) @<<
$(CDEBUG) $(CFLAGS) $(IPATH) $*.c
<<
	@$(LINK) @<<
$*.obj
$(LFLAGS)
-lib $(RISLIB) $(LDULDLIB) $(UMSLIB)
-exe $*.exp
<<
	@$(BIND) $(RUN386B) $*
	@-del $*.obj
	@-del $*.exp
