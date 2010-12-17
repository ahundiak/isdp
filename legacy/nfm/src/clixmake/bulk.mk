CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
SCBINDIR=../binc100
TARGSTR=-Atarg=c100

SOURCEFILES=../bulkload/FMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmbulk.a \
	$(LIBDIR)/NFMversion.o \
	$(LIBDIR)/libnfmr.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a

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
        -lc_s

NFMBULK=../bulkload
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmbulk

SCPP=$(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMBULK)/SCatofn.c
	@echo "\nchar *nfm_path = \"$(NFMBULK)\";" >> $(NFMBULK)/SCatofn.c
	@acc -c -ansi -O3 -Dclipper $(CFLAGS) $(TARGSTR) -I$(NFMINCL) \
           $(NFMBULK)/SCatofn.c 

image : 
	@echo ""
	acc -O3 -Dclipper $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(LIBDIR)/libnfmsc.o \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

