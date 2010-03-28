#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpdisplay.I */
extern IGRint DPdisbybuf __((IGRlong *msg, GRspacenum osnum, GRobjid objid, enum GRdpmode mode, IGRlong num_elem, struct DPele_header *buffer, IGRint view_ind, IGRint view_ind_type, IGRdouble *view_ind_point));
extern IGRint DPdisbyoid __((IGRlong *msg, GRspacenum osnum, GRobjid objid, enum GRdpmode mode, IGRlong num_elem, struct GRid *oids, IGRshort *mtx_type, IGRmatrix *matrix[], struct IGRaltdisplay *alt_symb, IGRboolean mtx_flag));

#if defined(__cplusplus)
}
#endif


#undef __
