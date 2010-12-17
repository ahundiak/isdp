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
	$(LIBDIR)/librisinit.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a \
	$(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libalter.a \
	$(RISLIB)/ris.a 


LIBRARIES=\
	-lUMS \
	-lcurses \
	-lsocket \
	-lc

SCPP = $(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
#	@$(SCPP) $(SOURCEFILES) > $(NFMINIT)/SCatofn.c
#	@echo "\nchar *nfm_path = \"$(NFMINIT)\";" >> $(NFMINIT)/SCatofn.c
	@cc -c -ansi $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
	    $(NFMINIT)/SCatofn.c 

image : 
	@echo ""
	cc $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
        ../sc/SCmain.$(OBJEXT) \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

