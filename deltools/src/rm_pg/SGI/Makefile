CFLAGS	= -O $(TARG)
RFILES	= rm_pg
OFILES	= main.o  rm_misc.o  page_misc.o
#defines for IRIX 5.x
DEFS	= -DSYSV -DSVR4 -DNEWDIRS
#defines for IRIX 4.x
#DEFS	= -DSYSV -DSVR3

RDIR   = ../../../prod.sgi

all:	$(RFILES)

rm_pg:	$(OFILES)
	$(CC) $(CFLAGS) -s -o rm_pg $(OFILES) -lcurses
	ls -ls rm_pg

release: $(RFILES)
	strip $(RFILES)
	chmod 0755 $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

main.o: ../main.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../main.c

rm_misc.o: ../rm_misc.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../rm_misc.c

page_misc.o: ../page_misc.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../page_misc.c

clean:
	rm -f $(OFILES) $(RFILES) *.dbg core
