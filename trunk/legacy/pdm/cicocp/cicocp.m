#ifdef reactive
TARGET
PDMcicocp.s
#endif

SOURCE
PDMcopy_f.c
PDMffast.c
PDMcopy_m.c
PDMassy_mem.c
PDMfunc1.c
PDMcp_files.c
PDMfcopy_m.c
PDMiteminfo.c
PDMn_ci.c
PDMsettools.c
PDMexp_copy.c
PDMsave_part.c
PDMcipart.c
PDMCheckOut.c

INCLUDE
$(PDM)/include
$(PDM)/pdmapi/include
$(PDU)/include
$(NFM)/include
$(RIS)/include
$(RIS)/errmsg

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDM)/lib/$(TARG)/PDMcicocp.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/cicocp

PDMcicocp.s:	$(objects_TARGET)
	@echo "Making PDMcicocp.s for reactive loading."
	@echo
	@-mkstubs -o PDMcicocp.s -t"Pdu:pdm/cicocp" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from cicocp directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubcicoc.o
	@echo "Compiling PDMstubcicoc.o from PDMcicocp.s"
	@as -o PDMstubcicoc.o PDMcicocp.s

END_SPECIAL

#endif
