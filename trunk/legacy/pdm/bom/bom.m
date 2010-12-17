#ifdef reactive
TARGET
PDMbom.s
#endif

SOURCE
PDMactive.c
PDMbom.c
PDMbomrtns.c
PDMreview.c
PDMbom_assy.c
PDMbom_attr.c
PDMgen_bom.c
PDMxsum_rps.c
PDMbom_CID.c
PDMbom_parst.c

INCLUDE
$(PDU)/include
$(PDM)/include
$(PDM)/pdmapi/include
$(NPAL)/include
$(RIS)/include
$(NFM)/include
$(DBA)/include

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDM)/lib/$(TARG)/PDMbom.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/bom

PDMbom.s:	$(objects_TARGET)
	@echo "Making PDMbom.s for reactive loading."
	@echo
	@-mkstubs -o PDMbom.s -t"Pdu:pdm/bom" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from bom directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubbom.o
	@echo "Compiling PDMstubbom.o from PDMbom.s"
	@as -o PDMstubbom.o PDMbom.s

END_SPECIAL

#endif
