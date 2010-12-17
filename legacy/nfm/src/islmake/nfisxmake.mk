# 22 April 1999 Art Hundiak
# tweaked path to libXFI.a

CC=/opt/SUNWspro/bin/cc
CFLAGS= -g  
LIBDIR=../tdlib
BINDIR=../tdbin
OSFLAG=-Dsolaris

TARGSTR=
RISLIB=/opt/ingr/ris/risdp/lib
OBJEXT=9

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
	$(LIBDIR)/libnfmftr.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmerr.a \
	$(RISLIB)/ris.a \
	$(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libalter.a

EXECUTABLE = $(BINDIR)/Nfmfisx

LIBRARIES  =-lw \
		-lX11 \
		-lhlib \
		-ldl \
		/usr/lib/libXFI.a \
		-lnsl \
                -lUMS \
		-lsocket \
		-lm \
		-lelf

$(EXECUTABLE) : $(NFMFI)/NFFmain.$(OBJEXT) $(NFMFILIB) $(NFMLIB)
	$(CC) -g -DXWINDOWS $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(EXECUTABLE)\
        $(NFMFI)/NFFmain.$(OBJEXT) \
	$(NFMFILIB) $(NFMLIB) \
	/opt/ingr/lib/libXFS.so \
	$(LIBRARIES)
	@echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""
