#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/var/GRdelvar.I */
extern IGRint GRdelvar __((IGRlong *msg, OMuword osnum, GRIOalias_name *num_alias, struct GRIOvar_def *alias_list));

#if defined(__cplusplus)
}
#endif


#undef __
