CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
SCBINDIR=../sunbin
USR5LIB=/usr/5lib
TARGSTR=
OBJEXT=6
RISLIB=/usr/ip32/ris/rispsuc/lib/sun

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
        $(USR5LIB)/libcurses.a  \
        -lxc \
	-lUMS \
        -lxcmalloc \
        $(USR5LIB)/libc.a

SCPP = $(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
#	@/usr/5bin/echo "\n\n\n\t...SCcpp\n"
#	@$(SCPP) $(SOURCEFILES) > $(NFMINIT)/SCatofn.c
#	@/usr/5bin/echo "\nchar *nfm_path = \"$(NFMINIT)\";" >> $(NFMINIT)/SCatofn.c
	@acc -c $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
	    $(NFMINIT)/SCatofn.c 

image : 
	@/usr/5bin/echo ""
	acc $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
        ../sc/SCmain.$(OBJEXT) \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	@/usr/5bin/echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@/usr/5bin/echo ""

