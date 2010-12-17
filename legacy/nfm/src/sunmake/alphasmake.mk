CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
SCBINDIR=../sunbin
TARGSTR=
OBJEXT=6
RISLIB=/usr/ip32/ris/rispsuc/lib/sun
USR5LIB=/usr/5lib

SOURCEFILES=../alphas/FMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmfms.a \
	$(LIBDIR)/NFMversion.a \
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
	$(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/alter.a

LIBRARIES=\
	-lnsl \
	$(USR5LIB)/libcurses.a \
	-lxc \
	-lUMS \
	-lxcmalloc \
	$(USR5LIB)/libc.a

NFMALPHA=../alphas
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmalphas

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

