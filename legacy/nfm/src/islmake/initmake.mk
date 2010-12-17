CC=/opt/SUNWspro/bin/cc
CFLAGS=
LIBDIR=../tdlib
BINDIR=../tdbin
SCBINDIR=../tdbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=9
RISLIB=/opt/ingr/ris/risdp/lib

NFM=..
NFMINIT=$(NFM)/initial
NFMINCL=$(NFM)/include
NFMSC=$(NFM)/sc
NFMEXEC=$(BINDIR)/Nfminit

SOURCEFILES=$(NFM)/initial/NFMi_init.c

OBJECTS=\
	$(LIBDIR)/libnfmsc.a \
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
	$(LIBDIR)/libalter.a

LIBRARIES=\
        -lnsl \
        /usr/ccs/lib/libcurses.a \
	/opt/ingr/ums/lib/i86pc/libUMS.a \
        -lsocket \
	-ldl

SCPP = $(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
#	@$(SCPP) $(SOURCEFILES) > $(NFMINIT)/SCatofn.c
#	@echo "\nchar *nfm_path = \"$(NFMINIT)\";" >> $(NFMINIT)/SCatofn.c
	@$(CC) -g -c $(CFLAGS) $(OSFLAG) $(TARGSTR) -I$(NFMINCL) \
	    $(NFMINIT)/SCatofn.c 

image : 
	@echo "\n\nimage......"
	$(CC) -g $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

