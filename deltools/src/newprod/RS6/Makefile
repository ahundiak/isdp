RFILES	= newprod delserve
RDIR	= ../../../prod.rs6
CFLAGS	= -O
#CFLAGS	= -g
OBJS	= main.o proddate.o menu.o tape.o fsys.o getfile.o install.o prompt.o \
	  net.o cksum.o moveprod.o sh.o lk.o pgmenu.o version.o keyfile.o \
	  walk.o fslist.o lex.yy.o access.o
DSOBJS	= delserve.o cksum.o version.o keyfile.o access.o lex.yy.o
LIBS	= -lcurses -lbsd
DEFS	= -DNEW_ARCHITECTURES

all: $(RFILES)

newprod: $(OBJS)
	$(CC) $(CFLAGS) -s -o newprod $(OBJS) $(LIBS)
#	$(CC) $(CFLAGS) -o newprod $(OBJS) $(LIBS)

delserve:	$(DSOBJS)
	$(CC) $(CFLAGS) -s -o delserve $(DSOBJS) $(LIBS)
#	$(CC) $(CFLAGS) -o delserve $(DSOBJS) $(LIBS)

release: ../../../.version $(RFILES)
#	ksh version 3
	make version.o
	make
	ls -ls $(RFILES)
	chmod 755 $(RFILES)
	chown root $(RFILES)
	chgrp staff $(RFILES)
	chmod u+s delserve
	make shipit
	touch release

shipit:
	find $(RFILES) -print | cpio -pvmd $(RDIR)

.c.o:
	$(CC) $(CFLAGS) $(DEFS) -c $<

version.o:	../version.c ../../../.version
	sh -c '$(CC) $(CFLAGS) -c ../version.c -DVERSION="\"`ksh version`\""'

delserve.o:	../delserve.c ../req.h
	$(CC) $(CFLAGS) $(DEFS) -c ../delserve.c
net.o:		../req.h ../net.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../net.c
main.o:		../main.c ../defs.h ../dipdef.h
	$(CC) $(CFLAGS) $(DEFS) -c ../main.c
cksum.o:	../cksum.c
	$(CC) $(CFLAGS) $(DEFS) -c ../cksum.c
lk.o:		../lk.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../lk.c
keyfile.o:	../keyfile.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../keyfile.c
fsys.o:		../fsys.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../fsys.c
fslist.o:	../fslist.c
	$(CC) $(CFLAGS) $(DEFS) -c ../fslist.c
getfile.o:	../getfile.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../getfile.c
proddate.o:	../proddate.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../proddate.c
menu.o:		../menu.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../menu.c
pgmenu.o:	../pgmenu.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../pgmenu.c
install.o:	../install.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../install.c
prompt.o:	../prompt.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../prompt.c
moveprod.o:	../moveprod.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../moveprod.c
tape.o:		../tape.c ../defs.h
	$(CC) $(CFLAGS) $(DEFS) -c ../tape.c
sh.o:		../sh.c
	$(CC) $(CFLAGS) $(DEFS) -c ../sh.c
walk.o:		../walk.c
	$(CC) $(CFLAGS) $(DEFS) -c ../walk.c
lex.yy.o:	../addr.lex
	lex -t ../addr.lex > ../lex.yy.c
	$(CC) $(CFLAGS) $(DEFS) -c ../lex.yy.c
access.o:	../access.c
	$(CC) $(CFLAGS) $(DEFS) -c ../access.c

clean:
	rm -f $(OBJS) $(DSOBJS) $(RFILES)
