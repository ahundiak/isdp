SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscom/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END

SRC
$(RISDEVDIR)/riscom/network

INCLUDE
#if defined(unix)
/usr/include
$(RISDEVDIR)/risums/unix/include
#endif

#if defined(clipper)
/usr/ip32/dnp/include
#endif

#if defined(sun)
/usr/5include
#endif

#if defined(WIN32)
$(RISDEVDIR)\risums\nt\include
$(MSTOOLSDIR)\include
#endif

#if defined(DOS)
$(HIGHCDIR)\inc
$(UMSDIR)\include
#endif

$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/network/prt
$(RISDEVDIR)/rissrv/server/prt

SOURCE 
netglobs.c
netgnerc.c
netlen.c
netshare.c
netumsg.c
netwrap.c
#if defined(unix)
netdum.c
netdnpdm.c
netl62dm.c
netlocal.c
netmem.c
netpopen.c
nettcp.c
nettcpdm.c
netwrapt.c
netxnsdm.c
#if defined(__clipper__)
netdnp.c
netl62.c
netlocdm.c
netwrapx.c
netxns.c
#endif
#endif
#if defined(WIN32)
netdnpdm.c
netl62.c
netl62dm.c
netlocal.c
netmem.c
nettcp.c
netwrapt.c
netxnsdm.c
#endif
#if defined(DOS)
netdnpdm.c
netdoscm.c
netl62dm.c
netlocdm.c
netxnsdm.c
nettcp.c
netwrapt.c
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/riscom/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscom\build\rulesc.nt
#endif
#if defined (DOS)
!include $(RISDEVDIR)\riscom\build\rulesc.dos
#endif
END
