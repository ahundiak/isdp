CFLAGS = -O -s
RFILES = Free
RDIR   = ../../../prod.rs6

all:	$(RFILES)

Free:	../free.c
	$(CC) $(CFLAGS) -o Free ../free.c
	ls -ls Free

release: $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES)
