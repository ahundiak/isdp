#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRscanrange.c */
extern IGRboolean GRscanrange __((IGRlong *msg, IGRdouble *pt1, IGRdouble *pt2, struct GRmdenv_info *md_env, IGRdouble *vw_volume, IGRmatrix master_to_ref_matrix, IGRmatrix clip_matrix, IGRdouble *tolerance, GRrange range));

#if defined(__cplusplus)
}
#endif


#undef __
