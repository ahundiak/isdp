#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRxformboth.I */
extern IGRlong GRxformboth __((IGRlong *msg, struct GRmd_env *obj_env, struct GRmd_env *new_env, GRobjid *reffile_id, GRobjid *clippoly_id));

#if defined(__cplusplus)
}
#endif


#undef __
