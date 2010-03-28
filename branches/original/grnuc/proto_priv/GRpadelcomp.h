#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ptngo/GRpadelcomp.I */
extern IGRint GRpadelcomp __((IGRlong *msg, struct GRid *caller, OM_S_CHANSELECT *chan, struct GRmd_env *mod));

#if defined(__cplusplus)
}
#endif


#undef __
