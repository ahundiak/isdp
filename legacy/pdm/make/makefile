TARGSTR=-Atarg=c100

PDMEXEC = ${PDM}/bin/PDMserver

APPOBJECTS=\
        ${PDM}/lib/PDMmain.o \
        ${PDM}/lib/PDMcicocp.a \
        ${PDM}/lib/PDMs.a \
        ${PDM}/lib/PDMreports.a \
        ${PDM}/lib/PDMass.a \
        ${PDM}/lib/PDMmulfile.a \
        ${PDM}/lib/PDMdraw.a \
        ${PDM}/lib/PDMp.a \
        ${PDM}/lib/PDMbom.a \
        ${PDM}/lib/PDMfmgr.a \
        ${PDM}/lib/PDMtools.a \
        ${PDM}/lib/PDMdirris.a \
        $(LIBDIR)/libnfma.a \
        $(LIBDIR)/libnfmu.a \
        $(LIBDIR)/libnfma.a \
        $(LIBDIR)/libnfmlists.a \
        $(LIBDIR)/libnfmsac.a \
        $(LIBDIR)/libcmdtools.a \
        $(LIBDIR)/libnfmwf.a \
        $(LIBDIR)/libdbtools.a \
        $(LIBDIR)/libnfmtools.a \
        $(LIBDIR)/libnfmsql.a \
        $(LIBDIR)/libfilexfer.a \
        $(LIBDIR)/libtli.a \
        $(LIBDIR)/libsystools.a \
        $(LIBDIR)/libnfmmem.a \
        $(LIBDIR)/libnfmnet.a \
        $(LIBDIR)/libtli.a \
        $(LIBDIR)/libnfmerr.a \
        $(DBA)/lib/script.o \
        $(DBA)/lib/report.a \
        $(DBA)/lib/no_mcsl.o \
        $(RIS)/lib/ris.a 

APPLIBRARIES=\
	-lbsd \
	-linc \
	-lnsl_s \
	-ltools_s \
	-lUMS \
	-lc_s \
	-lmath \
	-lxcmalloc \
	-ldevi

OBJECTS = $(APPOBJECTS)

LIBRARIES = $(APPLIBRARIES)

image = $(LIBRARIES) $(OBJECTS)


image : 
	@echo ""
	acc -O3 -Dclipper $(TARGSTR) -o $(PDMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	chmod +s $(PDMEXEC)
	strip $(PDMEXEC)
	@ls -ls $(PDMEXEC)


#acc -g -Dclipper $(TARGSTR) -o $(PDMEXEC) \
