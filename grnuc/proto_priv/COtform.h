#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/manipco/COtform.I */
extern IGRint COtform __((IGRlong *msg, struct GRmd_env *module, IGRdouble *t_matrix, GRobjid caller_id, OMuword caller_os, OM_S_CHANSELECT *chansel));

#if defined(__cplusplus)
}
#endif


#undef __
