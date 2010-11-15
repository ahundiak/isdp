SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscli/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt

target: user.lib

user.lib: $(OBJECTS)
	@echo.
	@echo 	OBJECTS   -to-   $@
	@if exist $@ del $@
	@lib /out:$@ $**

#endif
END

SRC
$(RISDEVDIR)/riscli/user

INCLUDE
#if defined(sun)
/usr/5include
#endif
#if defined(unix)
/usr/include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\include
#endif

$(RISDEVDIR)/riscli/include
$(RISDEVDIR)/riscli/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal

$(RISDEVDIR)/riscli/user/prt
$(RISDEVDIR)/riscom/arch/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/network/prt
$(RISDEVDIR)/riscli/clicom/prt
$(RISDEVDIR)/riscli/dict/prt
$(RISDEVDIR)/riscli/file/prt

SOURCE
usracc.c
usrcnv.c
usrdb.c
usrerror.c
usrexebl.c
usrexec.c
usrglob.c
usrinit.c
usrkill.c
usrmisc.c
usrsndrc.c
usrsrv.c
usrtab.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/riscli/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscli\build\rulesc.nt
#endif
END
