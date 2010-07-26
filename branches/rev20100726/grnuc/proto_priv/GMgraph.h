#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/absg_graph/GMgraph.C */
extern int GMinit_graph __((int modulo, int nb_elmt, int step_size, struct GMgraph *p_graph));
extern int GMremove_graph __((struct GMgraph *p_graph));
extern int GMclear_graph __((struct GMgraph *p_graph));
extern int GMget_graph __((struct GRid *l_root, int nb_root, struct GRid *l_tip, int nb_tip, int (*f_get_anc )(), char *p_arg_anc, int (*f_get_suc )(), char *p_arg_suc, int sort, struct GMgraph *p_graph));
extern int GMinternal_graph __((struct GRid *l_obj, int nb_obj, int (*f_get_anc )(), char *p_arg_anc, int (*f_get_suc )(), char *p_arg_suc, struct GMgraph *p_graph));
extern int GMbroadcast_graph __((int (*sel_fct )(), char *p_sel_arg, int (*broad_fct )(), char *p_broad_arg, int broad_mode, struct GMgraph *p_graph, struct GMsyst *p_grsyst, int *l_status));
extern int GMduplicate_graph __((struct GMgraph *p_graph, struct GMgraph *p_dup_graph));
extern int GMdep_exist __((struct GRid *l_root, int nb_root, struct GRid *l_tip, int nb_tip, int (*f_get_anc )(), char *p_arg_anc));
extern int GMget_type __((struct GRid *l_object, int nb_object, struct GMgraph *p_graph, int *l_attr));
extern int GMlist_access_init __((struct GMgraph *p_graph, int *p_desc));
extern int GMaccess_element __((struct GMgraph *p_graph, int (*select_fctu )(), char *p_sel_argu, int *p_desc, int forward, struct GRid *p_object));

#if defined(__cplusplus)
}
#endif


#undef __
