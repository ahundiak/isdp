#ifdef reactive
TARGET
PDUpdmr.s
#endif

SOURCE
PDMrassy.c
PDMrattr.c
PDMrbom.c
PDMrcanchko.c
PDMrcatalog.c
PDMrchkin.c
PDMrchkout.c
PDMrcopy.c
PDMrdebug.c
PDMrdetach.c
PDMrdyn_part.c
PDMrflag.c
PDMrfmgr.c
PDMrmisc.c
PDMrnfm_rpts.c
PDMrpart.c 
PDMrpart_p.c
PDMrpartstr.c
PDMrpdm_rpts.c
PDMrrps_f.c
PDMrsearch.c
PDMrtools.c
PDMruser.c
PDMrwf.c
PDUstatus.c
PDMrcriteria.c
PDMrexec.c
PDMrapi.c

INCLUDE
$(PDU)/include
$(PDM)/include
$(PDM)/pdmapi/include
$(NFM)/include
$(EXNUC)/include
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
$(PDU)/lib/$(TARG)/PDUpdmr.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/pdmr

PDUpdmr.s:	$(objects_TARGET)
	@echo "Making PDUpdmr.s for reactive loading."
	@echo
	@echo "Moving PDUstatus.o to extension .X"
	@mv PDUstatus.o PDUstatus.X
	@-mkstubs -o PDUpdmr.s -t"Pdu:/pdu/pdmr" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from pdmr to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubpdmr.o
	@echo "Moving PDUstatus.X to extension .o"
	@mv PDUstatus.X PDUstatus.o
	@echo "Copying PDUstatus.o to $(PDU)/config/dload/init
	@cp PDUstatus.o $(PDU)/config/dload/init
	@echo "Compiling PDUstubpdmr.o from PDUpdmr.s"
	@as -o PDUstubpdmr.o PDUpdmr.s

END_SPECIAL

#endif
