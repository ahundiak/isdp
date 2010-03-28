#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPsvinquire.I */
extern int DPsi_savvw_name __((IGRlong *msg, IGRchar inq0_set1, IGRlong *which_error, struct var_list *var_list, GRspacenum osnum, IGRchar *savedvw_name));
extern int DPsetinqsavvw __((IGRlong *msg, IGRchar inq0_set1, IGRlong *which_error, struct var_list *var_list, GRspacenum osnum, GRobjid vw_objid));

#if defined(__cplusplus)
}
#endif


#undef __
