CFLAGS = -O
RFILES = getanswer
RDIR   = ../../../prod.rs6

all:	$(RFILES)

getanswer:	../getanswer.c
	$(CC) $(CFLAGS) -s -o getanswer ../getanswer.c 
	ls -ls getanswer

release: $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES)
