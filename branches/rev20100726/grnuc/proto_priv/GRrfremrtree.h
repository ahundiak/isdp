#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRrfremrtree.I */
extern IGRlong GRrfremrtree __((IGRlong *msg, struct GRmd_env *env, GRobjid *poly_objid, GRobjid *ref_objid));

#if defined(__cplusplus)
}
#endif


#undef __
