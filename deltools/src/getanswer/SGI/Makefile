CFLAGS	= -O
RFILES	= getanswer
RDIR	= ../../../prod.sgi
# Definitions for IRIX 5.x
DEFS	= -DSYSV -DSVR4 -DNEWDIRS
# Definitions for IRIX 4.x
#DEFS	= -DSYSV -DSVR3

all:	$(RFILES)

getanswer:	../getanswer.c
	$(CC) $(CFLAGS) $(DEFS) -o getanswer ../getanswer.c -lPW

release: $(RFILES)
	strip $(RFILES)
	chmod 0755 $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) *.dbg core
