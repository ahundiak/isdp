CC	= cc
CFLAGS	= -Xa -O $(DEFS)
PROD	= ../../../prod.solaris
RFILES	= catalog
DEFS	= -DSVR4 -DSYSV -DNEWDIRS

all:	$(RFILES)

catalog:	../catalog.c
	$(CC) $(CFLAGS) -o catalog ../catalog.c

release:	$(RFILES)
	chmod 755 catalog
	find $(RFILES) -print | cpio -pmudv $(PROD)
	touch release

clean:
	rm -f $(RFILES) core
