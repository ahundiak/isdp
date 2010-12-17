#ifdef reactive
TARGET
PDMtools.s
#endif

SOURCE
PDMattr_f.c
PDMbom_f.c
PDMbommnpl.c
PDMctools.c
PDMdbms_f.c
PDMdyn_tbd.c
PDMdynamic.c
PDMpart_f.c
PDMrefresh.c
PDMreport_f.c
PDMstools1.c
PDMstools2.c
PDMbom_tools.c
PDMlfm_tools.c
PDMrep_tools.c
PDMtable_f.c
PDMwf_acl.c
PDMdebug.c
PDMmisc.c
PDMquery_cat.c
PDMptools.c
PDMpart_p.c
PDMviews.c
PDMpget_attr.c
PDMfasttool.c
PDMpara_tool.c
PDMpdms_tool.c
PDMfmgr_tool.c
PDMcico_tool.c
PDMtimestamp.c


INCLUDE
$(PDM)/include
$(PDM)/pdmapi/include
$(PDU)/include
$(NFM)/include
$(RIS)/include
$(RIS)/errmsg
$(DBA)/include

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDM)/lib/$(TARG)/PDMtools.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdm/tools

PDMtools.s:	$(objects_TARGET)
	@echo "Making PDMtools.s for reactive loading."
	@echo
	@-mkstubs -o PDMtools.s -t"Pdu:pdm/tools" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from tools directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubtools.o
	@echo "Compiling PDMstubtools.o from PDMtools.s"
	@as -o PDMstubtools.o PDMtools.s

END_SPECIAL

#endif
