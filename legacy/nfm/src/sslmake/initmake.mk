CFLAGS=
LIBDIR=../sollib
BINDIR=../solbin
SCBINDIR=../solbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=7
RISLIB=/usr/ip32/ris/rispsuc/lib/Sol2

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
	$(RISLIB)/ris.a \
	$(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/alter.a

LIBRARIES=\
        -lnsl \
        -lcurses \
	-lUMS \
        -lsocket \
	-ldl

SCPP = $(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
#	@echo "\n\n\n\t...SCcpp\n"
#	@$(SCPP) $(SOURCEFILES) > $(NFMINIT)/SCatofn.c
#	@echo "\nchar *nfm_path = \"$(NFMINIT)\";" >> $(NFMINIT)/SCatofn.c
	@acc -g -c $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
	    $(NFMINIT)/SCatofn.c 

image : 
	@echo ""
	acc -g $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
        ../sc/SCmain.$(OBJEXT) \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

