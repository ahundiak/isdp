SPECIAL
#if defined(WIN32) && !defined(WIN32S)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(WIN32S)
!include $(RISDEVDIR)\ristools\include\makeenv.32s
#endif
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END

SRC
$(RISDEVDIR)\risutl\winio

INCLUDE
#if defined(WIN32) || defined(WIN32S)
$(MSTOOLSDIR)\include
#endif
#if defined(DOS)
$(HIGHCDIR)\inc
#endif
$(RISDEVDIR)\risutl\internal

SOURCE
winarg.c
winio.c
winhan.c
winparse.c
winport.c

POST_SPECIAL
#if defined(WIN32) && !defined(WIN32S)
!include $(RISDEVDIR)\risutl\build\rulesc.nt
#endif
#if defined(WIN32S)
!include $(RISDEVDIR)\risutl\build\rulesc.32s
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesc.dos
#endif
END
