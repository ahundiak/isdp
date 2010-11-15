SPECIAL
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END_SPECIAL

SRC
$(RISDEVDIR)/risapp/remove

INCLUDE
#if defined(DOS)
c:\highc\inc
#endif

$(RISDEVDIR)/risapp/remove/prt

SOURCE
#if defined(DOS)
remove.c
remglob.c
#endif

POST_SPECIAL
#if defined(DOS)
!include $(RISDEVDIR)\risapp\build\rulesc.dos
#endif
END
