#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/flib/sunconv.c */
extern int Xconv_short __((short *s));
extern int Xconv_int __((int *i));
extern int Xconv_double __((double *d));

#if defined(__cplusplus)
}
#endif


#undef __
