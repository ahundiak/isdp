#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/expression/exp_univ.I */
extern int ACconcatenate_down __((struct GRid parent_in, char *down_in, struct GRid *parent_out, char *down_out));
extern int ACfind_cons_condit __((struct GRid *occ, struct GRid *condit, struct GRid *cons_condit));
extern int ACparent_in_feet __((char *down_in, struct GRid macro_in, struct GRid *parent_out, struct GRid *macro_out, char *down_out));
extern int ACparent_in_template __((struct GRid macro_in, int index, char *downscan, struct GRid *parent_out, struct GRid *macro_out, char *down_out));
extern int ACretrieve_real_parent __((struct GRid parent_in, struct GRid macro_in, char *down_in, struct GRid *parent_out, struct GRid *macro_out, char *down_out));
extern int ACgive_formula __((struct GRid *occurence, char *name, char *formula, int len));
extern int ACgive_recursive_formula __((struct GRid parent_in, struct GRid macro_in, char *formula, int len));

#if defined(__cplusplus)
}
#endif


#undef __
