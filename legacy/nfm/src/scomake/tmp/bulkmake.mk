CFLAGS=-g
LIBDIR=../scolib
BINDIR=../scobin
SCBINDIR=../scobin
TARGSTR=
OBJEXT=5

SOURCEFILES=../bulkload/FMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmbulk.a \
	$(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libnfmr.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/libalter.a \
	$(LIBDIR)/libnfmerr.a

LIBRARIES=\
        -lnsl_s \
	-lsocket\
	-lcurses\
        -lUMS \
        -lmalloc 

NFMBULK=../bulkload
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmbulk

SCPP=$(SCBINDIR)/SCcpp

product: $(NFMBULK)/SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMBULK)/SCatofn.c
	@echo "\nchar *nfm_path = \"$(NFMBULK)\";" >> $(NFMBULK)/SCatofn.c
	@cc -g -c  $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
           $(NFMBULK)/SCatofn.c 
	@mv SCatofn.o $(NFMBULK)

image : 
	@echo ""
	cc -g $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	../sc/SCmain.$(OBJEXT) \
	$(NFMBULK)/SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

