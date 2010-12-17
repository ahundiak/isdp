XFI          = ../xfi

CURRENT_PROC_TYPE = c100

LIB_DIR      = $(XFI)/lib/$(CURRENT_PROC_TYPE)
FORMS_LIB    = $(LIB_DIR)/libXFI_s.a

#LICTOOL_DIR=/usr/ip32/lictools
#LICTOOL_LIB=$(LICTOOL_DIR)/api.o
#LICTOOL_INCLUDE_FILE=$(LICTOOL_DIR)/api.h

XFUTIL         = ..

FS           = /usr
FS_INCLUDE   = $(FS)/include/X11

CLIX_FS_LIB  = -lXFS_s
SUN_FS_LIB   = -lXFS
MIPS_FS_LIB  = -lXFS

#if defined(clipper)
XCMALLOC_LIB = $(XC)/lib/$(CURRENT_PROC_TYPE)/libxcmalloc.a
#else
XCMALLOC_LIB = $(XC)/lib/libxcmalloc.a
#endif

GENMENU      = .
INC          = $(XFI)/include

CC           = acc
COPT         = -knr  -O2

IPATH        = -I../set_text -I$(XFI)/include -I$(FS_INCLUDE) \
               -I$(X11_INCLUDE_LOC) -I$(X11_INCLUDE_LOC)/X11 \
               -I$(LICTOOL_DIR)

CFLAGS       = $(COPT) $(IPATH) $(MOPT) $(DOPT)


# This is where executables go.
#EXE_DIR      = $(XFUTIL)/bin/$(CURRENT_PROC_TYPE)
EXE_DIR      = $(XFUTIL)/bin

GEN_EXE      = $(EXE_DIR)/xgenmenu
MRG_EXE      = $(EXE_DIR)/xmrgpanel

DOC_DIR      = $(XFUTIL)/doc
GENMENU_DOC  = $(DOC_DIR)/xgenmenu.doc

# For SunOS
SUN_XLIB     = -lX11
# For CLIX
CLIX_XLIB    = -lX11_s
# For MIPS
MIPS_XLIB    = -lX11_s


BOX=`uname -s`
 #dmb:04/06/93:Changing to OS_KEY for SUNOS5
OS_KEY = `uname -s | tr '[a-z]' '[A-Z]'`
OS_VER = `uname -r`


################################################



####################################################
# Remove this???
MALLOC=-lxcmalloc
####################################################

both : $(GEN_EXE) $(MRG_EXE) DOC

DOC:
	@mk.genmenu.nt
	@if [ ! -d $(DOC_DIR) ]; \
	then \
		echo; \
		echo "Create $(DOC_DIR)."; \
		echo; \
		mkdir -p $(DOC_DIR); \
	fi;
	@cp genmenu.nt $(GENMENU_DOC); \
	echo; \
	ls -ls $(GENMENU_DOC); \
	echo;

genobjs = \
	genmenu.o \
	GMMenuData.o \
	GMHdrData.o \
	GMOtlData.o \
	GMLineData.o \
	GMParser.o \
	GMPrintDesc.o \
	GMMenu.o

$(GEN_EXE): $(genobjs) $(FORMS_LIB)
	@if [ ! -d $(EXE_DIR) ]; \
	then \
		echo "Create $(EXE_DIR)."; \
		mkdir -p $(EXE_DIR); \
	fi;
	@if [ "$(OS_KEY)" = "SCO" ]; \
	then \
		echo ""; \
		echo "Build with $(SCO_XLIB) for $(OS_KEY)"; \
		set -x ; \
		$(CC) $(CFLAGS) -o $(GEN_EXE) \
		  $(genobjs) $(FORMS_LIB) $(LICTOOL_LIB) \
		  $(SCO_FS_LIB) $(SCO_XLIB) \
		  $(MALLOC_LIB) \
		  -lm -lsocket -lc_s; \
		set +x ; \
	elif [ "$(OS_KEY)" = "SUNOS5" ]; \
	then \
		if [ $(CURRENT_PROC_TYPE) = "i86pc" ]; \
		then \
			echo ""; \
			echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
			set -x ; \
			$(CC) $(CFLAGS) -o $(GEN_EXE) \
			  $(genobjs) -lXFI $(LICTOOL_LIB) \
			  $(SUN_FS_LIB) $(SUN_XLIB) \
			  -lmalloc -lm; \
			set +x ; \
		else \
			echo ""; \
			echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
			set -x ; \
			$(CC) $(CFLAGS) -o $(GEN_EXE) \
			  $(genobjs) -lXFI $(LICTOOL_LIB) \
			  $(SUN_FS_LIB) $(SUN_XLIB) \
			  $(XC)/lib/libxcmalloc.a -lm; \
			set +x ; \
		fi; \
	else \
		echo "Unknown OS_KEY $(OS_KEY)"; \
	fi; \
	if [ "${STRIP}" ]; \
	then \
		echo "Strip $(GEN_EXE)"; \
		strip $(GEN_EXE); \
		if [ "$(OS_KEY)" = "CLIX" ]; \
		then \
		  mcs -c $(GEN_EXE); \
		elif [ "$(OS_KEY)" = "SUNOS5" ]; \
		then \
		  mcs -c $(GEN_EXE); \
		fi; \
	fi; \
	echo; \
	ls -ls $(GEN_EXE); \
	echo;

mrgobjs = \
	mrgpanel.o \
	GMMergePanel.o \
	GMPrintDesc.o \
	GMMenu.o

$(MRG_EXE): $(mrgobjs) $(FORMS_LIB)
	@if [ ! -d $(EXE_DIR) ]; \
	then \
		echo "Create $(EXE_DIR)."; \
		mkdir -p $(EXE_DIR); \
	fi;
	@if [ "$(OS_KEY)" = "SCO" ]; \
	then \
		echo ""; \
		echo "Build with $(SCO_XLIB) for $(OS_KEY)"; \
		set -x ; \
		$(CC) $(CFLAGS) -o $(MRG_EXE) \
		  $(mrgobjs) $(FORMS_LIB) $(LICTOOL_LIB) \
 		  $(SCO_FS_LIB) $(SCO_XLIB) \
		  $(MALLOC_LIB) \
		  -lm -lsocket -lc_s; \
		set +x ; \
	elif [ "$(OS_KEY)" = "SUNOS5" ]; \
	then \
		if [ $(CURRENT_PROC_TYPE) = "i86pc" ]; \
		then \
			echo ""; \
			echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
			set -x ; \
			$(CC) $(CFLAGS) -o $(MRG_EXE) \
			  $(mrgobjs) -lXFI $(LICTOOL_LIB) \
			  $(SUN_FS_LIB) $(SUN_XLIB) \
	   		  -lmalloc -lm; \
			set +x ; \
		else \
			echo ""; \
			echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
			set -x ; \
			$(CC) $(CFLAGS) -o $(MRG_EXE) \
			  $(mrgobjs) -lXFI $(LICTOOL_LIB) \
			  $(SUN_FS_LIB) $(SUN_XLIB) \
	   		  $(XC)/lib/libxcmalloc.a -lm; \
			set +x ; \
		fi; \
	else \
		echo "Unknown OS_KEY $(OS_KEY)"; \
	fi; \
	if [ "${STRIP}" ]; \
	then \
		echo "Strip $(MRG_EXE)"; \
		strip $(MRG_EXE); \
		if [ "$(OS_KEY)" = "CLIX" ]; \
		then \
		  mcs -c $(MRG_EXE); \
		elif [ "$(OS_KEY)" = "SUNOS5" ]; \
		then \
		  mcs -c $(MRG_EXE); \
		fi; \
	fi; \
	echo; \
	ls -ls $(MRG_EXE); \
	echo;


GMHdrData.o : \
	$(INC)/FI.h \
	$(INC)/MI.h \
	$(GENMENU)/GMoutline.h \
	$(GENMENU)/GMerror.h

GMLineData.o : \
	$(INC)/MI.h \
	$(GENMENU)/GMoutline.h \
	$(GENMENU)/GMerror.h

GMMenu.o : \
	$(INC)/FI.h \
	$(INC)/FIdyn.h \
	$(INC)/MI.h \
	$(GENMENU)/GMmenu.h \
	$(GENMENU)/GMerror.h

GMMenuData.o : \
	$(INC)/FI.h \
	$(INC)/FIdyn.h \
	$(INC)/MI.h \
	$(GENMENU)/GMmenu.h \
	$(GENMENU)/GMoutline.h \
	$(GENMENU)/GMerror.h

GMMergePanel.o : \
	$(INC)/FI.h \
	$(INC)/FIdyn.h \
	$(GENMENU)/GMmenu.h \
	$(GENMENU)/GMerror.h

GMOtlData.o : \
	$(GENMENU)/GMoutline.h \
	$(GENMENU)/GMerror.h

GMParser.o : \
	$(GENMENU)/GMoutline.h

GMPrintDesc.o : \
	$(INC)/FI.h \
	$(INC)/FIdyn.h \
	$(GENMENU)/GMmenu.h \
	$(GENMENU)/GMerror.h

genmenu.o : \
	$(INC)/FIdyn.h \
	$(GENMENU)/GMmenu.h \
	$(GENMENU)/GMerror.h

mrgpanel.o : \
	$(INC)/FIdyn.h \
	$(INC)/MI.h \
	$(GENMENU)/GMmenu.h \
	$(GENMENU)/GMerror.h
