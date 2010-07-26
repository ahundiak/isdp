#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/go1/GRbcclip.I */
extern IGRint GRconstconnect __((IGRlong *msg, struct GRmd_env *target_env, struct GRvg_construct *const_lis, IGRchar *classname, IGRlong *num, struct GRid *in_id, struct GRid *out_id, struct GRid *ovl_id, IGRlong *clip_flags, IGRlong *indicator, IGRlong clip_control, struct GRid *clp_id, OM_p_MESSAGE conn_msg, IGRint *tot_in, IGRint *tot_out, IGRint *tot_ovl));

#if defined(__cplusplus)
}
#endif


#undef __
