#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/node/graph.I */
extern int NDinit_graph __((struct GMgraph *p_graph, int modulo, int nb_elmt, int step_size));
extern int NDremove_graph __((struct GMgraph *p_graph));
extern int NDclear_graph __((struct GMgraph *p_graph));
extern int NDget_graph __((struct GRid *l_initial, int nb_initial, struct GRid *l_tip, int nb_tip, int type_select, struct GMgraph *p_graph));
extern int NDinternal_graph __((struct GRid l_initial[], int nb_initial, struct GMgraph *p_graph));
extern int NDget_list __((int accept_type, int ex_acc, int reject_type, int ex_rej, struct GMgraph *p_graph, int *p_nb_elmt, int size, struct GRid *l_elmt, struct GRid **p_list));
extern int NDbroadcast_graph __((int accept_type, int ex_acc, int reject_type, int ex_rej, OM_S_MESSAGE *msg, OM_E_WRT_FLAG mode, int order, struct GMgraph *p_graph));
extern int NDgm_broad_graph __((int accept_type, int reject_type, int (*broad_fct )(), char *p_broad_arg, int broad_mode, struct GMgraph *p_graph));
extern int NDdep_exist __((struct GRid *l_root, int nb_root, struct GRid *l_tip, int nb_tip));
extern int NDget_type __((struct GRid *l_object, int nb_object, int *l_attr, struct GMgraph *p_graph));
extern int NDcopy_graph __((long *p_msg, int cp_type, struct GRid *l_root, int nb_root, struct GRid *l_tip, int nb_tip, struct GRid *l_ext, int nb_ext, int type_select, struct GRmd_env *p_from_info, struct GRmd_env *p_to_info, struct GMgraph *p_graph, struct NDcp_struct *p_copy));
extern int NDupdate_graph __((int cn_type, int root_compute, struct GRmd_env *p_env, struct GMgraph *p_graph));

#if defined(__cplusplus)
}
#endif


#undef __
