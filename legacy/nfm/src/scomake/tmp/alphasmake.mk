CFLAGS=-g
LIBDIR=../scolib
BINDIR=../scobin
SCBINDIR=../scobin
TARGSTR=
OBJEXT=5

SOURCEFILES=../alpha/FMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmfm.a \
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
        $(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libalter.a

LIBRARIES=\
	-lnsl_s \
	-lcurses\
	-lUMS \
	-lsocket \
	-lmalloc \
	-lc

NFMALPHA=../alpha
NFMINCL=../include
NFMEXEC=../scobin/Nfmalpha

SCPP = $(SCBINDIR)/SCcpp

product: $(NFMALPHA)/SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMALPHA)/SCatofn.c
	@echo "\nchar *nfm_path = \"$(NFMALPHA)\";" >> $(NFMALPHA)/SCatofn.c
	@cc -g -c  $(CFLAGS) $(TARGSTR) -I$(NFMINCL) $(NFMALPHA)/SCatofn.c 
	@mv SCatofn.o $(NFMALPHA)

image : 
	@echo "" 
	cc -g $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) ../sc/SCmain.$(OBJEXT) \
	$(NFMALPHA)/SCatofn.o $(OBJECTS) $(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

