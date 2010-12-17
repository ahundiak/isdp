#ifdef reactive
TARGET
PDMmulfile.s
#endif

SOURCE
PDMnew_part.c
PDMadd_del.c

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
$(PDM)/lib/$(TARG)/PDMmulfile.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/mulfile

PDMmulfile.s:	$(objects_TARGET)
	@echo "Making PDMmulfile.s for reactive loading."
	@echo
	@-mkstubs -o PDMmulfile.s -t"Pdu:pdm/mulfile" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from mulfile directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubmulfl.o
	@echo "Compiling PDMstubmulfl.o from PDMmulfile.s"
	@as -o PDMstubmulfl.o PDMmulfile.s

END_SPECIAL

#endif

