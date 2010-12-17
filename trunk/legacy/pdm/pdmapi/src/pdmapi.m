SOURCE
PMlogin.c
PMdebug.c
PMlogout.c
PMtools.c
PMstrct_tls.c
PMadd_part.c
PMload_files.c
PMload_attrs.c
PMchg_part.c
PMadd_files.c
PMchg_files.c
PMdel_files.c
PMris_tools.c
PMdel_part.c
PMget_trans.c
PMmv_state.c
PMasm_tool.c
PMmodassy.c
PMaddassy.c
PMdefassy.c
PMGenRpt.c
PMChkPrt.c
PMChkOut.c
PMCanCo.c
PMcheckin.c
PMread_buf.c
PMfile_mem.c
PMwrite_buf.c
PMrec_file.c
PMckin_tls.c

INCLUDE
$(PDU)/include
$(PDM)/include
$(NFM)/include
$(PDM)/pdmapi/include
$(DBA)/include
$(RIS)/include
$(FORMS)/include
$(UMS)/include
#if defined (__Sol2__) || defined (__sgi)
$(XINCL)/include
#endif

CC
$(COMP)
 
COPT
$(COMP_OPT)

LIB
$(PDM)/lib/$(TARG)/PDMapi.a
ARCHIVE

