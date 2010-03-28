#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRrfaddrtree.I */
extern IGRlong GRrfaddrtree __((IGRlong *msg, struct GRmd_env *env, GRobjid *poly_objid, GRobjid *ref_objid, IGRdouble *rtree_range));

#if defined(__cplusplus)
}
#endif


#undef __
