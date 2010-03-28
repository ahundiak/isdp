#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/grsetgo/GRgsgetsimp.I */
extern IGRint GRgsget_simple_object __((IGRlong *msg, struct GRid *owner_id, OM_p_CHANSELECT chansel, struct GRobj_env *obj_env));

#if defined(__cplusplus)
}
#endif


#undef __
