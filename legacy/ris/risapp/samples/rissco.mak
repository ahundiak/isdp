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
RISDIR=/usr/ip32/ris/risdp
RISCPP=$(RISDIR)/bin/riscpp
LIBS=\
        $(RISDIR)/lib/ris.a \
         -lnsl_s -lc_s -lmalloc -lUMS -lsocket
IPATH=\
        -I$(RISDIR)/include


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
	@$(RISCPP) $(IPATH) -o $* $*.rc $(LIBS)
