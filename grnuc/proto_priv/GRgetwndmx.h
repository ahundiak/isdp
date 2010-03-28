#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRgetwndmx.C */
extern IGRint GRget_window_matrix __((IGRlong *msg, GRspacenum window_osnum, GRobjid window_objid, IGRmatrix matrix, IGRint *ortho_view));

#if defined(__cplusplus)
}
#endif


#undef __
