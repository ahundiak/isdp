RFILES = cdprof
RDIR   = ../../../prod.hp
OBJS   = keys.o get_prof.o
LIBS   = 
CFLAGS = -O -Ae +DA1.0
DEFS   = -DHP_UX 


all:	$(RFILES)

cdprof: $(OBJS)
	$(CC) $(CFLAGS) -s -o cdprof $(OBJS) $(LIBS)

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
