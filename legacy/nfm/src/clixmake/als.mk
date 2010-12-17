CFLAGS=-D__cpu_c400__
LIBDIR=../libc400
BINDIR=../binc400
SCBINDIR=../binc100
TARGSTR=-Atarg=c400
RISLIB=/usr2/ip32/ris/risdp/lib/c400
FTRDIR=/usr/ip32/ftrdp/lib/c100

SOURCEFILES=../alpha/FMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmfms.a \
	$(LIBDIR)/libnfmr.a \
	$(LIBDIR)/NFMversion.o \
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
	$(LIBDIR)/libnfmftr.a \
	$(FTRDIR)/FTRlib.a \
	$(RISLIB)/ris.a

LIBRARIES=\
	-lbsd \
	-linc \
	-lnsl_s \
	-lcurses \
	-ltools_s \
	-lxc \
	-lix \
	-lUMS \
	-lxcmalloc \
	-ll \
	-lm \
	-lPW \
	-lc_s

NFMALPHA=../alphas
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmalphas

SCPP = $(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMALPHA)/SCatofn.c
	@echo "\nchar *nfm_path = \"$(NFMALPHA)\";" >> $(NFMALPHA)/SCatofn.c
	@acc -c -ansi -O3 -Dclipper $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
           $(NFMALPHA)/SCatofn.c 

image : 
	@echo ""
	acc -O3 -Dclipper $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(LIBDIR)/libnfmscs.o \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

