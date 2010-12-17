CC=/opt/SUNWspro/bin/cc
CFLAGS=
LIBDIR=../tdlib
BINDIR=../tdbin
SCBINDIR=../tdbin
OSFLAG=-Dsolaris -DDEBUG
TARGSTR=
OBJEXT=9

SOURCEFILES=../alpha/FMcommands.c

OBJECTS=\
        $(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/libnfmfm.a \
        $(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libnfmr.a \
	$(LIBDIR)/libnfmruti.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a \
	$(LIBDIR)/libalter.a

LIBRARIES=\
	-lnsl \
	/usr/ccs/lib/libcurses.a \
	-lUMS \
	-lsocket \
	-ldl \
	-lmapmalloc

NFMALPHA=../alpha
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmalpha

SCPP = $(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMALPHA)/SCatofn.c
	@echo "\nchar *nfm_path = \"$(NFMALPHA)\";" >> $(NFMALPHA)/SCatofn.c
	@$(CC) -g -c -Xa $(CFLAGS) $(TARGSTR) -I$(NFMINCL) $(NFMALPHA)/SCatofn.c 
image : 
	@echo ""
	$(CC) -g -Xa $(CFLAGS) $(OSFLAG) $(TARGSTR) -o $(NFMEXEC) \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES) 
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

