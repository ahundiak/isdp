SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscli/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt

target: sql.lib

sql.lib: $(OBJECTS)
	@echo.
	@echo 	OBJECTS   -to-   $@
	@if exist $@ del $@
	@lib /out:$@ $**

#endif
END

SRC
$(RISDEVDIR)/riscli/sql

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

$(RISDEVDIR)/riscli/sql/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscli/clicom/prt
$(RISDEVDIR)/riscli/dict/prt
$(RISDEVDIR)/riscli/user/prt

SOURCE
sqldel.c
sqldrive.c
sqlexpr.c
sqlindex.c
sqlinsrt.c
sqlmisc.c
sqlpred.c
sqlselct.c
sqltable.c
sqlupdt.c
sqlview.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/riscli/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscli\build\rulesc.nt
#endif
END
