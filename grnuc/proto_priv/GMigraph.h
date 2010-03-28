#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/absg_graph/GMigraph.C */
extern int GMcatch_suc __((struct GRid *l_root, int nb_root, struct GRid *l_tip, int nb_tip, struct GMgraph *p_graph));
extern int GMcatch_down __((struct GRid *l_root, int nb_root, struct GRid *l_tip, int nb_tip, struct GMgraph *p_graph));
extern int GMcatch_up __((struct GRid *l_root, int nb_root, struct GRid *l_tip, int nb_tip, struct GMgraph *p_graph));
extern int GMmodify_state __((struct GRid *l_object, int nb_object, int (*select_fct )(), char *p_info, int state, int flag, struct GMgraph *p_graph));
extern int GMmin_flag __((struct GRid *l_tip, int nb_tip, struct GMgraph *p_graph));
extern int GMroot_flag __((struct GMgraph *p_graph));
extern int GMcompute_level __((struct GMelmt *p_elmt, struct GMgraph *p_graph));
extern int GMget_int_anc __((struct GRid *p_object, struct GMgraph *p_graph, ushort **p_list, int *p_nb_elmt));
extern int GMtrigger __((struct GRid *p_object, struct GMelmt *p_content, int (*broad_fct )(), char *p_broad_arg, struct GMgraph *p_graph, int *l_status, int *p_nb_status));
extern int GMget_suc_gr __((struct GRid *l_root, int nb_root, struct GRid *l_tip, int nb_tip, struct GMgraph *p_graph, struct GMlist *l_anc));
extern int GMordinate __((struct GMgraph *p_graph));
extern int GMget_list __((struct GMgraph *p_graph, int (*select_fctu )(), char *p_sel_argu, struct GRid *p_list[], int *p_nb_elmt));
extern int GMajust_buf __((int new_size, char **pl_buff, int *p_sbuff));

#if defined(__cplusplus)
}
#endif


#undef __
