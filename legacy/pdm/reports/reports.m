#ifdef reactive
TARGET
PDMreports.s
#endif

SOURCE
PDMbom_rps.c
PDMcit_rps.c
PDMnfm_rpts.c
PDMpdm_rpts.c
PDMcvt_bufr.c
PDMmove_rpt.c
PDMdef_qry.c
PDMstls.c

INCLUDE
$(PDU)/include
$(PDM)/include
$(PDM)/pdmapi/include
$(RIS)/include
$(NFM)/include
$(DBA)/include
$(FORMS)/include

CC
acc

COPT
$(COMP_OPT)

LIB
$(PDM)/lib/$(TARG)/PDMreports.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/reports

PDMreports.s:	$(objects_TARGET)
	@echo "Making PDMreports.s for reactive loading."
	@echo
	@-mkstubs -o PDMreports.s -t"Pdu:pdm/reports" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from reports directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubrpts.o
	@echo "Compiling PDMstubrpts.o from PDMreports.s"
	@as -o PDMstubrpts.o PDMreports.s

END_SPECIAL

#endif
