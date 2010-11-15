#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

RISDP=/usr/ip32/ris/risdp

IPATH=$(RISDP)/include

LIBS=$(RISDP)/lib/rislduld.a \
     $(RISDP)/lib/ris.a \
     -lc_s -lmalloc -lsocket -lUMS

all: lodsamp1 lodsamp2 lodsamp3 lodsamp4 lodsamp5 lodsamp6

.c:
	@echo
	@echo "\tMaking $@"
	@cc -o $@ -I$(IPATH) $@.c $(LIBS)
