CC	= cc
CFLAGS	= -O 
RFILES	= dates proddata prodinfo
RDIR	= ../../../prod.sco
DEFS	= -DSYSV -DSVR3 -DSCO -D_XOPEN_SOURCE

all:	$(RFILES)

dates:	../dates.c
	$(CC) $(CFLAGS) $(DEFS) -o dates ../dates.c -lc

prodinfo:	dates
	-ln dates prodinfo

proddata:	dates
	-ln dates proddata

release: $(RFILES)
	strip $(RFILES)
	chmod 755 $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) *.dbg core
