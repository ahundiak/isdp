#
# Copyright 1993, Intergraph Corporation, All Rights Reserved
#

SHELL=/bin/ksh

.SUFFIXES: .rc

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
	@case $$(uname -rs) in \
		"SunOS 5."?) RISDIR=$${INGRHOME:=/opt/ingr}/ris ;; \
		*) RISDIR=/usr/ip32/ris ;; \
	esac; \
	$$RISDIR/risdp/bin/riscpp -o $* $*.rc 

