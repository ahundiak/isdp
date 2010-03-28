#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRpytransuti.c */
extern IGRboolean GRpytransutil __((IGRlong *msg, IGRshort *mx_type, IGRmatrix matrix, IGRlong *num_points, IGRdouble *in_points, unsigned short *properties, IGRdouble *out_points, struct IGRbsp_curve *curve));

#if defined(__cplusplus)
}
#endif


#undef __
