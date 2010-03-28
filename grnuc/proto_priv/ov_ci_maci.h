#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro/ov_ci_maci.I */
extern int test_ci1 __((char *entry_point, OM_S_OBJID ci_mac_my_id, GRspacenum ci_mac_my_os, struct GRid *ci_macro_id, char *my_internal_buffer));
extern int run_ci __((char *entry_point, struct GRid ci_macro_id));

#if defined(__cplusplus)
}
#endif


#undef __
