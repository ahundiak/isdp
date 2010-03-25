CFLAGS	= -O $(TARG)
RFILES	= ../remove ../.remove/* gethelp
RFILES2 = remove .remove/*
RFILES3 = gethelp
RDIR	= ../../../prod.sgi
RDIR2	= ../../prod.sgi
RDIR3	= ../../../prod.sgi/.remove
#defines for IRIX 5.x
DEFS	= -DSYSV -DSVR4 -DNEWDIRS
#defines for IRIX 4.x
#DEFS	= -DSYSV -DSVR3

all: $(RFILES)

gethelp: ../gethelp.c
	$(CC) $(CFLAGS) -s -o gethelp ../gethelp.c 

release: $(RFILES)
	strip $(RFILES3)
	chmod 0755 $(RFILES3)
	(cd ..; find $(RFILES2) -print | cpio -pvmd $(RDIR2))
	find $(RFILES3) -print | cpio -pvmd $(RDIR3)
	touch release

clean:
	rm -f $(RFILES3) *.dbg core
