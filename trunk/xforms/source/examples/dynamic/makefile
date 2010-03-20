XFI          = /usr

 #dmb:04/06/93:Added X11_INCLUDE_LOC
X11_INCLUDE_LOC=/usr/ip32/i_mgui/include

FS_INCLUDE   = /usr/include/X11

XFI_INC_DIR  = $(XFI)/include/X11

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
EXE          = $(EXE_DIR)/dynamic

CC           = acc
COPT         = -ansi

IPATH        = -I$(XFI_INC_DIR) -I$(FS_INCLUDE) \
               -I$(X11_INCLUDE_LOC) -I$(X11_INCLUDE_LOC)/X11

CFLAGS       = $(COPT) $(IPATH) $(MOPT) $(DOPT)

# For SunOS
SUN_XLIB = -lX11
# For CLIX
CLIX_XLIB = -lX11_s
# For MIPS
MIPS_XLIB = -lX11_s

HPUX_XLIB = /usr/lib/X11R5/libX11.sl

BOX=`uname -s`
 #dmb:04/06/93:Changing to OS_KEY for SUNOS5
#OS_KEY = `uname -s | tr '[a-z]' '[A-Z]'`
OS_VER = `uname -r | sed 's/\..*//'`

objs=\
    command.o main.o notify.o doform.o dobezel.o do_cbar.o \
	doline.o dotext.o chkerror.o dobutton.o dotoggle.o \
	docheck.o dosym.o doslider.o dodial.o dofield.o \
	dogauge.o doscroll.o domcf.o

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
	elif [ "$(OS_KEY)" = "HPUX" ]; \
	then \
		echo; \
		echo "Build with $(HPUX_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) $(FORMS_LIB)  \
		  	$(LICTOOL_LIB) $(HPUX_FS_LIB) $(UMS_LIB) $(HPUX_XLIB) \
			$(MALLOC_LIB) -lm -lbsdipc -lc; \
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
	elif [ "$(OS_KEY)" = "SUNOS4" ]; \
	then \
		echo; \
		echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
		set -x; \
		$(CC) $(CFLAGS) -o $(EXE) -assert definitions $(objs) \
			-lXFI 			\
			$(LICTOOL_LIB) $(SUN_FS_LIB) $(UMS_LIB) $(SUN_XLIB) \
			-lm -lc; \
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
	elif [ "$(OS_KEY)" = "SUNOS" ]; \
	then \
		if [ "$(OS_VER)" = "4" ]; \
		then \
		  echo; \
		  echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
		  set -x; \
		  $(CC) $(CFLAGS) -o $(EXE) -assert definitions $(objs) \
			  -lXFI 			\
			  $(LICTOOL_LIB) $(SUN_FS_LIB) $(UMS_LIB) $(SUN_XLIB) \
			  -lm -lc; \
		  set +x; \
		elif [ "$(OS_VER)" = "5" ]; \
		then \
		  echo; \
		  echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
		  set -x; \
		  $(CC) $(CFLAGS) -o $(EXE) $(objs) \
			  -lXFI 			\
			  $(LICTOOL_LIB) $(SUN_FS_LIB) $(UMS_LIB) $(SUN_XLIB) \
			  -lm; \
		  set +x; \
		fi; \
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
