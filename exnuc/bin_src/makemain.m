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
$(EXNUC)/bin

SOURCE
APP_main.C

INCLUDE
$(EXNUC)/include
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
#if defined (X11)
$(X11_INC_PATH)
#endif

LIB
main.o

OMCPP
$(BASE)/bin/omcpp
