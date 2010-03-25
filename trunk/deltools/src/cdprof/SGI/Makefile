RFILES = getcdkeys
RDIR   = ../../../prod.sgi
OBJS   = keys.o get_prof.o
LIBS   =
CFLAGS = -O
# Definitions for IRIX 5.x
DEFS   = -DSYSV -DSVR4 -DNEWDIRS
# Definitions for IRIX 4.x
#DEFS   = -DSYSV -DSVR3


all:	$(RFILES)

getcdkeys: $(OBJS)
	$(CC) $(CFLAGS) -s -o getcdkeys $(OBJS) $(LIBS)

.c.o:
	$(CC) $(CFLAGS) -c $<

release: $(RFILES)
	strip $(RFILES)
	ls -ls $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

keys.o:	../keys.c
	$(CC) $(CFLAGS) $(DEFS) -c ../keys.c

get_prof.o: ../get_prof.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../get_prof.c

clean:
	rm -f $(OBJS) $(RFILES) *.dbg core
