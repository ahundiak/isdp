CC	= cc
CFLAGS	= -O $(DEFS)
PROD	= ../../../prod.sco
RFILES	= catalog
DEFS	= -DSYSV -DSVR3 -DSCO -D_XOPEN_SOURCE

all:	$(RFILES)

catalog:	../catalog.c
	$(CC) $(CFLAGS) -o catalog ../catalog.c -lc

release:	$(RFILES)
	strip $(RFILES)
	mcs -d $(RFILES)
	chmod 755 $(RFILES)
	find $(RFILES) -print | cpio -pmdv $(PROD)
	touch release

clean:
	rm -f $(RFILES) core
