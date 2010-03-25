FLAGS	= -O
RFILES	= dates proddata prodinfo
RDIR	= ../../../prod.rs6

all:	dates

dates:	../dates.c
	$(CC) $(CFLAGS) -s -o dates ../dates.c
	ls -ls dates
	-ln dates prodinfo
	-ln dates proddata

release: $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES)
