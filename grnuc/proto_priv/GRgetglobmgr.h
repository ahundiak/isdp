#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRgetglobmgr.I */
extern IGRint GRget_global_mgr_id __((IGRlong *msg, IGRchar *name, GRspacenum osnum, GRobjid *global_mgr));

#if defined(__cplusplus)
}
#endif


#undef __
