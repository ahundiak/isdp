COPT
#ifdef NT

#ifdef _DEBUG
-W3 -Zp8 -Gd -nologo -Od -Zi -MTd
#else /* _DEBUG */
-W3 -Zp8 -Gd -nologo -O2
#endif /* _DEBUG */

#else /* NT */
-DBASE_EMS
#endif /* NT */

SRC
$(EXNUC)/om/tools

TARGET
#	if defined (NT)
$(TARGET)/bin/dros.exe
$(TARGET)/bin/OMchecksum.exe
#	else
$(TARGET)/bin/dros
$(TARGET)/bin/edros
$(TARGET)/bin/OMchecksum
#	endif
#	if defined (clipper)
$(TARGET)/bin/istrip
$(TARGET)/bin/digitizer
$(TARGET)/bin/reset_track
#	endif

INCLUDE
$(EXNUC)/include
$(EXNUC)/om/include
$(LIBXC_INC_PATH)
#if defined (ENV5)
$(FORMS_INC_PATH)
#elif defined (X11)
$(XFORMSDP_INC_PATH)
#endif

DEPLIB=dros
$(LIBXC_LIB_PATH)/libxc.a
#	if defined(NT)
$(TARGET)/lib/exnt.lib
#	endif

SOURCE=dros
dros.C
wild_card.c
support.C
tag.C
init.C
#	if defined (clipper)
parddp.C
display.C
#	endif
#	if defined (sparc) || defined (mips)
port.C
#	endif

EXEC=dros
$(TARGET)/bin/dros

LINKLIB=dros
#ifdef INTEL
/usr/lib/libmapmalloc.so
#else
$(LIBXC_LIB_PATH)/libxcmalloc.a
#endif
#	if defined (clipper)
#		if defined (ENV5)
$(FORMS_LIB_PATH)/libforms.a
-ltools_s
#		elif defined (X11)
$(SYSXLIB)
$(XLIB)
$(LINKLIB2)
#		endif
-lc_s
-lmath
#	elif !defined (NT)
-lc
-lm
#	endif

SOURCE=OMchecksum
OMchecksum.c

EXEC=OMchecksum
$(TARGET)/bin/OMchecksum

#	if defined (clipper)
SOURCE=istrip
istrip.c

EXEC=istrip
$(TARGET)/bin/istrip

LINKLIB=istrip
$(LIBXC_LIB_PATH)/libxc.a
-lbsd
-lPW

SOURCE=digitizer
digitizer.c

EXEC=digitizer
$(TARGET)/bin/digitizer

LINKLIB=digitizer
-ltools_s
-lc_s

SOURCE=reset_track
reset_track.c

EXEC=reset_track
$(TARGET)/bin/reset_track

LINKLIB=reset_track
-ltools_s
-lc_s
#	endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

DEPLIB=edros
#	if defined (clipper)
$(LIBXC_LIB_PATH)/libxc.a wild_card.o support.o tag.o parddp.o display.o 
#	endif
#	if defined (sparc) || defined (mips)
$(LIBXC_LIB_PATH)/libxc.a wild_card.o support.o tag.o port.o 
#	endif
#	if defined (i386)
$(LIBXC_LIB_PATH)/libxc.a wild_card.o support.o tag.o
#	endif

#	if defined(NT)
$(TARGET)/lib/exnt.lib
#	endif

SOURCE=edros
edros.C
einit.C

EXEC=edros
$(TARGET)/bin/edros

LINKLIB=edros
#ifdef INTEL
/usr/lib/libmapmalloc.so
#else
$(LIBXC_LIB_PATH)/libxcmalloc.a
#endif
#	if defined (clipper)
#		if defined (ENV5)
$(FORMS_LIB_PATH)/libforms.a
-ltools_s
#		elif defined (X11)
$(SYSXLIB)
$(XLIB)
$(LINKLIB2)
#		endif
-lc_s
-lmath
#	elif !defined (NT)
-lc
-lm
#	endif

