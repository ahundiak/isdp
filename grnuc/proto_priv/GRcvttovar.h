#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/var/GRcvttovar.I */
extern IGRint GRcvt_to_var __((IGRlong *msg, GRIOalias_name *input_alias, OMuword osnum, struct GRIOvar_def *var));

#if defined(__cplusplus)
}
#endif


#undef __
