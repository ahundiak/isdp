#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro/ACrep_sup.I */
extern int ACcompute_rep_value __((int rep_in, struct GRid *root, int count, int *rep_out));
extern int ACgenerate_rep __((int rep, GRspacenum osnum, struct GRid *temp_rep));
extern int ACget_def_NVrep __((unsigned char *prep, struct GRsymbology *esymb));
extern int ACget_possible_rep_col __((struct GRid *coll));
extern int ACcreate_possible_rep_col __((struct GRid *coll));
extern int ACadd_representation __((char *name, int value));

#if defined(__cplusplus)
}
#endif


#undef __
