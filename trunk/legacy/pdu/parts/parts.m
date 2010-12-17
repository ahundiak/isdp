#ifdef reactive
TARGET
PDUparts.s
#endif

SOURCE
PDUadd_part.c
PDUpart_form.c
PDUpart_oper.c
PDUchg_part.c
PDUseed_file.c
PDUpart_tls.c
PDUpartsapi.c

INCLUDE
$(INGRHOME)/include
$(PDU)/include
$(PDM)/include
$(PDM)/pdmapi/include
$(EXNUC)/include
$(GRNUC)/include
#if defined (__Sol2__)
$(GRNUC)/ingrsys
#endif
$(NFM)/include
$(DBA)/include
$(FORMS)/include
#if defined(__Sol2__)
$(XINCL)/include
#endif

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDU)/lib/$(TARG)/PDUparts.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/parts

PDUparts.s:	$(objects_TARGET)
	@echo "Making PDUparts.s for reactive loading."
	@echo
	@-mkstubs -o PDUparts.s -t"Pdu:pdu/parts" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from parts to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubparts.o
	@echo "Compiling PDUstubparts.o from PDUparts.s"
	@as -o PDUstubparts.o PDUparts.s

END_SPECIAL

#endif
