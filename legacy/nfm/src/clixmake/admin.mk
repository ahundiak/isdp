CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
SCBINDIR=../binc100
TARGSTR=-Atarg=c100
RISLIB=/usr2/ip32/ris/risdp/lib/c100
FTRDIR=/usr/ip32/ftrdp/lib/c100

SOURCEFILES=../admin/ADMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmadmin.a \
	$(LIBDIR)/NFMversion.o\
	$(LIBDIR)/libnfmsuti.a \
	$(LIBDIR)/libnfma.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmlists.a \
	$(LIBDIR)/libcmdtools.a \
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
	$(FTRDIR)/FTRlib.a \
	$(RISLIB)/ris.a

LIBRARIES=\
	-lbsd \
	-linc \
	-lnsl_s \
	-lcurses \
	-ltools_s \
	-lUMS \
	-lxc \
	-lxcmalloc \
	-ll \
	-lm \
	-lPW \
	-lc_s

NFMADMIN=../admin
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmadmin

SCPP=$(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMADMIN)/SCatofn.c
	@echo "\nchar *nfm_path = \"$(NFMADMIN)\";" >> $(NFMADMIN)/SCatofn.c
	@acc -c -ansi -O3 -Dclipper $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
           $(NFMADMIN)/SCatofn.c 

image : 
	@echo ""
	acc -O3 -Dclipper $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(LIBDIR)/libnfmsc.o \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

