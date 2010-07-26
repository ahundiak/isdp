#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASlinedbti.I */
extern IGRdouble ref_from_centers __((IGRpoint center1, IGRpoint center2, double *ix, double *iy, double *jx, double *jy));
extern int line_bitang __((IGRpoint center1, IGRdouble rad1, IGRpoint center2, IGRdouble rad2, IGRpoint line[], int Which1, int Which2));

#if defined(__cplusplus)
}
#endif


#undef __
