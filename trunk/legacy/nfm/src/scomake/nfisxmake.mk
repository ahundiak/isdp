CFLAGS=
LIBDIR=../scolib
BINDIR=../scobin
TARGSTR=
RISLIB=/usr/ip32/ris/risdp/lib
OBJEXT=5

NFMLIB = \
	$(LIBDIR)/libquis.a \
	$(LIBDIR)/libnfmruti.a \
	$(LIBDIR)/libnfma.a \
	$(LIBDIR)/libnfmsuti.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmlists.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libnfmwf.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmerr.a \
	$(RISLIB)/ris.a \
	$(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libalter.a

NFMFI = ../nfmfis_x
NFMFILIB = $(LIBDIR)/libnfmfis_x.a

EXECUTABLE = $(BINDIR)/Nfmfisx

$(EXECUTABLE) : $(NFMFI)/NFFmain.$(OBJEXT) $(NFMFILIB) $(NFMLIB)
	cc -g -DXWINDOWS $(CFLAGS) $(TARGSTR) $(NFMFI)/NFFmain.$(OBJEXT) \
	$(NFMFILIB) $(NFMLIB) \
	-lXFI -lX11 -lnsl_s -lsocket -lm -lUMS -o $(EXECUTABLE)
	@echo ""
#	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""
