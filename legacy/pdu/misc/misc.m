#ifdef reactive
TARGET
PDUmisc.s
#endif

SOURCE
PDUnode_info.c
PDUget_node.c
PDUmiscapi.c

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
$(PDU)/lib/$(TARG)/PDUmisc.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/misc

PDUmisc.s:	$(objects_TARGET)
	@echo "Making PDUmisc.s for reactive loading."
	@echo
	@-mkstubs -o PDUmisc.s -t"Pdu:pdu/misc" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from misc to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubmisc.o
	@echo "Compiling PDUstubmisc.o from PDUmisc.s"
	@as -o PDUstubmisc.o PDUmisc.s

END_SPECIAL

#endif
