CFLAGS=-g -D_M_TERMINFO
LIBDIR=../scolib
BINDIR=../scobin
SCBINDIR=../scobin
TARGSTR=
OBJEXT=5
RISLIB=/usr/ip32/ris/risdp/lib

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
	$(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/libalter.a \
        $(RISLIB)/rislduld.a    \
	$(RISLIB)/ris.a 


LIBRARIES=\
	-lUMS \
	-lcurses \
	-lsocket \
	-lc

SCPP = $(SCBINDIR)/SCcpp

product: $(NFMINIT)/SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMINIT)/SCatofn.c
	@echo "\nchar *nfm_path = \"$(NFMINIT)\";" >> $(NFMINIT)/SCatofn.c
	@cc -g -c -ansi $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
	    $(NFMINIT)/SCatofn.c 
	@mv SCatofn.o $(NFMINIT)

image : 
	@echo ""
	cc -g $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
        ../sc/SCmain.$(OBJEXT) \
	$(NFMINIT)/SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

