#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VLforkMacro.I */
IGRint VLcreateLoftJunction __((IGRlong *msg, struct GRobj_env *graphic, struct GRobj_env *collect, struct ACrg_coll *attr, IGRint number, struct GRobj_env *measure, struct GRmd_env *Env, struct GRid *occ_id));
IGRint VLgetLoftJunctionGeom __((IGRlong *msg, struct GRid *objId, struct GRmd_env *objEnv, struct GRid *footId, struct GRmd_env *footEnv, IGRint option, OM_S_OBJID MyStupidId, IGRchar **Geometry));
IGRint VLgetLoftJunctionAttr __((IGRlong *msg, struct GRid *objId, IGRchar *name, IGRdouble *value, IGRchar *text));

#if defined(__cplusplus)
}
#endif

