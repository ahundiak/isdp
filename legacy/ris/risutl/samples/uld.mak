#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

RISDP=/usr/ip32/ris/risdp

IPATH=\
	-I$(RISDP)/include

LIBS=\
	$(RISDP)/lib/rislduld.a \
	$(RISDP)/lib/ris.a \
	-lc_s -lmalloc -linc -lnsl_s -lbsd -lUMS

all: uldsamp1 uldsamp2 uldsamp3 

.c:
	@echo
	@echo "\tMaking $@"
	@acc -o $@ $(IPATH) $@.c $(LIBS)
