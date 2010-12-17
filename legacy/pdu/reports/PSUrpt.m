SOURCE
MRPinit_var.c
rMRPinit_var.c
PSUtools.c
PSUformat.c
MRPdyn_gad.c
MRPforms_tls.c
PSUcom_tls.c
rMRPmessage.c
display_rpt.c
PDUblk_frm.c


INCLUDE
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
$(UMS)/include
$(FORMS)/include
#if defined(X11)
$(XINCL)/include
#endif

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
$(PDU)/lib/$(TARG)/PDUpsurpt.a
ARCHIVE
