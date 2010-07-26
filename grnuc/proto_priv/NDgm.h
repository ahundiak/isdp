#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/node/NDgm.I */
extern int NDancestor __((struct GRid *p_object, char *p_info, struct GRid **p_lanc, int *p_nb_anc));
extern int NDsuccessor __((struct GRid *p_object, char *p_info, struct GRid **p_lsuc, int *p_nb_suc));
extern int NDacrej __((struct GRid *p_object, int int_attr, short p_info[]));
extern int NDgm_send __((struct GRid *p_object, OM_S_MESSAGE *msg));
extern int NDget_comp_state __((struct GRid l_object[], int nb_object, int l_attr[], struct GMgraph *p_graph));
extern int NDset_comp_state __((struct GRid l_object[], int nb_object, int l_attr[], struct GMgraph *p_graph));
extern int NDcvt_to_graph __((struct GRid l_object[], int l_type[], int nb_object, struct GMgraph *p_graph));

#if defined(__cplusplus)
}
#endif


#undef __
