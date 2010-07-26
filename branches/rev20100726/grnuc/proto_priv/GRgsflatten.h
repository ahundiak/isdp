#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/grsetgo/GRgsflatten.I */
extern IGRint GRflatten_owners __((IGRlong *msg, struct GRlc_locate *attributes, OM_S_CLASSLIST *eligible_classes, OM_S_CLASSLIST *owner_classes, IGRint owner_properties, struct GRobj_env *obj_env, struct GRid *gs_id, OM_p_CHANSELECT gs_chansel, struct GRid *sv_id, IGRint *env_properties));

#if defined(__cplusplus)
}
#endif


#undef __
