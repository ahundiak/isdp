#ifdef reactive
TARGET
PDMmacros.s
#endif

SOURCE
PDMm_parts.c

INCLUDE
$(PDU)/include
$(PDM)/include
$(PDM)/pdmapi/include
$(NFM)/include
$(RIS)/include
$(FORMS)/include
$(EXNUC)/include

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDM)/lib/$(TARG)/PDMmacros.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/macros

PDMmacros.s:	$(objects_TARGET)
	@echo "Making PDMmacros.s for reactive loading."
	@echo
	@-mkstubs -o PDMmacros.s -t"Pdu:pdm/macros" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from macros directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubmacro.o
	@echo "Compiling PDMstubmacro.o from PDMmacros.s"
	@as -o PDMstubmacro.o PDMmacros.s

END_SPECIAL

#endif

