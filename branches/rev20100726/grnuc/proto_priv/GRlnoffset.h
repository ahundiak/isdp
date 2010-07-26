#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRlnoffset.C */
extern IGRlong GRlnoffset __((IGRlong *msg, IGRchar *offset_env, struct IGRpolyline *py, IGRdouble *projection_matrix, IGRdouble *distance, struct IGRline *distance_boreline, struct IGRline *direction_boreline, IGRchar *classname, IGRchar *inf_end, IGRboolean *apparent_flag, IGRshort *properties, GRobjid *objid, GRobjid *new_objid));

#if defined(__cplusplus)
}
#endif


#undef __
