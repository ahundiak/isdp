CFLAGS	= -O $(DEFS)
RFILES	= ../remove ../.remove/* gethelp
RFILES2 = remove .remove/*
RFILES3 = gethelp
RDIR	= ../../../prod.sun
RDIR2	= ../../prod.sun
RDIR3	= ../../../prod.sun/.remove
DEFS	= -DSunOS_4

all: $(RFILES)

gethelp: ../gethelp.c
	$(CC) $(CFLAGS) -s -o gethelp ../gethelp.c 

release: $(RFILES)
	(cd ..; find $(RFILES2) -print | cpio -pvmd $(RDIR2))
	find $(RFILES3) -print | cpio -pvmd $(RDIR3)
	touch release

clean:
	rm -f $(RFILES3)

