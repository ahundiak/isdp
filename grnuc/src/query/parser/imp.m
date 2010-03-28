SOURCE
sql.y

SRC
$(GRNUC)/src/query/parser

LIB
$(GRLIB)/lib/sql.o

INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

POST_SPECIAL
$(yacc_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/sql.y : $?"; fi
	@echo "\t$(SRC)/sql.y -> sql.c"
	@yacc $(SRC)/sql.y
	@sed "s/yy/query_yy/g" y.tab.c | sed "s/YY/query_YY/g" > sql.c
	@echo "\tsql.c -> sql.o"
	@$(CC) -c $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) sql.c
	@rm y.tab.c sql.c
	@echo 
END_SPECIAL
