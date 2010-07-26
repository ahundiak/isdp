#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/symbco/GRsmplmat.C */
extern IGRint GRsmplmat __((IGRlong *msg, IGRdouble *angle, IGRdouble scale[3 ], IGRpoint origin, IGRmatrix rot_matrix, IGRmatrix symbol_matrix));

#if defined(__cplusplus)
}
#endif


#undef __
