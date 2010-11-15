#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

RISDP=/usr/ip32/ris/risdp

IPATH=\
	-I$(RISDP)/include

LIBS=\
	$(RISDP)/lib/rislduld.a \
	$(RISDP)/lib/ris.a \
	-linc -lnsl_s -lc_s -lmalloc -lbsd -lUMS

all: lodsamp1 lodsamp2 lodsamp3 lodsamp4 lodsamp5 lodsamp6

.c:
	@echo
	@echo "\tMaking $@"
	@acc -o $@ $(IPATH) $@.c $(LIBS)
