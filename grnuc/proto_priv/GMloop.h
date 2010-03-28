#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/absg_graph/GMloop.C */
extern int GMget_loop_elmts __((struct GRid *p_object, struct GMgraph *p_graph, struct GRid **pl_object, int *p_count));
extern int GMfind_loop __((struct GRid *p_object, struct GMgraph *p_graph, int *p_response));
extern int GMget_loop_path __((struct GRid *p_object, int (*f_get_anc )(), char *p_arg_anc, struct GMgraph *p_graph));
extern int GMdepth_first __((struct GMgraph *p_graph, struct GRid *p_object));
extern int GMget_anc_loop __((struct GRid *p_object, struct GMgraph *p_graph, struct GRid **pl_object, int *p_count));

#if defined(__cplusplus)
}
#endif


#undef __
