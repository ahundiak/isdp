CFLAGS=
LIBDIR=../sollib
BINDIR=../solbin
SCBINDIR=../solbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=7

SOURCEFILES=../bulkload/FMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmbulk.a \
	$(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libnfmr.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a \
	$(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/alter.a

LIBRARIES=\
        -lnsl \
	-lcurses \
	-lUMS \
	-lsocket \
	-ldl

NFMBULK=../bulkload
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmbulk

SCPP=$(SCBINDIR)/SCcpp


product: SCatofn.o image

SCatofn.o:	$(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMBULK)/SCatofn.c
	@echo "char *\nnfm_path = \"$(NFMBULK)\";" >> $(NFMBULK)/SCatofn.c
	@acc -c $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
           $(NFMBULK)/SCatofn.c 

image : 
	@echo ""
	acc -Xa $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	../sc/SCmain.$(OBJEXT) \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES) 
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
