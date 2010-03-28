#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPsetinq.I */
extern int DPsi_gg_name __((IGRlong *msg, IGRchar inq0_set1, IGRlong *which_error, struct var_list *var_list, GRspacenum osnum, IGRchar *gragad_name, IGRchar calc_info, IGRchar update));
extern int DPsetinqgragad __((IGRlong *msg, IGRchar inq0_set1, IGRlong *which_error, struct var_list *var_list, GRspacenum osnum, GRobjid gragad_objid, IGRchar calc_info, IGRchar update));
extern int GRwnparam __((IGRlong *msg, IGRshort *set0_inq1, struct GRid *win_id, IGRlong *which_error, IGRint var_list));

#if defined(__cplusplus)
}
#endif


#undef __
