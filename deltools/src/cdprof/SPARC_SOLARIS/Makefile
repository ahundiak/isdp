RFILES = getcdkeys
RDIR   = ../../../prod.solaris
OBJS   = keys.o get_prof.o
LIBS   = 
CFLAGS = -O -Xa
DEFS   = -DSYSV -DSVR4 -DNEWDIRS


all:	$(RFILES)

getcdkeys: $(OBJS)
	$(CC) $(CFLAGS) -s -o getcdkeys $(OBJS) $(LIBS)

.c.o:
	$(CC) $(CFLAGS) -c $<

release: $(RFILES)
	ls -ls $(RFILES)
	find $(RFILES) -print | cpio -puvmd $(RDIR)
	copy ../interfaces.ssl $(RDIR)
	touch release

keys.o:	../keys.c
	$(CC) $(CFLAGS) $(DEFS) -c ../keys.c

get_prof.o: ../get_prof.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../get_prof.c

clean:
	rm -f $(OBJS) $(RFILES) core
