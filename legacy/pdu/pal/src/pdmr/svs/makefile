IPATH =  \
        -I$(PDU)/include \
        -I$(PDM)/include \
        -I$(EXNUC)/include \
        -I$(GRNUC)/include \
        -I$(NFM)/include \
        -I$(DBA)/include

CC = acc

CFLAGS = -g

#ifdef sparc
COPT = -Xa -PIC
#else
COPT = $(COMP_OPT)
#endif

# Object files

c_objects = \
	svs.o \
	svswrk.o \
	condy.o \
	condl.o \
	viewy.o \
	viewl.o

objects = \
	$(c_objects)

#objects : svs.o svswrk.o condy.o condl.o viewy.o viewl.o 

# src group targets

objects:	$(objects)

svs.o : svs.c
	acc -DRISV$(RISVER) $(COPT) -c svs.c

svswrk.o : svswrk.c
	acc $(COPT) $(IPATH) -c svswrk.c

condy.o : condy.y
	yacc -dvlt condy.y
	mv y.tab.h condy.h
	sed -e 's/yy/PDU_c_yy/g' y.tab.c > out
	sed -e '1 i\
#include "header.h"' out > condy.c
	rm out
	acc -c $(COPT) condy.c

viewy.o : viewy.y
	yacc -dvlt viewy.y
	mv y.tab.h viewy.h
	sed -e 's/yy/PDU_v_yy/g' y.tab.c > out
	sed -e '1 i\
#include "header.h"' out > viewy.c
	rm out
	acc -c $(COPT) viewy.c

condl.o : condl.l
	lex -v condl.l
	sed -e '1 i\
#include "condy.h"' lex.yy.c > out
	sed -f csedcom out > condl.c	
	rm out
	acc -c $(COPT) condl.c

viewl.o : viewl.l
	lex -v viewl.l
	sed -e '1 i\
#include "viewy.h"' lex.yy.c > out
	sed -f vsedcom out > viewl.c	
	rm out
	acc -c $(COPT) viewl.c

DIR = $(PDU)/config/dload/prod/pdu/pal/src/pdmr/svs

PDUsvs.s:	$(objects_TARGET)
	@echo "Making PDUsvs.s for reactive loading."
	@echo
	@echo "Moving condl.o, condy.o, viewl.o, and viewy.o to extention .X"
	@mv condl.o condl.X
	@mv condy.o condy.X
	@mv viewl.o viewl.X
	@mv viewy.o viewy.X
	@-mkstubs -o PDUsvs.s -t"Pdu:pdu/pal/src/pdmr/svs" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from pal/src/pdmr/svs directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubsvs.o
	@echo "Moving condl.X, condy.X, viewl.X, and viewy.X to extention .o"
	@mv condl.X condl.o
	@mv condy.X condy.o
	@mv viewl.X viewl.o
	@mv viewy.X viewy.o
	@echo "Copying condl.o, condy.o, viewl.o and viewy.o to $(PDU)/config/dload/init."
	@cp condl.o $(PDU)/config/dload/init
	@cp condy.o $(PDU)/config/dload/init
	@cp viewl.o $(PDU)/config/dload/init
	@cp viewy.o $(PDU)/config/dload/init
	@echo "Compiling PDUstubsvs.o from PDUsvs.s"
	@as -o PDUstubsvs.o PDUsvs.s
