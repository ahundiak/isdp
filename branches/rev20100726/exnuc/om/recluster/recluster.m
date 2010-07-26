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
$(EXNUC)/om/recluster

INCLUDE
$(EXNUC)/include
$(EXNUC)/om/include

SOURCE=autorecluster
autoreclustr.C

DEPLIB=autorecluster
#ifdef INTEL
/usr/lib/libmapmalloc.so
#else
$(LIBXC_LIB_PATH)/libxcmalloc.a
#endif
$(LIBXC_LIB_PATH)/libxc.a

EXEC=autorecluster
$(TARGET)/bin/autorecluster

DEFINE
CCDEF
OMCPPDEF

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

