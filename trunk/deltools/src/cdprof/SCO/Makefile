CC     = cc
RFILES = getcdkeys
RDIR   = ../../../prod.sco
OBJS   = keys.o get_prof.o
CFLAGS = -O 
DEFS   = -DSYSV -DSVR3 -DL_ENDIAN -DSCO -D_XOPEN_SOURCE

all:	$(RFILES)

getcdkeys: $(OBJS)
	$(CC) $(CFLAGS) -s -o getcdkeys $(OBJS) -lc

.c.o:
	$(CC) $(CFLAGS) -c $<

release: $(RFILES)
	strip $(RFILES)
	mcs -d $(RFILES)
	chmod 755 $(RFILES)
	ls -ls $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	copy ../interfaces.sco $(RDIR)/interfaces
	touch release

keys.o:	../keys.c
	$(CC) $(CFLAGS) $(DEFS) -c ../keys.c

get_prof.o: ../get_prof.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../get_prof.c

clean:
	rm -f $(OBJS) $(RFILES) *.dbg core
