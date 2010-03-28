#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/symbco/GRcpsdasl.I */
extern IGRint GRcp_sd_to_asl __((IGRlong *msg, IGRmatrix symbol_matrix, struct GRmd_env *asl_env, struct GRid *sdh, GRobjid objid, GRspacenum osnum, OM_p_CHANSELECT chansel));

#if defined(__cplusplus)
}
#endif


#undef __
