#ifdef reactive
TARGET
PDMass.s
#endif

SOURCE
PDMass_struc.c
PDMatt_struc.c
PDMchkin_cit.c
PDMqry_mem.c

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
$(PDM)/lib/$(TARG)/PDMass.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/ass

PDMass.s:	$(objects_TARGET)
	@echo "Making PDMass.s for reactive loading."
	@echo
	@-mkstubs -o PDMass.s -t"Pdu:pdm/ass" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from ass directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubass.o
	@echo "Compiling PDMstubass.o from PDMass.s"
	@as -o PDMstubass.o PDMass.s

END_SPECIAL

#endif

