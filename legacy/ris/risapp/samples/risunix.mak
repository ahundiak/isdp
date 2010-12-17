#
#Copyright 1993, Intergraph Corporation, All Rights Reserved
#
#
#	Note: This is UNIX MAKE style makefile (make -f risunix.mak)
#

SHELL=/bin/ksh
.SUFFIXES: .rc

#
#	MACROS set for risunix.mak
#
RISDIR=$(INGRHOME)/ris/risdp
RISCPP=$(RISDIR)/bin/riscpp

fast: \
		async1 \
		async2 \
		asynctrn \
		blob1 \
		blob2 \
		cleanup \
		datetime \
		dclar \
		dynamic \
		extern \
		loccli \
		multiple \
		setup \
		static \
		sharedic \
		secure \
		transact \
		union

.rc:
	@echo 	"\nMaking $@"
	@$(RISCPP) -o $* $*.rc 
