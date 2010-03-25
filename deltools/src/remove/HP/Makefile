CFLAGS	= -O +DA1.0 $(DEFS)
RFILES	= ../remove ../.remove/* gethelp
RFILES2 = remove .remove/*
RFILES3 = gethelp
RDIR	= ../../../prod.hp
RDIR2	= ../../prod.hp
RDIR3	= ../../../prod.hp/.remove
DEFS	= -DHP_UX

all: $(RFILES)

gethelp: ../gethelp.c
	$(CC) $(CFLAGS) -s -o gethelp ../gethelp.c 

release: $(RFILES)
	(cd ..; find $(RFILES2) -print | cpio -pvmd $(RDIR2))
	find $(RFILES3) -print | cpio -pvmd $(RDIR3)
	touch release

clean:
	rm -f $(RFILES3)

