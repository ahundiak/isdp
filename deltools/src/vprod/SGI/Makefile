EMTOOLS = -lmyemt
EVCFLAGS = -knr -O3 -DVPROD $(TARG)
EVLIBS = $(EMTOOLS) -lforms_s -litems_s -ltools_s -lhelp

XLIBS = -lXFI_s -lXFS_s -lX11_s
XCFLAGS = -knr -O3 $(TARG) -DSYSV -DSVR3 -DXVPROD -DVPROD -DXFORMS

SYSLIBS = -lm -lmalloc -linc -lbsd -lnsl -ldevi -lgen -lc_s

CFLAGS = $(EVCFLAGS)
EXEC = vprod

OBJS = main.o notify.o errors.o misc.o prodlist.o connect.o net.o tape.o \
	proddate.o fsys.o keyfile.o lk.o moveprod.o walk.o sh.o install.o \
	version.o def.o df.o prod_form.o spawn.o runsh.o pack_misc.o \
	group_misc.o class_form.o rm_misc.o tnote.o time_misc.o \
	factor.o infp.o expand.o multname.o fslist.o lostpeer.o 

XOBJS = main.o notify.o errors.o misc.o prodlist.o connect.o net.o tape.o \
	proddate.o fsys.o keyfile.o lk.o moveprod.o walk.o sh.o install.o \
	version.o def.o df.o prod_form.o pack_misc.o group_misc.o class_form.o \
	rm_misc.o tnote.o time_misc.o factor.o infp.o expand.o multname.o \
	fslist.o lostpeer.o xrunsh.o

MOBJS = main.o notify.o errors.o misc.o prodlist.o connect.o net.o tape.o \
	proddate.o fsys.o keyfile.o lk.o moveprod.o walk.o sh.o install.o \
	def.o df.o prod_form.o spawn.o runsh.o pack_misc.o \
	group_misc.o class_form.o rm_misc.o tnote.o time_misc.o \
	factor.o infp.o expand.o multname.o fslist.o lostpeer.o

all:	$(EXEC)

vprod: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(EVLIBS) $(SYSLIBS)

$(MOBJS): ../main.h ../defs.h

version.o:      ../version.c
	sh -c '$(CC) $(CFLAGS) -c ../version.c -DVVERSION="\"`cat ../../../.version`\""'

release: $(EXEC)
	mcs -D vprod
	strip vprod
	ls -ls vprod
	mv dtry vprod
#	cp vprod /usr/bin/vprod
#	mv vprod ../../prod6/vprod$(NUM)/vprod

main.o:	../main.c
	$(CC) $(CFLAGS) -c ../main.c

notify.o:	../notify.c
	$(CC) $(CFLAGS) -c ../notify.c

errors.o:	../errors.c
	$(CC) $(CFLAGS) -c ../errors.c

misc.o:	../misc.c
	$(CC) $(CFLAGS) -c ../misc.c

prodlist.o:	../prodlist.c
	$(CC) $(CFLAGS) -c ../prodlist.c

connect.o:	../connect.c
	$(CC) $(CFLAGS) -c ../connect.c

net.o:	../net.c
	$(CC) $(CFLAGS) -c ../net.c

tape.o:	../tape.c
	$(CC) $(CFLAGS) -c ../tape.c

proddate.o:	../proddate.c
	$(CC) $(CFLAGS) -c ../proddate.c

fsys.o:	../fsys.c
	$(CC) $(CFLAGS) -c ../fsys.c

keyfile.o:	../keyfile.c
	$(CC) $(CFLAGS) -c ../keyfile.c

lk.o:	../lk.c
	$(CC) $(CFLAGS) -c ../lk.c

moveprod.o:	../moveprod.c
	$(CC) $(CFLAGS) -c ../moveprod.c

walk.o:	../walk.c
	$(CC) $(CFLAGS) -c ../walk.c

sh.o:	../sh.c
	$(CC) $(CFLAGS) -c ../sh.c

install.o:	../install.c
	$(CC) $(CFLAGS) -c ../install.c

def.o:	../def.c
	$(CC) $(CFLAGS) -c ../def.c

df.o:	../df.c
	$(CC) $(CFLAGS) -c ../df.c

prod_form.o:	../prod_form.c
	$(CC) $(CFLAGS) -c ../prod_form.c

spawn.o:	../spawn.c
	$(CC) $(CFLAGS) -c ../spawn.c

runsh.o:	../runsh.c
	$(CC) $(CFLAGS) -c ../runsh.c

xrunsh.o:	../xrunsh.c
	$(CC) $(CFLAGS) -c ../xrunsh.c

pack_misc.o:	../pack_misc.c
	$(CC) $(CFLAGS) -c ../pack_misc.c

group_misc.o:	../group_misc.c
	$(CC) $(CFLAGS) -c ../group_misc.c

class_form.o:	../class_form.c
	$(CC) $(CFLAGS) -c ../class_form.c

rm_misc.o:	../rm_misc.c
	$(CC) $(CFLAGS) -c ../rm_misc.c

tnote.o:	../tnote.c
	$(CC) $(CFLAGS) -c ../tnote.c

time_misc.o:	../time_misc.c
	$(CC) $(CFLAGS) -c ../time_misc.c

factor.o:	../factor.c
	$(CC) $(CFLAGS) -c ../factor.c

infp.o:	../infp.c
	$(CC) $(CFLAGS) -c ../infp.c

expand.o:	../expand.c
	$(CC) $(CFLAGS) -c ../expand.c

multname.o:	../multname.c
	$(CC) $(CFLAGS) -c ../multname.c

fslist.o:	../fslist.c
	$(CC) $(CFLAGS) -c ../fslist.c

lostpeer.o:	../lostpeer.c
	$(CC) $(CFLAGS) -c ../lostpeer.c


