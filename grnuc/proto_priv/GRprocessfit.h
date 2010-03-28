#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRprocessfit.I */
extern int GRprocessfit __((IGRlong *msg, IGRshort *type, IGRmatrix matrix, struct DP_information *sp_info, OM_p_KEY_DESC key, IGRint inf_line, IGRint linear, GRobjid *objid));

#if defined(__cplusplus)
}
#endif


#undef __
