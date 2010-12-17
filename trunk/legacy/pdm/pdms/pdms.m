#ifdef reactive
TARGET
PDMpdms.s
#endif

SOURCE
PDMattr.c
PDMcatalog.c
PDMflag.c
PDMgr_asly.c
PDMnlogin.c
PDMnet.c
PDMpart.c
PDMpartstr.c
PDMs_rtns.c
PDMsearch.c
PDMwf.c
PDMloc_part.c
PDMcat_class.c
PDMcat_attr.c
PDMattr_func.c
PDMupd_mem.c
PDMwhr_usd.c

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
$(PDM)/lib/$(TARG)/PDMpdms.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/pdms

PDMpdms.s:	$(objects_TARGET)
	@echo "Making PDMpdms.s for reactive loading."
	@echo
	@-mkstubs -o PDMpdms.s -t"Pdu:pdm/pdms" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from pdms directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubpdms.o
	@echo "Compiling PDMstubpdms.o from PDMpdms.s"
	@as -o PDMstubpdms.o PDMpdms.s

END_SPECIAL

#endif
