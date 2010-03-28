#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/grsetgo/GRgsaddobj.I */
extern IGRint GRgsadd_object __((IGRlong *msg, struct GRid *obj_id, struct GRmd_env *path, IGRint *env_properties, struct GRid *target_id, OM_p_CHANSELECT target_sel));

#if defined(__cplusplus)
}
#endif


#undef __
