XFI          = ../../xfi
XFB          = ../
UMS          = /usr
SRC          = .
XC           = /usr

CURRENT_PROC_TYPE = c100



FS           = /usr
FS_INCLUDE   = $(FS)/include/X11

CLIX_FS_LIB  = -lXFS_s
SUN_FS_LIB   = -lXFS
MIPS_FS_LIB   = -lXFS

#MALLOC_LIB = -lxcmalloc

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

IPATH     = -I$(XFI_INC_DIR) -I$(XFB_INC_DIR) -I$(UMS_INCLUDE_DIR) \
            -I$(FS_INCLUDE) -I$(X11_INCLUDE_LOC) -I$(X11_INCLUDE_LOC)/X11 \
            -I$(LICTOOL_DIR)

CFLAGS       = $(COPT) $(IPATH) $(MOPT) $(DOPT)

#EXE_DIR      = $(XFB)/bin/$(CURRENT_PROC_TYPE)
EXE_DIR      = $(XFB)/bin

EXE          = $(EXE_DIR)/xfb

# For SunOS
SUN_XLIB     = -lX11

# For CLIX
CLIX_XLIB    = -lX11_s
HPUX_XLIB    = /usr/lib/X11R5/libX11.sl

# For MIPS
MIPS_XLIB     = -lX11



BOX=`uname -s`
 #dmb:04/06/93:Changing to OS_KEY for SUNOS5
OS_KEY = `uname -s | tr '[a-z]' '[A-Z]'`
OS_VER = `uname -r`


objs=\
	exec.o whence.o work_form.o shellvar.o command.o \
	exit_fb.o change_pv.o character.o validate.o toolbox.o bezel_gdt.o \
	button_gdt.o button_pal.o \
	cklist_gdt.o copy_form.o copy_gdt.o create_grp.o create_lnk.o \
	create_seq.o define_form.o delete_form.o delete_gdt.o \
	delete_grp.o delete_lnk.o delete_seq.o dial_gdt.o drop_grp.o \
	edit_gdt.o err_msg_fld.o fence_copy.o fence_delete.o fence_edit.o \
	fence_move.o fence_undel.o field_gdt.o fit_form.o gauge_gdt.o \
	grid.o group_copy.o group_delete.o group_edit.o group_move.o \
	group_undel.o line_gdt.o move_gdt.o multi_col.o place_cbar.o \
	poke.o preview_form.o rectangle.o review_seq.o review_lnk.o \
	save_form.o save_pv.o scroll_gdt.o show_grp.o slider_gdt.o \
	symbol_dir.o symbol_gdt.o symbol_scrl.o text_gdt.o toggle_gdt.o \
	undelete_gdt.o load_sym.o parse.o exp_preview.o fei.o \
	builder.o proclkb.o talktokb.o


$(EXE): $(objs) $(FORMS_LIB) FBprint_vers.o $(UMS_LIB)
	@if [ ! -d $(EXE_DIR) ]; \
	then \
		echo "Create $(EXE_DIR)."; \
		mkdir -p $(EXE_DIR); \
	fi;
	@if [ "$(OS_KEY)" = "CLIX" ]; \
	then \
		echo "Build with $(CLIX_XLIB) for $(OS_KEY)"; \
		echo ; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) $(FORMS_LIB) FBprint_vers.o \
		  	$(LICTOOL_LIB) $(CLIX_FS_LIB) $(UMS_LIB) $(CLIX_XLIB) \
			$(XC)/lib/$(CURRENT_PROC_TYPE)/libxcmalloc.a \
			-lmath -lbsd -lc_s; \
	elif [ "$(OS_KEY)" = "HPUX" ]; \
	then \
		echo "Build with $(HPUX_XLIB) for $(OS_KEY)"; \
		echo ; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) $(FORMS_LIB) FBprint_vers.o \
		  	$(LICTOOL_LIB) $(HPUX_FS_LIB) $(UMS_LIB) $(HPUX_XLIB) \
			$(MALLOC_LIB) \
			-lm -lbsdipc -lc; \
	elif [ "$(OS_KEY)" = "SUNOS4" ]; \
	then \
		echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
		$(CC) $(CFLAGS) -o $(EXE) -assert definitions $(objs) \
			$(XC)/lib/libxcmalloc.a \
			-lXFI FBprint_vers.o			\
			$(LICTOOL_LIB) $(SUN_FS_LIB) $(UMS_LIB) \
			$(SUN_XLIB) -lm -lc; \
	elif [ "$(OS_KEY)" = "SUNOS5" ]; \
	then \
		if [ $(CURRENT_PROC_TYPE) = "i86pc" ]; \
		then \
			echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
			$(CC) $(CFLAGS) -o $(EXE) $(objs) \
				-lXFI FBprint_vers.o			\
				$(LICTOOL_LIB) $(SUN_FS_LIB) $(UMS_LIB) $(SUN_XLIB) \
				-lmalloc -lm; \
		else \
			echo "Build with $(SUN_XLIB) for $(OS_KEY)"; \
			$(CC) $(CFLAGS) -o $(EXE) $(objs) \
				-lXFI FBprint_vers.o			\
				$(LICTOOL_LIB) $(SUN_FS_LIB) $(UMS_LIB) $(SUN_XLIB) \
				$(XC)/lib/libxcmalloc.a -lm; \
		fi; \
	elif [ "$(OS_KEY)" = "IRIX" ]; \
	then \
		echo "Build with $(MIPS_XLIB) for $(OS_KEY)"; \
		echo ; \
		set -x ; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) $(FORMS_LIB) FBprint_vers.o \
		  	$(LICTOOL_LIB) $(MIPS_FS_LIB) $(UMS_LIB) $(MIPS_XLIB) \
			$(XC)/lib/libxcmalloc.a -lm -lbsd -lc; \
		set - ; \
	else \
		echo "Unknown OS_KEY $(OS_KEY)"; \
	fi; \
	rm FBprint_vers.o
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

exec.o: exec.c				\
	$(XFB)/include/FB.h		\
	$(XFB)/include/NFBpriv.h \
	$(LICTOOL_INCLUDE_FILE)

REALexec.o: exec.c				\
	$(XFB)/include/FB.h		\
	$(XFB)/include/NFBpriv.h	\
	$(LICTOOL_DIR)/api.h

work_form.o:	 work_form.c		\
	$(XFB)/include/FB.h		\
	$(XFB)/include/NFBpriv.h

FBprint_vers.o:
	@if [ "${PROD_VERSION}" ]; \
	 then \
	  echo "XFB_VERSION is \"${PROD_VERSION}\""; \
	  sed -e "/#define/s/XFB_VERSION[ 	].*$$/XFB_VERSION \"${PROD_VERSION}\"/" \
 	   FBprint_vers.c >FBv.ctmp; \
	 else \
	  echo "XFB_VERSION is \"00.00.00.00\""; \
	  sed -e "/#define/s/XFB_VERSION[ 	].*$$/XFB_VERSION \"00.00.00.00\"/" \
 	   FBprint_vers.c >FBv.ctmp; \
	 fi; \
	 mv -f FBv.ctmp FBprint_vers.c; \
	 if [ "${BUILD_DATE}" ]; \
	 then \
	  echo "XFB_DATE is \"${BUILD_DATE}\""; \
	  sed -e "/#define/s/XFB_DATE[ 	].*$$/XFB_DATE \"${BUILD_DATE}\"/" \
 	   FBprint_vers.c >FBv.ctmp; \
	 else \
	  echo "XFB_DATE is \"`date`\""; \
	  sed -e "/#define/s/XFB_DATE[ 	].*$$/XFB_DATE \"`date`\"/" \
 	   FBprint_vers.c >FBv.ctmp; \
	 fi; \
	 mv -f FBv.ctmp FBprint_vers.c
	@$(CC) $(CFLAGS) -c FBprint_vers.c

tst : $(objs)
	$(CC) $(CFLAGS) -o tst.tmp \
	  $(objs) -lXFI -lX11_s -lmath -ldmalloc -lbsd -lc_s -lg
	mv tst.tmp tst
	ls -ls tst

