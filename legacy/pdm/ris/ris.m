#ifdef reactive
TARGET
PDMris.s
#endif

SOURCE
PDMrs_tool.c
PDMrs_fmgr.c
PDMrs_bom.c
PDMrs_cat.c
PDMrs_rpt.c
SQLqry.c

INCLUDE
$(PDM)/include
$(PDM)/pdmapi/include
$(PDU)/include
$(NFM)/include
$(RIS)/include
$(DBA)/include
$(RIS)/errmsg

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDM)/lib/$(TARG)/PDMris.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/ris

PDMris.s:	$(objects_TARGET)
	@echo "Making PDMris.s for reactive loading."
	@echo
	@-mkstubs -o PDMris.s -t"Pdu:pdm/ris" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from ris directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubris.o
	@echo "Compiling PDMstubris.o from PDMris.s"
	@as -o PDMstubris.o PDMris.s

END_SPECIAL

#endif
