#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

SHELL=/bin/ksh

CC=cc -KPIC -xnolib

RISDP=$(INGRHOME)/ris/risdp

IPATH=\
	-I/usr/include \
	-I$(RISDP)/include

LIBS=\
	$(RISDP)/lib/rislduld.a \
	$(RISDP)/lib/ris.a \
	-lc -lsocket -lnsl

all: uldsamp1 uldsamp2 uldsamp3 

.c:
	@if [ -z "$$INGRHOME" ]; then \
		print "NOTICE: Please set the INGRHOME \c"; \
		print "environment variable and try again."; \
	else \
		print "\n\tMaking $@"; \
		$(CC) -o $@ $@.c $(IPATH) $(LIBS); \
	fi
