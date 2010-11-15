SPECIAL
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscli/internal/nonfuncs
END

SRC
$(RISDEVDIR)/riscli/tools

INCLUDE
#if defined(sun) 
/usr/5include
#endif
/usr/include

$(RISDEVDIR)/riscli/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risapp/include

$(RISDEVDIR)/riscli/tools/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/network/prt

SOURCE
#if defined(unix) && !defined(sco)
cnvschfl.rc
#endif
mkkeydoc.c

POST_SPECIAL
include $(RISDEVDIR)/riscli/build/rules.c
#if defined(unix) && !defined(sco)
include $(RISDEVDIR)/riscli/build/rules.rc
#endif
END
