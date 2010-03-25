CC	= cc
CFLAGS  = -O
LIBS	= -lmalloc -lsocket -lnsl_s -lc
OFILES	= r_newprod.o infp.o factor.o version.o lex.yy.o
RFILES	= Info Initial r_newprod.dat r_newprod.doc README
RDIR	= ../../prod.sco/node
RDIR2   = ../../../prod.sco/node
DEFS	= -DSYSV -DSVR3 -DSCO -DL_ENDIAN

all: ../Initial remote_newprod ../r_newprod.dat ../r_newprod.doc ../README

remote_newprod:	$(OFILES)
	$(CC) $(CFLAGS) $(DEFS) -o remote_newprod $(OFILES) $(LIBS)

infp.o:	../infp.c ../infp.h
	$(CC) $(CFLAGS) $(DEFS) -c ../infp.c

factor.o:	../factor.c ../infp.h
	$(CC) $(CFLAGS) $(DEFS) -c ../factor.c

version.o:      ../version.c ../../../.version
	sh -c '$(CC) $(CFLAGS) $(DEFS) -c ../version.c -DVERSION="\"`ksh version`\""'

r_newprod.o: ../r_newprod.c ../../newprod/req.h
	$(CC) $(CFLAGS) $(DEFS) -I../../newprod -c ../r_newprod.c

lex.yy.o:	../../newprod/addr.lex
	lex -t ../../newprod/addr.lex > ../lex.yy.c
	$(CC) $(CFLAGS) $(DEFS) -c ../lex.yy.c


release: ../Initial remote_newprod ../r_newprod.dat ../r_newprod.doc ../README
#	ksh version 3
	make version.o
	make 
	strip remote_newprod
	chmod 750 remote_newprod
	( cd .. ; find $(RFILES) -print | cpio -pvmd $(RDIR))
	echo remote_newprod | cpio -pvmd $(RDIR2)
	touch release

clean:
	rm -f $(OFILES) remote_newprod *.dbg core
