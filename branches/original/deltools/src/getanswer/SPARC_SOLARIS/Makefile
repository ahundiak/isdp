CFLAGS = -O -Xa $(DEFS)
RFILES = getanswer
RDIR   = ../../../prod.solaris
DEFS   = -DSYSV -DSVR4 -DNEWDIRS

all:	$(RFILES)

getanswer:	../getanswer.c
	$(CC) $(CFLAGS) -o getanswer ../getanswer.c  -lgen
	ls -ls getanswer

release: $(RFILES)
	find $(RFILES) -print | cpio -puvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) core
