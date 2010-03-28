#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/COparaloci.I */
extern IGRint cmp_parent __((IGRlong *msg, OMuint *num_parents, struct GRid *list_parents, struct GRid *list_context));
extern AScs_for_dim __((struct GRid window_id, struct GRid *cs_id));

#if defined(__cplusplus)
}
#endif


#undef __
