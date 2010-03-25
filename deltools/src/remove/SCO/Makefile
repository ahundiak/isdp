CC	= cc
CFLAGS	= -O
RFILES	= ../remove ../.remove/* gethelp
RFILES2 = remove .remove/*
RFILES3 = gethelp
RDIR	= ../../../prod.sco
RDIR2	= ../../prod.sco
RDIR3	= ../../../prod.sco/.remove
DEFS	= -DSYSV -DSVR3 -DSCO -D_XOPEN_SOURCE

all: $(RFILES)

gethelp: ../gethelp.c
	$(CC) $(CFLAGS) -s -o gethelp ../gethelp.c  -lc

release: $(RFILES)
	(cd ..; chmod 500 remove; find $(RFILES2) -print | cpio -pvmd $(RDIR2))
	find $(RFILES3) -print | cpio -pvmd $(RDIR3)
	touch release

clean:
	rm -f $(RFILES3) *.dbg core
