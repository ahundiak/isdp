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

all: uldsamp1 uldsamp2 uldsamp3 

.c:
	@echo
	@echo "\tMaking $@"
	@$(CC) -o $@ $(IPATH) $@.c -L/usr/5lib $(LIBS)
