SPECIAL
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END_SPECIAL

SRC
$(RISDEVDIR)\risutl\remove

INCLUDE
#if defined(DOS)
$(HIGHCDIR)\inc
$(RISDEVDIR)\risutl\remove\prt
#endif

SOURCE
#if defined(DOS)
remove.c
remglob.c
#endif

POST_SPECIAL
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesc.dos
#endif
END
