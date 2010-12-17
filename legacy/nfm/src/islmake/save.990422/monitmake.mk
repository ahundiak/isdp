CC=/opt/SUNWspro/bin/cc
CFLAGS=
LIBDIR=../tdlib
BINDIR=../tdbin
SCBINDIR=../tdbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=9
RISLIB=/opt/ingr/ris/risdp/lib

OBJECTS=$(LIBDIR)/libnfmmonitor.a

NFMALPHA=../nfmmonitor
NFMINCL=../include
NFMEXEC=$(BINDIR)/NFMmonitor

image : 
	@echo ""
	$(CC) -g $(CFLAGS) $(OSFLAG) $(TARGSTR) -o $(NFMEXEC) $(OBJECTS)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

