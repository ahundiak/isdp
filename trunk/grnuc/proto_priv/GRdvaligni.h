#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/detailgo/GRdvaligni.I */
static IGRint GRis_translation __((IGRmatrix matrix));
extern IGRint GRget_dv_ids __((GRspacenum osnum, GRobjid objid, struct GRid *da_id1, struct GRid *da_id2, struct GRid *dv_id1, struct GRid *dv_id2));

#if defined(__cplusplus)
}
#endif


#undef __
