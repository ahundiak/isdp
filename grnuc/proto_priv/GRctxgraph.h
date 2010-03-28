#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ref/GRctxgraph.I */
extern int GRget_ref_children __((struct GRid *root, char *dummy, struct GRid **children, int *nb_children));
extern int GRget_nested_files_1 __((void));
extern int GRget_sorted_nested_files __((long *msg, int *p_count, OMuword **p_osnums, OMuword osnum));

#if defined(__cplusplus)
}
#endif


#undef __
