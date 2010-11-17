
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

all: uldsamp1 uldsamp2 uldsamp3 

.c:
	@echo
	@echo "\tMaking $@"
	@$(CC) -o $@ $(IPATH) $@.c -L/usr/lib $(LIBS)