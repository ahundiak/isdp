#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/var/GRaddvar.I */
extern IGRint GRaddvar __((IGRlong *msg, GRIOalias_name *input_alias, OMuword osnum, struct GRIOvar_def *input_variable));

#if defined(__cplusplus)
}
#endif


#undef __
