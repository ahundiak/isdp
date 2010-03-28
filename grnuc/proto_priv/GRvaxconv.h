#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GRvaxconv.c */
extern int GRFltVaxToFlt32 __((int no_floats, unsigned long vax_float[], double *ieee_float));
extern int GRFlt32ToFltVax __((int no_floats, double *ieee_float, unsigned long vax_float[]));
extern int GRFVaxTo32 __((int no_floats, unsigned long vax_float[], float *ieee_float));
extern int GRF32ToFVax __((int no_floats, float *ieee_float, unsigned long vax_float[]));
extern int flt32_to_fltvax __((int no_floats, double *ieee_float, unsigned long vax_float[]));
extern int fltvax_to_flt32 __((int no_floats, unsigned long vax_float[], double *ieee_float));
extern double UTAdjustDouble __((double ieee_val));
extern int UTFlt32ToFltVax __((int no_floats, double *ieee_float, unsigned long vax_float[]));
extern int UTFltVaxToFlt32 __((int no_floats, unsigned long vax_float[], double *ieee_float));
extern int UTFVaxTo32 __((int no_floats, unsigned long vax_float[], float *ieee_float));
extern int UTF32ToFVax __((int no_floats, float *ieee_float, unsigned long vax_float[]));

#if defined(__cplusplus)
}
#endif


#undef __
