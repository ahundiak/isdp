#ifdef reactive
TARGET
PDUmacros.s
#endif

SOURCE
PDUm_login.c
PDUm_logout.c
PDUm_chkout.c
PDUm_chkin.c
PDUm_cpfiles.c
PDUm_cat.c
PDUm_add_pt.c
PDUm_chg_pt.c
PDUactdeact.c

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

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDU)/lib/$(TARG)/PDUmacros.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/macros

PDUmacros.s:	$(objects_TARGET)
	@echo "Making PDUmacros.s for reactive loading."
	@echo
	@-mkstubs -o PDUmacros.s -t"Pdu:pdu/macros" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from macros to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubmacro.o
	@echo "Compiling PDUstubmacro.o from PDUmacros.s"
	@as -o PDUstubmacro.o PDUmacros.s

END_SPECIAL

#endif
