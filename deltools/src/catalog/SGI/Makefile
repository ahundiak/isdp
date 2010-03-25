CC	= cc
CFLAGS	= -O $(DEFS)
PROD	= ../../../prod.sgi
RFILES	= catalog
# Definitions for IRIX 5.x
DEFS	= -DSYSV -DSVR4 -DNEWDIRS
# Definitions for IRIX 4.x
#DEFS	= -DSYSV -DSVR3


all:	$(RFILES)

catalog:	../catalog.c
	$(CC) $(CFLAGS) -o catalog ../catalog.c

release:	$(RFILES)
	strip $(RFILES)
	chmod 755 $(RFILES)
	find $(RFILES) -print | cpio -pmdv $(PROD)
	touch release

clean:
	rm -f $(RFILES) core
