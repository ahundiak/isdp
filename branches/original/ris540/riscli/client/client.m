SPECIAL
#if defined(unix) 
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscli/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt

target: client.lib

client.lib: $(OBJECTS)
	@echo.
	@echo 	OBJECTS   -to-   $@
	@if exist $@ del $@
	@lib /out:$@ $**

#endif
END

SRC
$(RISDEVDIR)/riscli/client

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
$(RISDEVDIR)/riscli/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal

$(RISDEVDIR)/riscli/client/prt
$(RISDEVDIR)/riscli/clicom/prt
$(RISDEVDIR)/riscom/arch/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/network/prt
$(RISDEVDIR)/riscom/parse/prt
$(RISDEVDIR)/riscli/dict/prt
$(RISDEVDIR)/riscli/file/prt
$(RISDEVDIR)/riscli/sql/prt
$(RISDEVDIR)/riscli/trans/prt
$(RISDEVDIR)/riscli/user/prt

SOURCE
clibuff.c
clicksum.c
cliclear.c
cliclose.c
clicnv.c
clidebug.c
clierbuf.c
cliexec.c
clifetch.c
cligetfl.c
cliglob.c
cliid.c
cliinit.c
clilocfl.c
climain.c
cliprep.c
clischmg.c
clishhsh.c
clishmem.c
clishmgr.c
clishsrv.c
clishstm.c
clisig.c
clisndrc.c
clisserr.c
clistmst.c
clisvglb.c
clitab.c
cliterm.c
clitrans.c
clivers.c
POST_SPECIAL
#if defined(unix) 
include $(RISDEVDIR)/riscli/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscli\build\rulesc.nt
#endif
END

