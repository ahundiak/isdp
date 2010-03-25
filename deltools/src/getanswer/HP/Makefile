CFLAGS = -O +DA1.0 $(DEFS)
RFILES = getanswer
RDIR   = ../../../prod.hp
DEFS   = -DHP_UX -DSYSV
#  libraries should be specified in The following order only in order not to
#  endup with link errors -- MVR 2 May 1994 
LIBS   = -lc -lPW
all:	$(RFILES)

getanswer:	../getanswer.c
	$(CC) $(CFLAGS) -s -o getanswer ../getanswer.c $(LIBS)
	ls -ls getanswer

release: $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) core
