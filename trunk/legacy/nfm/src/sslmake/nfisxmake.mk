CFLAGS=
LIBDIR=../sollib
BINDIR=../solbin
OSFLAG=-Dsolaris

TARGSTR=
RISLIB=/usr/ip32/ris/rispsuc/lib/Sol2
OBJEXT=7

NFMFI = ../nfmfis_x
NFMFILIB = $(LIBDIR)/libnfmfis_x.a

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
	$(LIBDIR)/alter.a

EXECUTABLE = $(BINDIR)/Nfmfisx

$(EXECUTABLE) : $(NFMFI)/NFFmain.$(OBJEXT) $(NFMFILIB) $(NFMLIB)
	acc -g -DXWINDOWS $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(EXECUTABLE)\
        $(NFMFI)/NFFmain.$(OBJEXT) \
	$(NFMFILIB) $(NFMLIB) \
	-lw -lXFS -lXFI -lX11 -lnsl -lsocket -lm \
	-lUMS -ldl -lhlib 
	@echo ""
#	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""
