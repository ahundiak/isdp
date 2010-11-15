
#
#  Copyright 1993, Intergraph Corporation, All Rights Reserved
#

CC=cc +z

RISDP=/usr/ip32/ris/risdp

IPATH=\
	-I/usr/include \
	-I$(RISDP)/include

LIBS=\
	$(RISDP)/lib/rislduld.a \
	$(RISDP)/lib/ris.a \
	-lc -lV3 -lUMS

all: lodsamp1 lodsamp2 lodsamp3 lodsamp4 lodsamp5 lodsamp6

.c:
	@echo
	@echo "\tMaking $@"
	@$(CC) -o $@ $(IPATH) $@.c -L/usr/lib $(LIBS)
