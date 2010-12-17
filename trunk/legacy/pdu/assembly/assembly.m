#ifdef reactive
TARGET
PDUassembly.s
#endif

SOURCE
PDUdef_assy.c
PDUassy_tls.c
PDUassyapi.c
PDUrev_assy.c
PDUrevasytls.c


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
#if defined (X11)
$(XINCL)/include
#endif

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDU)/lib/$(TARG)/PDUassembly.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/assembly

PDUassembly.s:	$(objects_TARGET)
	@echo "Making PDUassembly.s for reactive loading."
	@echo
	@-mkstubs -o PDUassembly.s -t"Pdu:pdu/assembly" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from assembly to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubassy.o
	@echo "Compiling PDUstubassy.o from  PDUassembly.s"
	@as -o PDUstubassy.o PDUassembly.s

END_SPECIAL

#endif
