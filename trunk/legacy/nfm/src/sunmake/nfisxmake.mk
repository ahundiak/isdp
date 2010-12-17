CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
USR5LIB=/usr/5lib
TARGSTR=
RISLIB=/usr/ip32/ris/rispsuc/lib/sun
OBJEXT=6

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

NFMFI = ../nfmfis_x
NFMFILIB = $(LIBDIR)/libnfmfis_x.a

EXECUTABLE = $(BINDIR)/Nfmfisx

$(EXECUTABLE) : $(NFMFI)/NFFmain.$(OBJEXT) $(NFMFILIB) $(NFMLIB)
	acc -DXWINDOWS $(CFLAGS) $(TARGSTR) $(NFMFI)/NFFmain.$(OBJEXT) \
	$(NFMFILIB) $(NFMLIB) \
	-lhlib -lXFI -lXFS -lX11 \
	-lnsl -lm -lUMS -lxc \
	$(USR5LIB)/libc.a -lxcmalloc -o $(EXECUTABLE)
	@echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""
