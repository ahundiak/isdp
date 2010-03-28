#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRverifyview.C */
extern int GRverifyview __((IGRlong *msg, IGRchar *saved_view, GRspacenum *osnum, GRobjid *objid, IGRdouble *vw_origin, IGRmatrix vw_rotation, IGRdouble *vw_volume, IGRboolean *same, IGRdouble *new_origin, IGRmatrix new_rotation, IGRdouble *new_volume));

#if defined(__cplusplus)
}
#endif


#undef __
