#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRgetbuffer.c */
extern IGRboolean GRgetbuffer __((IGRlong *msg, IGRshort *mx_type, IGRmatrix matrix, IGRlong *num_poles, IGRshort *order, IGRboolean *rational, IGRshort *num_boundaries, GRobjid *objid, IGRchar **ptr));

#if defined(__cplusplus)
}
#endif


#undef __
