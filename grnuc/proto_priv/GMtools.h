#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/absg_graph/GMtools.C */
extern int GMsel_and __((struct GRid *p_object, int int_attr, short *p_info));
extern int GMsel_nand __((struct GRid *p_object, int int_attr, short *p_info));
extern int GMgridcmp __((struct GRid *p_ext_key, struct GRid *p_int_key, char *p_user_info));
extern int GMmemcmp __((int *p_ext_key, int *p_int_key, char *p_user_info));
extern int GMh_grid __((struct GRid *p_key));
extern int GMreq_equal __((struct GMmodif *p_request_1, struct GMmodif *p_request_2, char *p_user_info));
extern int GMorient __((struct GRid *p_object, struct GMgraph *p_graph, struct GRid *l_succ, int *p_nb_succ));
extern int GMget_anc_ingr __((struct GRid *p_object, struct GMgraph *p_graph, struct GRid **pl_object, int *p_count));
extern int GMreplace_grid __((struct GRid *p_object, struct GRid *p_nobject, struct GMgraph *p_graph));
extern int GMcompress_list __((struct GRid *l_object, int *p_nbobj));

#if defined(__cplusplus)
}
#endif


#undef __
