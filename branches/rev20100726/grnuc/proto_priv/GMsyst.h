#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/absg_graph/GMsyst.C */
extern int GMsyst_activate __((struct GMsyst *p_grsyst));
extern int GMsyst_clear __((struct GMsyst *p_grsyst));
extern int GMsyst_remove __((struct GMsyst *p_grsyst));
extern int GMattach_to_grsyst __((struct GMgraph *p_graph, struct GMsyst *p_grsyst));
extern int GMdetach_fr_grsyst __((struct GMgraph *p_graph));
extern int GMgraph_request __((int type, struct GRid *p_object, struct GMsyst *p_grsyst));
extern int GMredo_broadcast __((struct GMgraph *p_graph));
extern int GManalyse_request __((struct GMgraph *p_graph, struct GMlist *l_greq, char *p_type));
extern int GMredo_graph __((struct GMlist *l_greq, struct GMgraph *p_graph));
extern int GMupdate_lists __((struct GMgraph *p_graph, struct GMlist *l_greq, struct GRid **pl_root, int *p_nb_root, struct GRid **pl_tip, struct GRid *p_nb_tip));
extern int GMgraph_modified __((struct GMgraph *p_graph));
extern int GMstop_broadcast __((struct GMsyst *p_grsyst));
extern int GMget_cur_graph __((struct GMsyst *p_grsyst, struct GMgraph **pp_graph));
extern int GMsel_connect __((struct GRid *p_object, int int_attr, struct GMsel_list *p_info));
extern int GMsel_nbroad __((struct GRid *p_object, int int_attr, struct GMbr_info *p_info));

#if defined(__cplusplus)
}
#endif


#undef __
