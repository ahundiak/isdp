#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

RISDP=/usr/ip32/ris/risdp

IFLAGS= \
	-I$(RISDP)/include

LIBS= \
	$(RISDP)/lib/xrisforms.a \
	$(RISDP)/lib/ris.a \
	-lXFI -lXFS_s -lX11_s -lmath -linc -lnsl_s -lbsd -lmalloc -lc_s -lUMS

all: xfrmsamp1 xfrmsamp2
xfrmsamp1.c: $(RISDP)/include/risforms.h $(RISDP)/include/ris.h
xfrmsamp2.c: $(RISDP)/include/risforms.h $(RISDP)/include/ris.h

.c:
	@echo
	@echo "\tMaking $@"
	@acc $(IFLAGS) -o $@ $@.c $(LIBS)
