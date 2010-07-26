#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ptngo/GRpagetsdh.I */
extern IGRint GRpagetsdh __((IGRlong *msg, GRobjid *caller, OM_S_CHANSELECT *to_sdh, struct GRmd_env *module, struct GRid *sdh, IGRdouble *sdh_range, IGRchar *classname));

#if defined(__cplusplus)
}
#endif


#undef __
