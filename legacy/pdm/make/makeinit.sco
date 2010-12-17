TARGSTR=-Atarg=$(TARG)

PDMINIT = $(PDM)/bin/PDMinit
FTR=/u2/ip32/ftrdp
UMS=/usr/ip32/ums
TARG2=i386

APPOBJECTS=\
	$(PDM)/lib/$(TARG)/PDMinit.a \
	$(PDM)/tools/PDMdbms_f.o \
	$(PDM)/tools/PDMpart_f.o \
	$(PDM)/tools/PDMattr_f.o \
	$(PDM)/tools/PDMstools1.o \
	$(PDM)/tools/PDMstools2.o \
	$(PDM)/ris/PDMrs_tool.o \
	$(PDM)/make/PDMglobals.o \
	$(LIBDIR)/lib$(TARG)/libnfmr.a \
	$(LIBDIR)/lib$(TARG)/libnfma.a \
	$(LIBDIR)/lib$(TARG)/libnfmu.a \
	$(LIBDIR)/lib$(TARG)/libnfmlists.a \
	$(LIBDIR)/lib$(TARG)/libnfmftr.a \
	$(LIBDIR)/lib$(TARG)/libnfmtools.a \
	$(LIBDIR)/lib$(TARG)/libnfmwf.a \
	$(LIBDIR)/lib$(TARG)/libcmdtools.a \
	$(LIBDIR)/lib$(TARG)/libfilexfer.a \
	$(FTR)/lib/$(TARG2)/FTRlib.a \
	$(LIBDIR)/lib$(TARG)/libnfmnet.a \
	$(LIBDIR)/lib$(TARG)/alter.a \
        $(LIBDIR)/lib$(TARG)/libnfmu.a \
	$(LIBDIR)/lib$(TARG)/libnfmwf.a \
	$(LIBDIR)/lib$(TARG)/libdbtools.a \
	$(LIBDIR)/lib$(TARG)/libnfmsql.a \
	$(LIBDIR)/lib$(TARG)/libsystools.a \
	$(LIBDIR)/lib$(TARG)/libnfmmem.a \
	$(LIBDIR)/lib$(TARG)/libtli.a \
	$(LIBDIR)/lib$(TARG)/libnfmerr.a \
	$(RIS)/lib/$(TARG)/ris.a \
	$(LIBDIR)/lib$(TARG)/libnfmmem.a \
	$(UMS)/lib/$(TARG2)/libUMS.a 

APPLIBRARIES=\
        -lcurses \
	-ll \
	-lm \
	-lx \
	-lprot \
	-lsocket \
	-lnsl_s \
	-lmalloc \
	-lc_s \
	-lc \
	-lintl 

OBJECTS = $(APPOBJECTS)

LIBRARIES = $(APPLIBRARIES)

image = $(LIBRARIES) $(OBJECTS)


image : 
	@echo ""
	cc -O3 -Dsco -o $(PDMINIT) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	chmod +s $(PDMINIT)
	strip $(PDMINIT)
	@ls -ls $(PDMINIT)
