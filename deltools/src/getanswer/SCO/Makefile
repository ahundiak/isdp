CC	= cc
CFLAGS	= -O
RFILES	= getanswer
RDIR	= ../../../prod.sco
DEFS	= -DSYSV -DSVR3 -DSCO -D_XOPEN_SOURCE
LIBS	= -lPW -lc

all:	$(RFILES)

getanswer:	../getanswer.c
	$(CC) $(CFLAGS) $(DEFS) -o getanswer ../getanswer.c $(LIBS)

release: $(RFILES)
	strip $(RFILES)
	chmod 755 $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) *.dbg core
