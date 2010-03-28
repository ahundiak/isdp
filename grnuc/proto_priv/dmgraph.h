#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/dmgraph.I */
extern IGRint DMget_graph __((struct GRid root, int level, int size, struct GRid list[], int *count));
extern IGRint DMbroadcast_subgraph __((IGRint order, struct GRid root, OM_S_MESSAGE *p_msg));
extern int DMnotify_disconnect __((struct GRid dim));

#if defined(__cplusplus)
}
#endif


#undef __
