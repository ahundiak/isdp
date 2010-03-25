CC	= cc
CFLAGS	= -O $(DEFS)
PROD	= ../../../prod.sco
RFILES	= netaddr
DEFS	= -DSYSV -DSVR3 -DSCO

all:	$(RFILES)

netaddr:	../netaddr.c
	$(CC) $(CFLAGS) -o netaddr ../netaddr.c -lc

release:	$(RFILES)
	strip $(RFILES)
	mcs -d $(RFILES)
	chmod 755 $(RFILES)
	find $(RFILES) -print | cpio -pmdv $(PROD)
	touch release

clean:
	rm -f $(RFILES)
