CFLAGS  = -O $(DEFS)
OFILES	= r_newprod.o infp.o factor.o version.o lex.yy.o
RFILES	= Info Initial r_newprod.dat r_newprod.doc README
RDIR	= ../../prod.sun/node
RDIR2   = ../../../prod.sun/node
DEFS	= -DSunOS_4

all: ../Initial remote_newprod ../r_newprod.dat ../r_newprod.doc ../README

remote_newprod:	$(OFILES)
	$(CC) $(CFLAGS) -s -o remote_newprod $(OFILES) $(LIBS)

infp.o:	../infp.c ../infp.h
	$(CC) $(CFLAGS) -c ../infp.c

factor.o:	../factor.c ../infp.h
	$(CC) $(CFLAGS) -c ../factor.c

version.o:      ../version.c ../../../.version
	sh -c '$(CC) $(CFLAGS) -c ../version.c -DVERSION="\"`ksh ./version`\""'

r_newprod.o: ../r_newprod.c ../../newprod/req.h
	$(CC) $(CFLAGS) -I../../newprod -c ../r_newprod.c

lex.yy.o:	../../newprod/addr.lex
	lex -t ../../newprod/addr.lex > ../lex.yy.c
	$(CC) $(CFLAGS) -c ../lex.yy.c
	
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
	rm -f $(OFILES) remote_newprod
