SPECIAL
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END_SPECIAL

SRC
$(RISDEVDIR)/riscli/dosrem

INCLUDE
#if defined(DOS)
$(HIGHCDIR)\inc
#endif

$(RISDEVDIR)/riscli/dosrem/prt

SOURCE
#if defined(DOS)
remglob.c
remove.c
#endif

POST_SPECIAL
#if defined(DOS)
!include $(RISDEVDIR)\riscli\build\rulesc.dos
#endif
END
