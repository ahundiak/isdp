#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

RISDP=/usr/ip32/ris/risdp

IFLAGS= \
	-I$(RISDP)/include

LIBS= \
	$(RISDP)/lib/risforms.a \
	$(RISDP)/lib/ris.a \
	-lforms_s -ltools_s -lm -linc -lnsl_s -lbsd -lmalloc -lc_s -lUMS

all: frmsamp1 frmsamp2
frmsamp1.c: $(RISDP)/include/risforms.h $(RISDP)/include/ris.h
frmsamp2.c: $(RISDP)/include/risforms.h $(RISDP)/include/ris.h

.c:
	@echo
	@echo "\tMaking $@"
	@acc $(IFLAGS) -o $@ $@.c $(LIBS)
