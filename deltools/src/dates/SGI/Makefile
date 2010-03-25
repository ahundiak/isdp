CFLAGS	= -O
RFILES	= dates proddata prodinfo
RDIR	= ../../../prod.sgi
# Definitions for IRIX 5.x
DEFS	= -DSYSV -DSVR4 -DNEWDIRS
# Definitions for IRIX 4.x
#DEFS	= -DSYSV -DSVR3

all:	$(RFILES)

dates:	../dates.c
	$(CC) $(CFLAGS) $(DEFS) -o dates ../dates.c

prodinfo:	dates
	-ln dates prodinfo

proddata:	dates
	-ln dates proddata

release: $(RFILES)
	strip $(RFILES)
	chmod 0755 $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) *.dbg core
