#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

SHELL=/bin/ksh

CC=cc -KPIC

RISDP=$(INGRHOME)/ris/risdp

IPATH= \
	-I/usr/openwin/include \
	-I$(RISDP)/include \
	-I$(INGRHOME)/xformsdp/xfi/include

LIBS= \
	$(RISDP)/lib/xrisforms.a \
	$(RISDP)/lib/ris.a \
	-lX11 -lXFI -lXFS -lm -lc -lsocket -lnsl

all: xfrmsamp1 xfrmsamp2

xfrmsamp1.c: $(RISDP)/include/risforms.h $(RISDP)/include/ris.h
xfrmsamp2.c: $(RISDP)/include/risforms.h $(RISDP)/include/ris.h

.c:
	@if [ -z "$$INGRHOME" ]; then \
		print "NOTICE: Please set the INGRHOME \c"; \
		print "environment variable and try again."; \
	else \
		print "\n\tMaking $@"; \
		$(CC) -o $@ $@.c $(IPATH) $(LIBS); \
	fi
