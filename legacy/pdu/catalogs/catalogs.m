#ifdef reactive
TARGET
PDUcatalogs.s
#endif

SOURCE
PDUcopy_cat.c
PDUcreat_cat.c
PDUdel_cat.c
PDUdyn_attr.c
PDUmod_cat.c
PDUcat_name.c
PDUcat_attr.c
PDUvalidate.c
PDUbuff.c
PDUcommands.c
PDUfrm_tools.c
PDUparm_form.c
PDUparm_part.c
PDUdef_lib.c
PDUcat_list.c
PDUcatapi.c
PMapi_cat.c

INCLUDE
$(INGRHOME)/include
$(PDU)/include
$(PDM)/include
$(PDM)/pdmapi/include
$(EXNUC)/include
$(GRNUC)/include
#if defined (__Sol2__)
$(GRNUC)/ingrsys
#endif
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
$(PDU)/lib/$(TARG)/PDUcatalogs.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/catalogs

PDUcatalogs.s:	$(objects_TARGET)
	@echo "Making PDUcatalogs.s for reactive loading."
	@echo
	@-mkstubs -o PDUcatalogs.s -t"Pdu:pdu/catalogs" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from catalogs to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubcats.o
	@echo "Compiling PDUstubcats.o from PDUcatalogs.s"
	@as -o PDUstubcats.o PDUcatalogs.s

END_SPECIAL

#endif
