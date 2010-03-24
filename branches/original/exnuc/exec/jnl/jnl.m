SRC
$(EXNUC)/exec/jnl

SOURCE
edtjnl.c

INCLUDE
$(EXNUC)/include
#if defined (X11)
$(X11_INC_PATH)
#endif

EXEC
$(TARGET)/bin/edt_jnl

LINKLIB
#if defined(X11)
#if defined(CLIX)
$(X11_LIB_PATH)/libXt_s.a
$(X11_LIB_PATH)/libX11_s.a
-lbsd
-lc_s
#else
$(XLIB)
#endif
#if defined (SUNOS5)
-lICE
-lSM
-lsocket
-lnsl
-ldl
-lw
#endif
#endif
