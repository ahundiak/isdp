#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRloccheck.I */
extern IGRlong GRloccheck __((IGRlong *msg, IGRshort *mx_type, IGRmatrix matrix, IGRushort *obj_properties, IGRulong *req_properties, IGRshort *obj_level, IGRint *req_levels, GRobjid *objid));
extern int GRcheck_props __((IGRshort *mx_type, IGRmatrix matrix, GRobjid *objid, IGRushort *props, IGRulong *test_props));

#if defined(__cplusplus)
}
#endif


#undef __
