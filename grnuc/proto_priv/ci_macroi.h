#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/ci_macro/ci_macroi.I */
extern int execute_ci1 __((char *entry_point, struct GRmd_env *mdenv, OM_S_OBJID ci_mac_my_id, GRspacenum ci_mac_my_os, IGRshort *matrix_type, IGRmatrix matrix, struct GRid *ci_macro_id, int my_state, char *my_internal_buffer));
extern int build_point __((struct GRid *POINT, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
