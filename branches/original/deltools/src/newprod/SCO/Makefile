CC	= cc
RFILES	= newprod delserve
RDIR	= ../../../prod.sco
CFLAGS	= -O
#CFLAGS	= -g
OBJS	= main.o proddate.o menu.o tape.o getfile.o fsys.o install.o prompt.o \
	  net.o cksum.o moveprod.o sh.o lk.o pgmenu.o version.o keyfile.o \
	  walk.o fslist.o lex.yy.o
DSOBJS	= delserve.o cksum.o version.o keyfile.o access.o fakesyslog.o \
	  check_sec.o sco_ts.o lex.yy.o

LIBS	= -lcurses -lmalloc -lgen -lPW -lcrypt_d -lsocket -lc -lm -lprot -lx \
          -laudit

DEFS	= -DSYSV -DSVR3 -DSCO -DNEW_ARCHITECTURES -DL_ENDIAN -DHOSTS_ACCESS \
          -DSecureWare
CPIO	= cpio

all: $(RFILES)

newprod: $(OBJS)
	$(CC) $(CFLAGS) -o newprod $(OBJS) $(LIBS)


delserve: $(DSOBJS)
	$(CC) $(CFLAGS) -o delserve $(DSOBJS) $(LIBS)

release: ../../../.version $(RFILES)
	make version.o
	make
	strip $(RFILES)
	ls -ls $(RFILES)
	chown root $(RFILES)
	chgrp sys $(RFILES)
	chmod 0755 newprod
	chmod 0111 delserve
	make shipit
	touch release

shipit:
	find $(RFILES) -print | $(CPIO) -pvmd $(RDIR)

.c.o:
	$(CC) $(CFLAGS) $(DEFS) -c $<

version.o:	../version.c ../../../.version
	sh -c '$(CC) $(CFLAGS) $(DEFS) -c ../version.c -DVERSION="\"$(VERSION)\""'
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
access.o:	../access.c ../fakesyslog.h
	$(CC) $(CFLAGS) $(DEFS) -c ../access.c
fakesyslog.o:	../fakesyslog.c ../fakesyslog.h
	$(CC) $(CFLAGS) $(DEFS) -c ../fakesyslog.c
check_sec.o:	../check_sec.c 
	$(CC) $(CFLAGS) $(DEFS) -c ../check_sec.c

sco_ts.o:	../check_sec.c 
	$(CC) $(CFLAGS) $(DEFS) -c ../sco_ts.c

lex.yy.o:	../addr.lex
	lex -t ../addr.lex > ../lex.yy.c
	$(CC) $(CFLAGS) $(DEFS) -c ../lex.yy.c

clean:
	rm -f $(OBJS) $(DSOBJS) $(RFILES) *.dbg core
