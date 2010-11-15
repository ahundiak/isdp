#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

RISDP=/usr/ip32/ris/risdp

IFLAGS= \
	-I/usr/openwin/include \
	-I$(RISDP)/include

LIBS= \
	$(RISDP)/lib/xrisforms.a \
	$(RISDP)/lib/ris.a \
	-lX11 -lXFI -lXFS -lc -lUMS

all: xfrmsamp1 xfrmsamp2
xfrmsamp1.c: $(RISDP)/include/risforms.h $(RISDP)/include/ris.h
xfrmsamp2.c: $(RISDP)/include/risforms.h $(RISDP)/include/ris.h

.c:
	@echo
	@echo "\tMaking $@"
	@acc $(IFLAGS) -o $@ $@.c -L/usr/openwin/lib -L/usr/5lib $(LIBS)
