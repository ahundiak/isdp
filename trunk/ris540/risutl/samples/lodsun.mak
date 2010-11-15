#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

CC=acc -PIC

RISDP=/usr/ip32/ris/risdp

IPATH=\
	-I/usr/5include \
	-I$(RISDP)/include

LIBS=\
	$(RISDP)/lib/rislduld.a \
	$(RISDP)/lib/ris.a \
	-lc -lUMS

all: lodsamp1 lodsamp2 lodsamp3 lodsamp4 lodsamp5 lodsamp6

.c:
	@echo
	@echo "\tMaking $@"
	@$(CC) -o $@ $(IPATH) $@.c -L/usr/5lib $(LIBS)
