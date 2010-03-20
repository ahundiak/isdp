XFI          = ../xfi
XFUTIL         = ..

CURRENT_PROC_TYPE = c100

FS           = /usr
FS_INCLUDE   = $(FS)/include/X11

CLIX_FS_LIB  = -lXFS_s
SUN_FS_LIB   = -lXFS
MIPS_FS_LIB  = -lXFS

XCMALLOC_LIB = /usr/lib/$(CURRENT_PROC_TYPE)/libxcmalloc.a

LIB_DIR      = $(XFI)/lib/$(CURRENT_PROC_TYPE)
FORMS_LIB    = $(LIB_DIR)/libXFI_s.a

LICTOOL_DIR=/usr/ip32/lictools
#LICTOOL_LIB=$(LICTOOL_DIR)/api.o

CC           = acc
COPT         = -knr  -O3 -Abss=0

IPATH        = -I$(XFI)/include -I$(FS_INCLUDE) -I$(LICTOOL_DIR)
CFLAGS       = $(COPT) $(IPATH)

#EXE_DIR      = ./$(CURRENT_PROC_TYPE)
EXE_DIR      = .

EXE          = $(EXE_DIR)/xPreviewMenu

# For SunOS
SUN_XLIB     = -lX11
# For CLIX
CLIX_XLIB    = -lX11_s
# For MIPS
MIPS_XLIB    = -lX11_s


#BOX=`uname -s`

OBJECTS= xPreviewMenu.o

$(EXE): $(OBJECTS) $(FORMS_LIB)
	@if [ ! -d $(EXE_DIR) ]; \
	then \
		echo "Create $(EXE_DIR)."; \
		mkdir -p $(EXE_DIR); \
	fi;
	@if [ "$(OS_KEY)" = "SCO" ]; \
	then \
		echo ""; \
		echo "Build with $(SCO_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)	\
		  $(FORMS_LIB)				\
		  $(LICTOOL_LIB)			\
		  $(SCO_FS_LIB) $(SCO_XLIB) $(MALLOC_LIB) \
		  -lm -lsocket -lc_s; \
		set +x; \
	elif [ "$(OS_KEY)" = "CLIX" ]; \
	then \
		echo ""; \
		echo "Build with $(CLIX_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)	\
		  $(FORMS_ARLIB)				\
		  $(LICTOOL_LIB)			\
		  $(CLIX_FS_LIB) $(CLIX_XLIB) $(XCMALLOC_LIB) \
		  -lmath -lbsd -lc_s; \
		set +x; \
	elif [ "$(OS_KEY)" = "IRIX" ]; \
	then \
		echo ""; \
		echo "Build with $(MIPS_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)	\
		  $(FORMS_ARLIB)				\
		  $(LICTOOL_LIB)			\
		  $(MIPS_FS_LIB) $(MIPS_XLIB) $(XCMALLOC_LIB) \
		  -lm -lbsd -lc_s; \
		set +x; \
	elif [ "$(OS_KEY)" = "SunOS" ]; \
	then \
		echo ""; \
		echo "Build with $(SUN_XLIB) for $(OS_KEY)";	\
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)		\
		 $(LICTOOL_LIB)					\
		 -lXFI $(SUN_FS_LIB) $(SUN_XLIB) -lm -lc;	\
		set +x; \
	else \
		echo "Unknown OS_KEY $(OS_KEY)"; \
	fi; \
	if [ "${STRIP}" ]; \
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
	ls -ls $(EXE); \
	echo;

xPreviewMenu.o	: xPreviewMenu.c	

tst : $(OBJECTS)
	$(CC) $(CFLAGS) -o tst.tmp $(OBJECTS) \
	  $(FORMS_LIB) -lX11_s -lm -lmalloc -lsocket -lc_s -lg
	mv tst.tmp tst
	ls -ls tst

