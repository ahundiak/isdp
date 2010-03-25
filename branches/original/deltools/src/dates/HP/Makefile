CFLAGS	= -O -Aa +DA1.0 $(DEFS)
RFILES	= dates proddata prodinfo
RDIR	= ../../../prod.hp
DEFS	= -DHP_UX -D_INCLUDE_POSIX_SOURCE

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
