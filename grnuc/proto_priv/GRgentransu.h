#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRgentransu.c */
extern IGRboolean GRgentransutil __((IGRlong *msg, IGRshort *mx_type, IGRmatrix matrix, IGRlong *num_points, IGRdouble *in_points, IGRdouble *out_points, IGRshort *flag));

#if defined(__cplusplus)
}
#endif


#undef __
