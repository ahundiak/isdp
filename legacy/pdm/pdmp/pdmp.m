#ifdef reactive
TARGET
PDMpdmp.s
#endif

SOURCE
PDMmacros.c
PDMcp_macro.c
PDMmac_cpio.c
PDMpara_cat.c
PDMadd_fly.c
PDMppart.c
PDMpara_ass.c
PDMmod_del.c
PDMpar_part.c
PDMmod_part.c

INCLUDE
$(PDM)/include
$(PDM)/pdmapi/include
$(PDU)/include
$(NFM)/include
$(RIS)/include
$(RIS)/errmsg
$(FORMS)/include

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDM)/lib/$(TARG)/PDMpdmp.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/pdmp

PDMpdmp.s:	$(objects_TARGET)
	@echo "Making PDMpdmp.s for reactive loading."
	@echo
	@-mkstubs -o PDMpdmp.s -t"Pdu:pdm/pdmp" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from pdmp directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubpdmp.o
	@echo "Compiling PDMstubpdmp.o from PDMpdmp.s"
	@as -o PDMstubpdmp.o PDMpdmp.s

END_SPECIAL

#endif
