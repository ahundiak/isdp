CFLAGS	= -O -Xa $(DEFS)
RFILES	= dates proddata prodinfo
RDIR	= ../../../prod.solaris
DEFS	= -DSYSV -DSVR4 -DNEWDIRS

all:	dates

dates:	../dates.c
	$(CC) $(CFLAGS) -s -o dates ../dates.c
	strip dates
	ls -ls dates
	-ln dates prodinfo
	-ln dates proddata

release: $(RFILES)
	find $(RFILES) -print | cpio -puvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) core
