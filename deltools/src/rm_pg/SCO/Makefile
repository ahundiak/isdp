CC	= cc
CFLAGS	= -O
RFILES	= rm_pg
OFILES	= main.o  rm_misc.o  page_misc.o
DEFS	= -DSYSV -DSVR3 -DSCO -D_XOPEN_SOURCE

RDIR   = ../../../prod.sco

all:	$(RFILES)

rm_pg:	$(OFILES)
	$(CC) $(CFLAGS) -s -o rm_pg $(OFILES) -lcurses -lc
	strip rm_pg
	ls -ls rm_pg

release: $(RFILES)
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
