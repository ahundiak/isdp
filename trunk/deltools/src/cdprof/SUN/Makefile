RFILES = getcdkeys
RDIR   = ../../../prod.sun
OBJS   = keys.o get_prof.o
LIBS   = 
CFLAGS = -O
DEFS   = -DSunOS_4


all:	$(RFILES)

getcdkeys: $(OBJS)
	$(CC) $(CFLAGS) -s -o getcdkeys $(OBJS) $(LIBS)

.c.o:
	$(CC) $(CFLAGS) -c $<

release: $(RFILES)
	ls -ls $(RFILES)
	find $(RFILES) -print | cpio -pvmd $(RDIR)
	touch release

keys.o:	../keys.c
	$(CC) $(CFLAGS) $(DEFS) -c ../keys.c

get_prof.o: ../get_prof.c ../main.h
	$(CC) $(CFLAGS) $(DEFS) -c ../get_prof.c

clean:
	rm -f $(OBJS) $(RFILES) clean
