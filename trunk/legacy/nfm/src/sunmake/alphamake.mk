CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
SCBINDIR=../sunbin
TARGSTR=
OBJEXT=6
USR5LIB=/usr/5lib

SOURCEFILES=../alpha/FMcommands.c

OBJECTS=\
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
        $(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/alter.a

LIBRARIES=\
	-lnsl \
	$(USR5LIB)/libcurses.a \
        -lxc \
        -lxcmalloc \
	-lUMS \
	$(USR5LIB)/libc.a

NFMALPHA=../alpha
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmalpha

SCPP = $(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@/usr/5bin/echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMALPHA)/SCatofn.c
	@/usr/5bin/echo "\nchar *nfm_path = \"$(NFMALPHA)\";" >> $(NFMALPHA)/SCatofn.c
	@acc -c -Xa $(CFLAGS) $(TARGSTR) -I$(NFMINCL) $(NFMALPHA)/SCatofn.c 

image : 
	@/usr/5bin/echo ""
	acc -Xa $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	../sc/SCmain.$(OBJEXT) \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	@/usr/5bin/echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@/usr/5bin/echo ""

