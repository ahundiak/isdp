CFLAGS = -O -Xa
RFILES = rm_pg
OFILES = main.o rm_misc.o page_misc.o
LIBS	= -lcurses
DEFS	= -DSYSV -DSVR4 -DSYSV_CURSES -DNEWDIRS

RDIR   = ../../../prod.solaris

all:	$(RFILES)

rm_pg:	$(OFILES)
	$(CC) $(CFLAGS) -s -o rm_pg $(OFILES) $(LIBS)
	ls -ls rm_pg

release: $(RFILES)
	find $(RFILES) -print | cpio -puvmd $(RDIR)
	touch release

main.o:		../main.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../main.c

rm_misc.o:	../rm_misc.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../rm_misc.c

page_misc.o:	../page_misc.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../page_misc.c

clean:
	rm -f $(OFILES) $(RFILES)
