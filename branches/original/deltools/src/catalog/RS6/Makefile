FLAGS	= -O
RDIR	= ../../../prod.rs6
RFILES	= catalog

all:	$(RFILES)

catalog:	../catalog.c
	$(CC) $(CFLAGS) -s -o catalog ../catalog.c
	ls -ls dates

release: $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

clean:
	rm -f $(RFILES) core
