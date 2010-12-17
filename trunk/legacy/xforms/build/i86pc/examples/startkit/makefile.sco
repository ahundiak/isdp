XFI          = /usr

 #dmb:04/06/93:Added X11_INCLUDE_LOC
X11_INCLUDE_LOC=/usr/ip32/i_mgui/include

FS_INCLUDE   = /usr/include/X11

#XFI_INC_DIR  = $(XFI)/include/X11
XFI_INC_DIR  = $(XFI)/include

CLIX_FORMS_LIB   = -lXFI_s
SUN_FORMS_LIB    = -lXFI
MIPS_FORMS_LIB   = -lXFI

CLIX_FS_LIB      = -lXFS_s
SUN_FS_LIB       = -lXFS
MIPS_FS_LIB      = -lXFS

# NOTE: This is defined in the production platform. It is not needed
# in the end user's environment.
FORMS_LIB    =

EXE_DIR      = .
EXE          = $(EXE_DIR)/demo

CC           = acc
COPT         =

IPATH        = -I$(XFI_INC_DIR) -I$(FS_INCLUDE) \
               -I$(X11_INCLUDE_LOC) -I$(X11_INCLUDE_LOC)/X11

CFLAGS       = $(COPT) $(IPATH) $(MOPT) $(DOPT)

# For SunOS
SUN_XLIB = -lX11
# For CLIX
CLIX_XLIB = -lX11_s
# For MIPS
MIPS_XLIB = -lX11_s


BOX=`uname -s`
 #dmb:04/06/93:Changing to OS_KEY for SUNOS5
OS_KEY = `uname -s | tr '[a-z]' '[A-Z]'`
OS_VER = `uname -r | sed 's/\..*//'`


objs=exec.o

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
			$(MALLOC_LIB) -lmath -lbsd -lc_s; \
		set +x; \
	elif [ "$(OS_KEY)" = "SCO" ]; \
	then \
		echo; \
		echo "Build with $(SCO_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) $(FORMS_LIB)  \
		  	$(LICTOOL_LIB) $(SCO_FS_LIB) $(UMS_LIB) $(SCO_XLIB) \
			$(MALLOC_LIB) -lm -lsocket -lc_s; \
		set +x; \
	elif [ "$(OS_KEY)" = "IRIX" ]; \
	then \
		echo; \
		echo "Build with $(MIPS_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) $(FORMS_LIB)  \
		  	$(LICTOOL_LIB) $(MIPS_FS_LIB) $(UMS_LIB) $(MIPS_XLIB) \
			$(MALLOC_LIB) -lm -lbsd -lc; \
		set +x; \
	elif [ "$(OS_KEY)" = "SUNOS5" ]; \
	then \
		echo; \
		echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) \
			-lXFI 			\
			$(LICTOOL_LIB) $(SUN_FS_LIB) $(UMS_LIB) $(SUN_XLIB) \
			-lm; \
		set +x; \
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
