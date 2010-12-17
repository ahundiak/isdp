SRC=/usr2/nfm352/src/dbasrv/nfm/
INC=/usr2/nfm352/src/dbasrv/inc
#ACFLAGS=-ansi -DSYSV -O3 -D__cpu_c400__ -Atarg=c400 -DRIS5
ASFLAGS=
PROC=
TARG=
CC=/opt/SUNWspro/bin/cc
ARCHIVE=nfm_calls.a
dba=dba

CFLAGS= -Disl -DRIS5  -I/usr2/nfm352/src/dbasrv/inc -I/usr2/nfm352/src/include -I/opt/ingr/xformsdp/xfi/include   -I/opt/ingr/ris/risdp/include  -I/opt/ingr/include  -I/usr/openwin/include 
$(dba) : \
 dbnfm.o \
 e_nfm.o \
 i_nfm.o \
 nfm_util.o \
 reg_nfm.o \
 s_nfm.o

$(ARCHIVE) : $(dba)
	ar ruv $(ARCHIVE) $(dba)

 dbnfm.o : $(SRC)dbnfm.c 
	$(CC) ${ACFLAGS} ${CFLAGS}   ${PROC} ${TARG} -c $(SRC)dbnfm.c

 e_nfm.o : $(SRC)e_nfm.c 
	$(CC) ${ACFLAGS} ${CFLAGS}   ${PROC} ${TARG} -c $(SRC)e_nfm.c

 i_nfm.o : $(SRC)i_nfm.c 
	$(CC) ${ACFLAGS} ${CFLAGS}   ${PROC} ${TARG} -c $(SRC)i_nfm.c

 nfm_util.o : $(SRC)nfm_util.c 
	$(CC) ${ACFLAGS} ${CFLAGS}   ${PROC} ${TARG} -c $(SRC)nfm_util.c

 reg_nfm.o : $(SRC)reg_nfm.c 
	$(CC) ${ACFLAGS} ${CFLAGS}   ${PROC} ${TARG} -c $(SRC)reg_nfm.c

 s_nfm.o : $(SRC)s_nfm.c 
	$(CC) ${ACFLAGS} ${CFLAGS}   ${PROC} ${TARG} -c $(SRC)s_nfm.c
