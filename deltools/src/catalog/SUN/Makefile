CC	= acc
CFLAGS	= -O $(DEFS)
PROD	= ../../../prod.sun
RFILES	= catalog
DEFS	= -DSunOS_4

all:	$(RFILES)

catalog:	../catalog.c
	$(CC) $(CFLAGS) -o catalog ../catalog.c

release:	$(RFILES)
	chmod 755 catalog
	find $(RFILES) -print | cpio -pmdv $(PROD)
	touch release

clean:
	rm -f $(RFILES) core
