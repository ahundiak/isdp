CC	= cc
CFLAGS	= -O -DSCO
LDLIBS	= -lc

RFILES	= .cmsdr.
RDIR	= ../../../prod.sco

all:	$(RFILES)

EXT =
BASEDIR = ..
DTOBJDR = ..
SHARE   = $(BASEDIR)
SRCDIR  = $(BASEDIR)
OBJDIR  = $(DTOBJDR)
EXEDIR  = $(BASEDIR)
EXEFILE = $(EXEDIR)

WSCFLAGS = -O -D_SYSV_
WSOBJS = wsapi.o crc32.o snerr.o

MSCFLAGS = -O -D_MSNE_DECONLY_ -D_A2B64_DECONLY_ -D_SYSV_
MSOBJS = msapi.o msne.o a2b64.o myctype.o
#       $(OBJDIR)/snerr.o

ESCFLAGS = -O -D_ESNE_DECONLY_ -D_A2B32_DECONLY_ -D_SYSV_
ESOBJS = esapi.o esne.o a2b32.o
#       $(OBJDIR)/crc32.o  \
#       $(OBJDIR)/snerr.o

all:	$(RFILES)

$(RFILES): $(WSOBJS) $(MSOBJS) $(ESOBJS)
	$(CC) $(CFLAGS) $(DEFS) -o $@ ../cmsdr.c $(WSOBJS) $(MSOBJS) $(ESOBJS) $(LDLIBS)

release:	$(RFILES)
	strip $(RFILES)
	mcs -d $(RFILES)
	chmod 0550 $(RFILES)
	ls -a $(RFILES) | cpio -pmudv $(RDIR)
	touch release
	
clean:
	rm -f $(RFILES) *.dbg core *.o

wsapi.o : $(SRCDIR)/wsapi.c $(SRCDIR)/wsapi.h $(SHARE)/snerr.h $(SHARE)/crc32.h
	$(CC) $(WSCFLAGS) -I $(SRCDIR) -I $(SHARE) -c $(SRCDIR)/wsapi.c

a2b32.o : $(SHARE)/a2b32.c $(SHARE)/a2b32.h
	$(CC) $(ESCFLAGS) -c $(SHARE)/a2b32.c -I$(SHARE)

a2b64.o : $(SHARE)/a2b64.c $(SHARE)/a2b64.h
	$(CC) $(MSCFLAGS) -c $(SHARE)/a2b64.c -I$(SHARE)

esapi.o : $(SRCDIR)/esapi.c $(SRCDIR)/esapi.h $(SHARE)/snerr.h \
                    $(SHARE)/crc32.h $(SHARE)/esne.h $(SHARE)/a2b32.h 
	$(CC) $(ESCFLAGS) -c $(SRCDIR)/esapi.c -I$(SRCDIR) -I$(SHARE)

msapi.o : $(SRCDIR)/msapi.c $(SRCDIR)/msapi.h $(SHARE)/snerr.h \
                    $(SHARE)/msne.h $(SHARE)/a2b64.h $(SHARE)/myctype.h 
	$(CC) $(MSCFLAGS) -c $(SRCDIR)/msapi.c -I$(SRCDIR) -I$(SHARE)

snerr.o : $(SHARE)/snerr.c $(SHARE)/snerr.h
	$(CC) $(WSCFLAGS) -c $(SHARE)/snerr.c -I$(SHARE)

crc32.o : $(SHARE)/crc32.c $(SHARE)/crc32.h $(SHARE)/snerr.h
	$(CC) $(WSCFLAGS) -c $(SHARE)/crc32.c -I$(SHARE)

esne.o : $(SHARE)/esne.c $(SHARE)/esne.h $(SHARE)/snerr.h \
                   $(SHARE)/crc32.h $(SHARE)/a2b32.h
	$(CC) $(ESCFLAGS) -c $(SHARE)/esne.c -I$(SHARE)

msne.o : $(SHARE)/msne.c $(SHARE)/msne.h $(SHARE)/snerr.h \
                   $(SHARE)/myctype.h $(SHARE)/a2b64.h
	$(CC) $(MSCFLAGS) -c $(SHARE)/msne.c -I$(SHARE)

myctype.o : $(SHARE)/myctype.c $(SHARE)/myctype.h
	$(CC) $(MSCFLAGS) -c $(SHARE)/myctype.c -I$(SHARE)

