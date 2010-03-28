#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LChilight.I */
extern int LChilight __((IGRlong *msg, IGRshort *matrix_type, IGRmatrix matrix, enum GRdpmode *hilight_mode, struct GRid *dis_id, OM_S_OBJID objid, OMuword osnum, IGRint flag));

#if defined(__cplusplus)
}
#endif


#undef __
