CC	= cc
CFLAGS	= -O
RFILES	= Free
RDIR	= ../../../prod.sco
DEFS	= -DSYSV -DSVR3 -DSCO
# -D_XOPEN_SOURCE

all:	$(RFILES)

Free:	../free.c
	$(CC) $(CFLAGS) $(DEFS) -o Free ../free.c -lc

release: $(RFILES)
	strip $(RFILES)
	chmod 755 $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) *.dbg core
