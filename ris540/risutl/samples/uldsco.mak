#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

RISDP=/usr/ip32/ris/risdp

IPATH=$(RISDP)/include

LIBS=$(RISDP)/lib/rislduld.a \
     $(RISDP)/lib/ris.a \
     -lc_s -lmalloc -lsocket -lUMS

all: uldsamp1 uldsamp2 uldsamp3 

.c:
	@echo
	@echo "\tMaking $@"
	@cc -o $@ -I$(IPATH) $@.c $(LIBS)
