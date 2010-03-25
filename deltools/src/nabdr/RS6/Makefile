CFLAGS	= -O

RFILES	= .cmsdr.
RDIR	= ../../../prod.rs6

all:	$(RFILES)

.cmsdr.:	../cmsdr.c
	$(CC) $(CFLAGS) -o $@ ../cmsdr.c
	
release:	$(RFILES)
	strip $(RFILES)
	chmod 0550 $(RFILES)
	ls -a $(RFILES) | cpio -pmudv $(RDIR)
	touch release

clean:
	rm -f $(RFILES)
