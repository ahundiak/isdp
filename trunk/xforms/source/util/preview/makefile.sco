XFI          = ../xfi
XFUTIL       = ..

CURRENT_PROC_TYPE = c100

FS           = /usr
FS_INCLUDE   = $(FS)/include/X11

CLIX_FS_LIB  = -lXFS_s
SUN_FS_LIB   = -lXFS
MIPS_FS_LIB  = -lXFS

##if defined(mips)
XCMALLOC_LIB = $(XC)/lib/libxcmalloc.a
##else
#XCMALLOC_LIB = /usr/lib/$(CURRENT_PROC_TYPE)/libxcmalloc.a
##endif

LIB_DIR      = $(XFI)/lib/$(CURRENT_PROC_TYPE)
FORMS_LIB    = $(LIB_DIR)/libXFI_s.a

#LICTOOL_DIR=/usr/ip32/lictools
#LICTOOL_LIB=$(LICTOOL_DIR)/api.o
#LICTOOL_INCLUDE_FILE=$(LICTOOL_DIR)/api.h

CC           = acc
COPT         = -knr  -O3 -Abss=0

IPATH        = -I$(XFI)/include -I$(FS_INCLUDE) \
               -I$(X11_INCLUDE_LOC) -I$(X11_INCLUDE_LOC)/X11 \
               -I$(LICTOOL_DIR)

CFLAGS       = $(COPT) $(IPATH) $(MOPT) $(DOPT)

#EXE_DIR      = $(XFUTIL)/bin/$(CURRENT_PROC_TYPE)
EXE_DIR      = $(XFUTIL)/bin

EXE          = $(EXE_DIR)/xPreviewForm

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


objs= xPreviewForm.o

$(EXE): $(objs) $(FORMS_LIB)
	@if [ ! -d $(EXE_DIR) ]; \
	then \
		echo "Create $(EXE_DIR)."; \
		mkdir -p $(EXE_DIR); \
	fi;
	@if [ "$(OS_KEY)" = "CLIX" ]; \
	then \
		echo; \
		echo "Build with $(CLIX_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) $(FORMS_LIB)  \
		  	$(LICTOOL_LIB) $(CLIX_FS_LIB) $(UMS_LIB) $(CLIX_XLIB) \
			$(XC)/lib/$(CURRENT_PROC_TYPE)/libxcmalloc.a \
			-lmath -lbsd -lc_s; \
		set +x; \
	elif [ "$(OS_KEY)" = "SCO" ]; \
	then \
		echo; \
		echo "Build with $(SCO_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) $(FORMS_LIB)  \
		  	$(LICTOOL_LIB) $(SCO_FS_LIB) $(UMS_LIB) $(SCO_XLIB) \
			$(MALLOC_LIB) \
			-lm -lsocket -lc_s; \
		set +x; \
	elif [ "$(OS_KEY)" = "IRIX" ]; \
	then \
		echo; \
		echo "Build with $(MIPS_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) $(FORMS_LIB)  \
		  	$(LICTOOL_LIB) $(MIPS_FS_LIB) $(UMS_LIB) $(MIPS_XLIB) \
			$(XC)/lib/libxcmalloc.a -lm -lbsd -lc; \
		set +x; \
	else \
		echo "Unknown OS_KEY $(OS_KEY)"; \
	fi;
	@if [ "${STRIP}" ]; \
	then \
		echo "Strip $(EXE)"; \
		strip $(EXE); \
		if [ "$(OS_KEY)" = "SUNOS5" ]; \
		then \
		  echo "mcs $(EXE)"; \
		  mcs -c $(EXE); \
		elif [ "$(OS_KEY)" = "CLIX" ]; \
		then \
		  echo "mcs $(EXE)"; \
		  mcs -c $(EXE); \
		fi; \
	fi; \
	echo; \
	ls -ls $(EXE);
	@echo

OLD_$(EXE): $(OBJECTS) $(FORMS_LIB)
	@if [ ! -d $(EXE_DIR) ]; \
	then \
		echo "Create $(EXE_DIR)."; \
		mkdir -p $(EXE_DIR); \
	fi;
	@if [ "$(BOX)" = "CLIX" ]; \
	then \
		echo ""; \
		echo "Build with $(CLIX_XLIB) for $(BOX)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)	\
		  $(FORMS_LIB)				\
		  $(LICTOOL_LIB)			\
		  $(CLIX_FS_LIB) $(CLIX_XLIB) $(XCMALLOC_LIB) \
		  -lmath -lbsd -lc_s; \
		set +x; \
	elif [ "$(BOX)" = "IRIX" ]; \
	then \
		echo ""; \
		echo "Build with $(MIPS_XLIB) for $(BOX)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)	\
		  $(FORMS_LIB)				\
		  $(LICTOOL_LIB)			\
		  $(MIPS_FS_LIB) $(MIPS_XLIB) $(XCMALLOC_LIB) \
		  -lm -lbsd -lc; \
		set +x; \
	elif [ "$(BOX)" = "SunOS" ]; \
	then \
		echo ""; \
		echo "Build with $(SUN_XLIB) for $(BOX)";	\
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)		\
		 $(LICTOOL_LIB)					\
		 -lXFI $(SUN_FS_LIB) $(SUN_XLIB) -lm -lc;	\
		set +x; \
	else \
		echo "Unknown BOX $(BOX)"; \
	fi; \
	if [ "${STRIP}" ]; \
	then \
		echo "Strip $(EXE)"; \
		strip $(EXE); \
		mcs -c $(EXE); \
	fi; \
	echo; \
	ls -ls $(EXE); \
	echo;

xPreviewForm.o	: xPreviewForm.c	\
	$(LICTOOL_INCLUDE_FILE)

