#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VEsave_rest.I */
extern IGRlong VEconnect_instance_to_gragad __((IGRlong *msg, OM_S_OBJID inst_id, OM_S_OBJID win_id, OMuword win_os));
extern IGRlong VEget_saved_instance_id __((IGRlong *msg, OM_S_OBJID win_id, OMuword win_os, OM_S_OBJID *instance_id));

/* VEsetinq.I */
extern IGRlong VEget_default_instance __((IGRlong *msg, IGRlong *which_error, struct var_list *list));
extern IGRlong VEget_window_instance_data __((IGRlong *msg, OM_S_OBJID win_id, OMuword win_os, IGRlong *which_error, struct var_list *list));
extern IGRlong VEset_window_instance_data __((IGRlong *msg, OM_S_OBJID win_id, OMuword win_os, IGRlong *which_error, struct var_list *list));

#if defined(__cplusplus)
}
#endif


#undef __


