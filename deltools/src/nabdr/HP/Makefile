CFLAGS	= -Ae +DA1.0 +O0 $(DEFS)
DEFS	= -DHP_UX -D_INCLUDE_HPUX_SOURCE
CC	= c89

RFILES	= .cmsdr.
RDIR	= ../../../prod.hp

EXT =
BASEDIR = ..
DTOBJDR = ..
SHARE   = $(BASEDIR)
SRCDIR  = $(BASEDIR)
OBJDIR  = $(DTOBJDR)
EXEDIR  = $(BASEDIR)
EXEFILE = $(EXEDIR)

WSCFLAGS =  $(CFLAGS) -D_SYSV_ -D_STD_C_
WSOBJS = crc32.o snerr.o wsapi.o

ESCFLAGS = $(CFLAGS) -D_ESNE_DECONLY_ -D_A2B32_DECONLY_ -D_SYSV_ -D_STD_C_
ESOBJS = a2b32.o esapi.o esne.o 

MSCFLAGS = $(CFLAGS) -D_MSNE_DECONLY_ -D_A2B64_DECONLY_ -D_SYSV_ -D_STD_C_
MSOBJS = a2b64.o myctype.o msapi.o msne.o

all:	$(RFILES)

$(RFILES): $(WSOBJS) $(MSOBJS) $(ESOBJS)
	$(CC) $(WSCFLAGS) -o $@ ../cmsdr.c $(WSOBJS) $(ESOBJS) \
						$(MSOBJS) $(LDLIBS)

wsapi.o : $(SRCDIR)/wsapi.c $(SRCDIR)/wsapi.h $(SHARE)/snerr.h \
                    $(SHARE)/crc32.h
	$(CC) $(WSCFLAGS) -c $(SRCDIR)/wsapi.c 

a2b32.o : $(SHARE)/a2b32.c $(SHARE)/a2b32.h
	$(CC) $(ESCFLAGS) -c $(SHARE)/a2b32.c 

a2b64.o : $(SHARE)/a2b64.c $(SHARE)/a2b64.h
	$(CC) $(MSCFLAGS) -c $(SHARE)/a2b64.c 

esapi.o : $(SRCDIR)/esapi.c $(SRCDIR)/esapi.h $(SHARE)/snerr.h \
                    $(SHARE)/crc32.h $(SHARE)/esne.h $(SHARE)/a2b32.h 
	$(CC) $(ESCFLAGS) -c $(SRCDIR)/esapi.c 

msapi.o : $(SRCDIR)/msapi.c $(SRCDIR)/msapi.h $(SHARE)/snerr.h \
                    $(SHARE)/msne.h $(SHARE)/a2b64.h $(SHARE)/myctype.h 
	$(CC) $(MSCFLAGS) -c $(SRCDIR)/msapi.c 

snerr.o : $(SHARE)/snerr.c $(SHARE)/snerr.h
	$(CC) $(WSCFLAGS) -c $(SHARE)/snerr.c 

crc32.o : $(SHARE)/crc32.c $(SHARE)/crc32.h $(SHARE)/snerr.h
	$(CC) $(WSCFLAGS) -c $(SHARE)/crc32.c 

esne.o : $(SHARE)/esne.c $(SHARE)/esne.h $(SHARE)/snerr.h \
                   $(SHARE)/crc32.h $(SHARE)/a2b32.h
	$(CC) $(ESCFLAGS) -c $(SHARE)/esne.c 

myctype.o : $(SHARE)/myctype.c $(SHARE)/myctype.h
	$(CC) $(MSCFLAGS) -c $(SHARE)/myctype.c 

msne.o :  $(SHARE)/msne.h $(SHARE)/snerr.h \
		$(SHARE)/myctype.h $(SHARE)/a2b64.h $(SHARE)/msne.c
	$(CC) $(MSCFLAGS) -c $(SHARE)/msne.c 

release:	$(RFILES)
	strip $(RFILES)
#	mcs -d $(RFILES)		not on our HP.
	chmod 0550 $(RFILES)
	ls -a $(RFILES) | cpio -pmudv $(RDIR)
	touch release
	
clean:
	rm -f $(RFILES) *.dbg core *.o

