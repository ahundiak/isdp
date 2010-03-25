CFLAGS	= -O
RFILES	= Free
RDIR	= ../../../prod.sgi
# Definitions for IRIX 5.x
DEFS	= -DSYSV -DSVR4 -DNEWDIRS
# Definitions for IRIX 4.x
#DEFS	= -DSYSV -DSVR3

all:	$(RFILES)

Free:	../free.c
	$(CC) $(CFLAGS) $(DEFS) -o Free ../free.c -lsun

release: $(RFILES)
	strip $(RFILES)
	chmod 0755 $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) *.dbg core
