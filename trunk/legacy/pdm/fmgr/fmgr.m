#ifdef reactive
TARGET
PDMfmgr.s
#endif

SOURCE
PDMfmgr_m.c
PDMfmgr_f.c
PDMfmgr_in.c
PDMfmgr_out.c
PDMffmgr_out.c
PDMffilemgr.c
PDMfmgr_cpy.c
PDMfmgr_fns.c
PDMco_lfm.c
PDMco_updlfm.c

INCLUDE
$(PDU)/include
$(PDM)/include
$(PDM)/pdmapi/include
$(RIS)/include
$(NFM)/include

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDM)/lib/$(TARG)/PDMfmgr.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/fmgr

PDMfmgr.s:	$(objects_TARGET)
	@echo "Making PDMfmgr.s for reactive loading."
	@echo
	@-mkstubs -o PDMfmgr.s -t"Pdu:pdm/fmgr" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from fmgr directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubfmgr.o
	@echo "Compiling PDMstubfmgr.o from PDMfmgr.s"
	@as -o PDMstubfmgr.o PDMfmgr.s

END_SPECIAL

#endif
