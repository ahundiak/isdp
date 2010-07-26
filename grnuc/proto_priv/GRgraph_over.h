#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/exec_node/GRgraph_over.I */
extern int ASredirect_msg __((OM_S_MESSAGE *mess, OM_p_CHANNEL_HDR *chan_addr, OM_S_OBJID send_id));
extern int AScompute_and_change_node __((OM_S_OBJID obj_id, struct GRmd_env *env));
extern int ASchange_node __((OM_S_OBJID obj_id, struct GRmd_env *env));

#if defined(__cplusplus)
}
#endif


#undef __
