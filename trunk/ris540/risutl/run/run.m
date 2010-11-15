SPECIAL
!include $(RISDEVDIR)\ristools\include\makeenv.nt
END

SRC
$(RISDEVDIR)\risutl\run

INCLUDE
$(MSTOOLSDIR)\include
$(RISDEVDIR)\riscom\include
$(RISDEVDIR)\risutl\run\prt

SOURCE
runmain.c

POST_SPECIAL
!include $(RISDEVDIR)\risutl\build\rulesc.nt
END
