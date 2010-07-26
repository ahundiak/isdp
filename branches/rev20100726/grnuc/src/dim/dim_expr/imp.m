SOURCE
parse.l

CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_expr

LIB
$(GRLIB)/lib/dim_expr.o

INCLUDE
$(INGRHOME)/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

POST_SPECIAL
parse.c: $(SRC)/parse.l
	lex $(SRC)/parse.l
	sed "s/yy/dm/g" < lex.yy.c > parse.c
	rm lex.yy.c
END_SPECIAL
