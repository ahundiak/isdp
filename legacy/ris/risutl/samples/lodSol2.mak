#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

SHELL=/bin/ksh

CC=cc -KPIC

RISDP=$(INGRHOME)/ris/risdp

IPATH=\
	-I/usr/include \
	-I$(RISDP)/include

LIBS=\
	$(RISDP)/lib/rislduld.a \
	$(RISDP)/lib/ris.a \
	-lc -lsocket -lnsl

all: lodsamp1 lodsamp2 lodsamp3 lodsamp4 lodsamp5 lodsamp6

.c:
	@if [ -z "$$INGRHOME" ]; then \
		print "NOTICE: Please set the INGRHOME \c"; \
		print "environment variable and try again."; \
	else \
		print "\n\tMaking $@"; \
		$(CC) -o $@ $@.c $(IPATH) $(LIBS); \
	fi
