CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
SCBINDIR=../binc100
TARGSTR=-Atarg=c100
RISLIB=/usr2/ip32/ris/risdp/lib/c100

NFM=..
NFMINIT=$(NFM)/initial
NFMINCL=$(NFM)/include
NFMSC=$(NFM)/sc
NFMEXEC=$(BINDIR)/Nfminit

SOURCEFILES=$(NFM)/initial/NFMi_init.c

OBJECTS=\
	$(LIBDIR)/NFMversion.a \
	$(LIBDIR)/librisinit.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a \
	$(RISLIB)/rislduld.a	\
	$(RISLIB)/ris.a

LIBRARIES=\
	-lbsd \
	-linc \
	-lnsl_s \
	-lcurses \
	-ltools_s \
	-lxc \
	-lUMS \
	-lxcmalloc \
	-lc_s

SCPP = $(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
#	@echo "\n\n\n\t...SCcpp\n"
#	@$(SCPP) $(SOURCEFILES) > $(NFMINIT)/SCatofn.c
#	@echo "\nchar *nfm_path = \"$(NFMINIT)\";" >> $(NFMINIT)/SCatofn.c
	@acc -c -ansi -O3 -Dclipper $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
	    $(NFMINIT)/SCatofn.c 

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

