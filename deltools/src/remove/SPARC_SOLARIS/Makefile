CFLAGS	= -O -Xa $(DEFS)
RFILES	= ../remove ../.remove/* gethelp
RFILES2 = remove .remove/*
RFILES3 = gethelp
RDIR	= ../../../prod.solaris
RDIR2	= ../../prod.solaris
RDIR3	= ../../../prod.solaris/.remove
DEFS	= -DSYSV -DSVR4 -DNEWDIRS

all: $(RFILES)

gethelp: ../gethelp.c
	$(CC) $(CFLAGS) -s -o gethelp ../gethelp.c 

release: $(RFILES)
	(cd ..; find $(RFILES2) -print | cpio -puvmd $(RDIR2))
	find $(RFILES3) -print | cpio -puvmd $(RDIR3)
	touch release

clean:
	rm -f $(RFILES3)

