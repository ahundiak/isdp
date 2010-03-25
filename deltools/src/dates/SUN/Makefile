CFLAGS	= -O $(DEFS)
RFILES	= dates proddata prodinfo
RDIR	= ../../../prod.sun
DEFS	= -DSunOS_4

all:	dates

dates:	../dates.c
	$(CC) $(CFLAGS) -s -o dates ../dates.c
	strip dates
	ls -ls dates
	-ln dates prodinfo
	-ln dates proddata

release: $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) core
