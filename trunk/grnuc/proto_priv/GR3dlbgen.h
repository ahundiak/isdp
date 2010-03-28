#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/symbgo/GR3dlbgen.C */
extern IGRint GR3dlbvigenabsg __((IGRlong *msg, IGRshort *matrix_type, IGRmatrix matrix, IGRint view_independent, IGRdouble rot_matrix[], IGRdouble origin[], IGRdouble diag_pt1[], IGRdouble diag_pt2[], GRobjid objid, GRspacenum osnum, IGRchar **absgptr));
extern IGRint GR3dlbgenabsg __((IGRlong *msg, IGRshort *matrix_type, IGRmatrix matrix, IGRdouble rot_matrix[], IGRdouble origin[], IGRdouble diag_pt1[], IGRdouble diag_pt2[], GRobjid objid, GRspacenum osnum, IGRchar **absgptr));

#if defined(__cplusplus)
}
#endif


#undef __
