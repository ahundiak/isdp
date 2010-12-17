#ifdef reactive
TARGET
PDUreports.s
#endif

SOURCE
PDUsort_name.c
PDUcrt_buff.c
PDUdef_crit.c
PDUsrchname.c
PDUget_strin.c
PDUsearch.c
PDUdef_sort.c
PDUlist_rpts.c
PDUsetup_def.c
PDUrpt_form.c
PDUbom_cnts.c
PDUdef_rpt.c
PDUdsp_rpt.c
PDUdel_rpt.c
PDUrpt_tools.c

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
$(PDU)/lib/$(TARG)/PDUreports.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/reports

PDUreports.s:	$(objects_TARGET)
	@echo "Making PDUreports.s for reactive loading."
	@echo
	@-mkstubs -o PDUreports.s -t"Pdu:pdu/reports" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from reports to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubrpts.o
	@echo "Compiling PDUstubrpts.o from PDUreports.s"
	@as -o PDUstubrpts.o PDUreports.s

END_SPECIAL

#endif
