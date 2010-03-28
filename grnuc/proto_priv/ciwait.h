#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/setup/ciwait.I */
extern int CIclock __((char *msg1, char *msg2));
extern int CImv_clock __((int val, int pid));
extern char *CIfm_cut_path __((char *in, int n, char *out));
extern int CIcci_form_process __((int label, struct FI_X_data_st *in));
extern void CIcci_out_form __((int title, OM_S_OBJID ciid, char *line[FI_X_LINE_LEN ], int count, char *help));
extern int CIstart_clock __((char *file));
static int CIcci_rc __((int cci_pid));
extern int CIpipe __((OM_S_OBJID ciid, int argc, char **argv));

#if defined(__cplusplus)
}
#endif


#undef __
