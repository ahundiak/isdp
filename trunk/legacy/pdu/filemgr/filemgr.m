#ifdef reactive
TARGET
PDUfilemgr.s
#endif

SOURCE
PDUbufrs.c
PDUcheckin.c
PDUcheckout.c
PDUfile.c
PDUflag.c
PDUlf_form.c
PDUlist_file.c
PDUlogin.c
PDUmcf_list.c
PDUmisc2.c
PDUp_login.c
PDUsgl_list.c
PDUsort.c
PDUsort_form.c
PDUstring.c
PDUvalidate.c
PDUwrkst_mgr.c
PDUbuffers.c
PDUmodes.c
PDUsort_opt.c
PDUfile_list.c
PDUsv_refrsh.c
PDUdate.c
PDUpart_lst.c
PDUpt_fl_lst.c
PDUcancl_lst.c
PDUwher_used.c
PDUgen_valid.c
PDUfileapi.c
PDUckin_tls.c
PDUflag_form.c
PDUstate_frm.c

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
$(PDU)/lib/$(TARG)/PDUfilemgr.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/filemgr

PDUfilemgr.s:	$(objects_TARGET)
	@echo "Making PDUfilemgr.s for reactive loading."
	@echo
	@-mkstubs -o PDUfilemgr.s -t"Pdu:pdu/filemgr" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from filemgr to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubfmgr.o
	@echo "Compiling PDUstubfmgr.o from PDUfilemgr.s"
	@as -o PDUstubfmgr.o PDUfilemgr.s

END_SPECIAL

#endif
