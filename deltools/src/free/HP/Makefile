CFLAGS = -O +DA1.0 $(DEFS)
RFILES = Free
RDIR   = ../../../prod.hp
DEFS   = -DHP_UX

all:	$(RFILES)

Free:	../free.c
	$(CC) $(CFLAGS) -s -o Free ../free.c
	ls -ls Free

release: $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) core
