CC	= acc
TARG	= -Atarg=c100
CFLAGS	= -O3 $(TARG)
RFILES	= showconfig
RDIR	  = ../../../prod
RDIR2	 = ../../prod

all:	$(RFILES)

showconfig: ../showconfig.c ../showconfig.dat
	$(CC) $(CFLAGS) -s -o showconfig ../showconfig.c -lc
	strip showconfig
	mcs -D showconfig
	ls -ls showconfig

release: $(RFILES) ../showconfig.dat
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	(cd ..; find showconfig.dat -print | cpio -pvmd $(RDIR2))
	touch release

clean:
	rm -f $(RFILES)
