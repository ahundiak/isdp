#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUitxtjust.C */
extern IGRint GUitxtjust __((IGRlong *msg, IGRshort *justification, IGRdouble origin[3 ], struct extents *txt_extents, IGRmatrix rot_matrix, IGRdouble *scale_factor));

#if defined(__cplusplus)
}
#endif


#undef __
