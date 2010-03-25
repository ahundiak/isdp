CFLAGS = -O -Xa $(DEFS)
RFILES = Free
RDIR   = ../../../prod.solaris
DEFS   = -DSYSV -DSVR4 -DNEWDIRS

all:	$(RFILES)

Free:	../free.c
	$(CC) $(CFLAGS) -s -o Free ../free.c
	ls -ls Free

release: $(RFILES)
	find $(RFILES) -print | cpio -puvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) core
