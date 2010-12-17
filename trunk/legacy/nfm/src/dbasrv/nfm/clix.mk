SRC=/usr2/dba/source/nfm/
INC=/usr2/dba/source/inc/
ACFLAGS=-ansi -DSYSV -O3 -D__cpu_c400__ -Atarg=c400 -DRIS5
ASFLAGS=
PROC=
TARG=

CFLAGS= -DHANGUL -D_INGR_EXTENSIONS  -I/usr2/dba/source/inc   -I/usr/ip32/forms/include     -I/usr2/ip32/ris/risdp/include  -I/usr/ip32/ums/include  -I/usr/ip32/nfmdp/include


dba : \
 dbnfm.o \
 e_nfm.o \
 i_nfm.o \
 nfm_util.o \
 reg_nfm.o \
 s_nfm.o


 dbnfm.o : $(SRC)dbnfm.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nfm -DCOMBINED_MAKE ${PROC} ${TARG} -c $(SRC)dbnfm.c

 e_nfm.o : $(SRC)e_nfm.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nfm -DCOMBINED_MAKE ${PROC} ${TARG} -c $(SRC)e_nfm.c

 i_nfm.o : $(SRC)i_nfm.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nfm -DCOMBINED_MAKE ${PROC} ${TARG} -c $(SRC)i_nfm.c

 nfm_util.o : $(SRC)nfm_util.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nfm -DCOMBINED_MAKE ${PROC} ${TARG} -c $(SRC)nfm_util.c

 reg_nfm.o : $(SRC)reg_nfm.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nfm -DCOMBINED_MAKE ${PROC} ${TARG} -c $(SRC)reg_nfm.c

 s_nfm.o : $(SRC)s_nfm.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nfm -DCOMBINED_MAKE ${PROC} ${TARG} -c $(SRC)s_nfm.c
