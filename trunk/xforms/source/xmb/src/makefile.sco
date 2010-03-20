XFI          = ../../xfi
XFB          = ../
UMS          = /usr
SRC          = .


CURRENT_PROC_TYPE = c100



FS           = /usr
FS_INCLUDE   = $(FS)/include/X11

CLIX_FS_LIB  = -lXFS_s
SUN_FS_LIB   = -lXFS
MIPS_FS_LIB   = -lXFS

#MALLOC_LIB = -lxcmalloc
#if defined(clipper)
MALLOC_LIB = $(XC)/lib/$(CURRENT_PROC_TYPE)/libxcmalloc.a
#else
MALLOC_LIB = $(XC)/lib/libxcmalloc.a
#endif

LIB_DIR      = $(XFI)/lib/$(CURRENT_PROC_TYPE)
FORMS_LIB    = $(LIB_DIR)/libXFI_s.a

#LICTOOL_DIR=/usr/ip32/lictools
#LICTOOL_LIB=$(LICTOOL_DIR)/api.o
#LICTOOL_INCLUDE_FILE=$(LICTOOL_DIR)/api.h

UMS_INCLUDE_DIR  = $(UMS)/include
UMS_ARLIB_DIR  = $(UMS)/lib/$(CURRENT_PROC_TYPE)
UMS_LIB      = $(UMS_ARLIB_DIR)/libUMS.a

CC           = acc
OLD_COPT         = -knr  -O3 -Abss=0 -A"nocwarn=(w178,w190) -Dclipper=1"
COPT         = -ansi -O3 -Abss=0
MOPT         = -Dclipper=1 -Atarg=c100

EXP_IPATH        = -I$(XFI_PUB_INC_DIR) -I$(XFI_PRI_INC_DIR) -I$(XFB_INC_DIR) \
		-I$(FS_INCLUDE) -I$(LICTOOL_DIR)

SAVE_IPATH        = -I$(XFI_INC_DIR) -I$(XFB_INC_DIR) -I$(FS_INCLUDE) \
               -I$(LICTOOL_DIR)

REAL_IPATH        = -I$(XFI_INC_DIR) -I$(XFB_INC_DIR) -I$(UMS_INCLUDE_DIR) \
               -I$(FS_INCLUDE) -I$(LICTOOL_DIR)

IPATH     = -I$(XFI)/include -I$(XMB)/include -I$(UMS_INCLUDE_DIR) \
            -I$(ANSI_INCLUDE) \
            -I$(FS_INCLUDE) -I$(X11_INCLUDE_LOC) -I$(X11_INCLUDE_LOC)/X11 \
            -I$(LICTOOL_DIR)

CFLAGS       = $(COPT) $(IPATH) $(MOPT) $(DOPT)

#EXE_DIR      = $(XMB)/bin/$(CURRENT_PROC_TYPE)
EXE_DIR      = $(XMB)/bin

EXE          = $(EXE_DIR)/xmb

# For SunOS
SUN_XLIB     = -lX11

# For CLIX
CLIX_XLIB    = -lX11_s

# For MIPS
MIPS_XLIB     = -lX11



BOX=`uname -s`
 #dmb:04/06/93:Changing to OS_KEY for SUNOS5
OS_KEY = `uname -s | tr '[a-z]' '[A-Z]'`
OS_VER = `uname -r`


objs=\
	exec.o command.o stub.o whence.o work_form.o toolbox.o free.o \
    define_menu.o validate.o shellvar.o save_menu.o exit_mb.o \
    button_gdt.o symbol_scrl.o symbol_dir.o poke.o swap_btn.o add_btn.o \
    cut_btn.o paste_btn.o preview_menu.o reload.o

$(EXE): $(objs) $(FORMS_LIB) $(UMS_LIB)
	@if [ ! -d $(EXE_DIR) ]; \
	then \
		echo "Create $(EXE_DIR)."; \
		mkdir -p $(EXE_DIR); \
	fi;
	@if [ "$(OS_KEY)" = "SCO" ]; \
	then \
		echo "Build with $(SCO_XLIB) for $(OS_KEY)"; \
		echo ; \
		set -x ; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) $(FORMS_LIB)  \
		  	$(LICTOOL_LIB) $(SCO_FS_LIB) $(UMS_LIB) $(SCO_XLIB) \
			$(MALLOC_LIB) \
			-lm -lsocket -lc_s; \
		set +x ; \
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

