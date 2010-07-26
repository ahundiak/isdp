#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRgetclippol.I */
extern int GRgetclippoly __((IGRlong *msg, IGRshort *mx_type, IGRmatrix matrix, GRobjid *objid, IGRchar **ptr));

#if defined(__cplusplus)
}
#endif


#undef __
