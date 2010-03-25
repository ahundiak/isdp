CC	= cc
CFLAGS	= -O $(DEFS)
PROD	= ../../../prod.sgi
RFILES	= netaddr
#DEFS	= -DSYSV -DSVR3 -DSGI
DEFS	= -DSYSV -DSVR4 -DSGI

all:	$(RFILES)

netaddr:	../netaddr.c
	$(CC) $(CFLAGS) -o netaddr ../netaddr.c -lc

release:	$(RFILES)
	strip $(RFILES)
	chmod 755 $(RFILES)
	find $(RFILES) -print | cpio -pmdv $(PROD)
	touch release

clean:
	rm -f $(RFILES)
