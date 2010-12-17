CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
SCBINDIR=../sunbin
USR5LIB=/usr/5lib
TARGSTR=
OBJEXT=6

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
	$(USR5LIB)/libcurses.a \
        -lxc \
        -lUMS \
        -lxcmalloc \
	$(USR5LIB)/libc.a

NFMBULK=../bulkload
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmbulk

SCPP=$(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@/usr/5bin/echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMBULK)/SCatofn.c
	@/usr/5bin/echo "\nchar *nfm_path = \"$(NFMBULK)\";" >> $(NFMBULK)/SCatofn.c
	@acc -c -ansi  $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
           $(NFMBULK)/SCatofn.c 

image : 
	@/usr/5bin/echo ""
	acc $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	../sc/SCmain.$(OBJEXT) \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES) 
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@/usr/5bin/echo ""

