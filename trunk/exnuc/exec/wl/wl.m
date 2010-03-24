SRC
$(EXNUC)/exec/wl
 
SOURCE
WLglobal.c
WLIcontext.c
WLImisc.c
WLIscreen.c
WLIwin.c
#if defined (ENV5)
WLIxor.c
#endif
WLcmap.c
WLcolorref.c
WLcontext.c
WLcursor.c
WLdraw.c
WLinit.c
WLmisc.c
WLmouse.c
WLraster.c
WLscr_getset.c
WLsymb.c
WLwin.c
WLwin_getset.c
WLsmart.c
WLopengl.c
#if defined( X11 )
WLIf_X.c
#elif defined( ENV5 )
WLIf_ENV5.c
#elif defined( WIN32 )
WLIf_WIN32.c
#endif
#if defined( X11 ) || defined( ENV5 )
WLIf_XENV5.c
#endif
WLxgl.c

INCLUDE
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
$(EXNUC)/exec/wl
$(EXNUC)/include
#if defined (X11)
$(X11_INC_PATH)
#endif


OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp
