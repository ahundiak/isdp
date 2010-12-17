CC=/opt/SUNWspro/bin/cc
CFLAGS=-g -xs 
LIBDIR=../tdlib
BINDIR=../tdbin
SCBINDIR=../tdbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=9
RISLIB=/opt/ingr/ris/risdp/lib
FTRDIR=/opt/ingr/lib

SOURCEFILES=../admin/ADMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/libnfmadmin.a \
	$(LIBDIR)/NFMversion.a\
	$(LIBDIR)/libnfmsuti.a \
	$(LIBDIR)/libnfma.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmlists.a \
	$(LIBDIR)/libnfmwf.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libnfmftr.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmerr.a \
	$(RISLIB)/ris.a \
	$(LIBDIR)/libalter.a

LIBRARIES=\
	-lnsl \
	/usr/ccs/lib/libcurses.a \
	-lUMS \
	-ldl \
	-lsocket

NFMADMIN=../admin
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmadmin

SCPP=$(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMADMIN)/SCatofn.c
	@echo "\nchar *nfm_path = \"$(NFMADMIN)\";" >> $(NFMADMIN)/SCatofn.c
	@$(CC) -c $(CFLAGS) $(TARGSTR) -I$(NFMINCL) $(NFMADMIN)/SCatofn.c 

image : 
	@echo ""
	$(CC) $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

