SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/risutl/internal/nonfuncs
#endif
END

SRC
$(RISDEVDIR)/risutl/help

INCLUDE
#if defined(unix)
/usr/include
/usr/ip32/helpdp/include
#endif
#if defined(sun)
/usr/5include
#endif
#if defined(__Sol2__) || defined(Soli)
$(INGRHOME)/helpdp/include
#endif
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/risutl/include
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risutl/help/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
hlpdsply.c
#ifdef BUILD_ENV5
main.c
#endif
#ifdef BUILD_X
xmain.c
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.c
#endif
END
