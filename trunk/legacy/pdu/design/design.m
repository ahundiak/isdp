#ifdef reactive
TARGET
PDUdesign.s
#endif

SOURCE
PDUstartupi.I
COpdui.I        
PDUactdeact.C   
PDUmessage.C    
PDUdsgnmsg.C    
PDUtopdown.c
PDUplpart.c     
PDUverify.c     
PDUexec.c       
PDUextern.c     
PDUglobal.c     
PDUmath.c       
PDUrefresh.c    
PDUtools.c
PDUdirectory.I  
PDUpointer.I    
PDUbuffer.I     
PDUcheckin.I    
PDUparm_part.I  
PDUtext.I       
PDUcregra.I     
PDUpart.I       
PDUassembly.I
PDUexp.I
PDUdsgn_frm.c
PDUdyn_form.c
PDUvalid.c
PDUgrpart.I
PDUcoorsys.I
PDUconvert.I
PDUopt_form.c
PDUdsp_att.c
PDUatt_list.c
PDUdebug.c
PDUdsgn_list.c
PDUatt_orig.c
PDUm_view_pt.C
PDUdsgnapi.c
PMdlprto.I
PMplprto.I
PDUpost_db.I
PDUexfrm_tls.c
PDUloadhooks.I
PDUemshooks.I
PDUasmfrm.I
PDUdispasm.I
PDUcheckout.I
PDUasmmgri.I
PDUtdseed.c
PDUpath.I
PDUmlibutil.C

INCLUDE
$(INGRHOME)/include
$(PDU)/include
$(PDU)/spec
$(PDM)/include
$(PDM)/pdmapi/include
$(EXNUC)/include
#if defined (__Sol2__)
$(GRNUC)/ingrsys
#endif
$(GRNUC)/include
$(BS)/include
$(NFM)/include
$(DBA)/include
$(FORMS)/include
$(UMS)/include
#if defined(X11)
$(XINCL)/include
#endif

SPEC
$(PDU)/spec
$(GRNUC)/spec
$(EXNUC)/spec
$(EXNUC)/om/spec
$(EXNUC)/exec/spec
$(EXNUC)/fi/spec

OPP
$(EXNUC)/bin/opp -i $(MKDOPTS) -D

OMCPP
$(EXNUC)/bin/omcpp $(MKDOPTS) 

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDU)/lib/$(TARG)/PDUdesign.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/design

PDUdesign.s:	$(objects_TARGET)
	@echo "Making PDUdesign.s for reactive loading."
	@echo
	@echo "Moving COpdui.o and PDUstartupi.o to .X extensions."
	@mv COpdui.o COpdui.X
	@mv PDUstartupi.o PDUstartupi.X
	@-mkstubs -o PDUdesign.s -t"Pdu:pdu/design" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from design to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubdsgn.o 
	@echo "Moving COpdui.X and PDUstartupi.X to .o extensions."
	@mv COpdui.X COpdui.o
	@mv PDUstartupi.X PDUstartupi.o
	@echo "Copying COpdui.o and PDUstartupi.o to $(PDU)/config/dload/init."
	@cp COpdui.o $(PDU)/config/dload/init
	@cp PDUstartupi.o $(PDU)/config/dload/init
	@echo "Compiling PDUstubdsgn.o from PDUdesign.s"
	@as -o PDUstubdsgn.o PDUdesign.s

END_SPECIAL

#endif

