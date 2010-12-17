#ifdef reactive
TARGET
PDUkernal.s
#endif

SOURCE
PDUglobals.c
PDMglobals.c

INCLUDE
$(PDU)/include
$(PDM)/include
$(PDM)/pdmapi/include
$(EXNUC)/include
$(GRNUC)/include
$(NFM)/include
$(DBA)/include
$(FORMS)/include
#if defined(X11)
$(XINCL)/include
#endif
$(PDU)/pal/src/pdmr/svs

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDU)/lib/$(TARG)/PDUkernal.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/init

PDUkernal.s:	$(objects)
	@echo "Copying PDUglobals.o and PDMglobals.o to $(DIR)."
	@cp PDUglobals.o $(DIR)
	@cp PDMglobals.o $(DIR)

END_SPECIAL

#endif
