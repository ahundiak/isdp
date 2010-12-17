#ifdef reactive
TARGET
PDUfunk.s
#endif

SOURCE
GRpuldwnlst.c
PALtools.c
PDMClsCats.c
PDMpdmparams.c
PDMselprt.c
PLM_functs.c
parsit.c
MOlocate.I
PDMchekin.I
PDMdynpar.I
PDMgetrle.I
PDMplprt.I
SelMacUtil.I
parse_fun.I
PDMattach.I
feet_depend.I
PDMmodprt.I
PDMdyncmp.I
PDMcpyprt.I
PALmodsplatr.c
PALmacintf.c
PDMmapcoll.I
PALgetfmt.c
ismacdef.I

INCLUDE
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(PDM)/include
$(PDU)/include
$(NFM)/include
$(FPAL)/include
$(FORMS)/include
#if defined (__Sol2__) || defined (__sgi)
$(XINCL)/include
#endif


SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

CC
$(COMP)

COPT
$(COMP_OPT)

#ifdef bld21x
DOPT 
bld21
#endif

LIB
$(PDU)/lib/$(TARG)/PDUfunk.a
ARCHIVE

#ifdef reactive

POST_SPECIAL

DIR = $(PDU)/config/dload/prod/pdu/pal/src/funk

PDUfunk.s:	$(objects_TARGET)
	@echo "Making PDUfunk.s for reactive loading."
	@echo
	@echo "Moving PALtools.o and PDMselprt.o to .X extensions."
	@mv PALtools.o PALtools.X
	@mv PDMselprt.o PDMselprt.X
	@-mkstubs -o PDUfunk.s -t"Pdu:pdu/pal/src/funk" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from pal/src/funk to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubfunk.o
	@echo "Moving PALtools.X and PDMselprt.X to .o extensions."
	@mv PALtools.X PALtools.o
	@mv PDMselprt.X PDMselprt.o
	@echo "Copying PALtools.o and PDMselprt.o to $(PDU)/config/dload/init."
	@cp PALtools.o $(PDU)/config/dload/init
	@cp PDMselprt.o $(PDU)/config/dload/init
	@echo "Compiling PDUstubfunk.o from PDUfunk.s"
	@as -o PDUstubfunk.o PDUfunk.s

END_SPECIAL

#endif
