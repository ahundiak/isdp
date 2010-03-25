CFLAGS = -O $(INCS)
RFILES = rm_pg
OFILES = main.o  rm_misc.o  page_misc.o
LIBS	= /usr/5lib/libcurses.a /usr/5lib/libtermcap.a
INCS	= -I/usr/5include
DEFS	= -DSunOS_4 -DSYSVCURSES

RDIR   = ../../../prod.sun

all:	$(RFILES)

rm_pg:	$(OFILES)
	$(CC) $(CFLAGS) -s -o rm_pg $(OFILES) $(LIBS)
	ls -ls rm_pg

release: $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

main.o:		../main.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../main.c

rm_misc.o:	../rm_misc.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../rm_misc.c

page_misc.o:	../page_misc.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../page_misc.c

clean:
	rm -f $(OFILES) $(RFILES)
