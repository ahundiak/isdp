#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ptngo/GRpagetcv.I */
extern IGRint GRpagetcv __((IGRlong *msg, GRobjid *caller, OM_S_CHANSELECT *to_comp, struct GRmd_env *module, struct IGRbsp_curve **cv));

#if defined(__cplusplus)
}
#endif


#undef __
