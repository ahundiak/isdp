CFLAGS=
LIBDIR=../scolib
BINDIR=../scobin
SCBINDIR=../scobin
TARGSTR=
OBJEXT=5
RISLIB=/usr/ip32/ris/risdp/lib

OBJECTS=$(LIBDIR)/libnfmmonitor.a

LIBRARIES=

NFMALPHA=../nfmmonitor
NFMINCL=../include
NFMEXEC=$(BINDIR)/NFMmonitor

image : 
	@echo ""
	cc -g $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

