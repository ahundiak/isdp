#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRrefmode.I */
extern int GRrefmode __((IGRlong *msg, IGRshort *type, IGRmatrix matrix, GRobjid *ref_id, GRspacenum *ref_osnum, IGRint *reset));

#if defined(__cplusplus)
}
#endif


#undef __
