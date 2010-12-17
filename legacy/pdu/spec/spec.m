SOURCE
COpdu.S
PDUstartup.S
PDUasmmgr.S

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(PDU)/include
$(PDM)/include
$(EXNUC)/include
$(GRNUC)/include
$(NFM)/include
#if defined (__Sol2__) || defined (__sgi)
$(FORMS)/include
$(UMS)/include
$(XINCL)/include
#endif

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDU)/lib/$(TARG)/PDUspec.a
ARCHIVE
