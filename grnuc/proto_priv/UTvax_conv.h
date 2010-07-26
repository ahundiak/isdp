#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/UT_src/UTvax_conv.c */
extern int UTflt32_to_fltvax __((int no_floats, double *ieee_float, unsigned int vax_float[]));
extern int UTfltvax_to_flt32 __((int no_floats, unsigned int vax_float[], double *ieee_float));
extern int UTconv_int __((unsigned int *temp));

#if defined(__cplusplus)
}
#endif


#undef __
