#ifdef reactive
TARGET
PDUtools.s
#endif

SOURCE
PDUverify.c
PDUbfr_tools.c  
PDUform.c       
PDUupdat_buf.c 
PDUdebug.c      
PDUstr_attr.c   
PDUvalid.c
PDUlinklist.c
PDUchsym_frm.c
PDUtoolsapi.c
PDUstat.c

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
$(PDU)/lib/$(TARG)/PDUtools.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/tools

PDUtools.s:	$(objects_TARGET)
	@echo "Making PDUtools.s for reactive loading."
	@echo
	@echo "Moving PDUform.o to .X extension."
	@mv PDUform.o PDUform.X
	@-mkstubs -o PDUtools.s -t"Pdu:pdu/tools" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from tools to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubtools.o
	@echo "Moving PDUform.X to .o extension."
	@mv PDUform.X PDUform.o
	@echo "Copying PDUform.o to $(PDU)/config/dload/init."
	@cp PDUform.o $(PDU)/config/dload/init
	@echo "Compiling PDUstubtools.o from PDUtools.s"
	@as -o PDUstubtools.o PDUtools.s

END_SPECIAL

#endif
