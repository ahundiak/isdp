CFLAGS = -O $(DEFS)
RFILES = Free
RDIR   = ../../../prod.sun
DEFS   = -DSunOS_4

all:	$(RFILES)

Free:	../free.c
	$(CC) $(CFLAGS) -s -o Free ../free.c
	ls -ls Free

release: $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) core
