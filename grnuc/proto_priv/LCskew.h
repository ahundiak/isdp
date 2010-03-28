#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCskew.C */
extern int LC_fill_skew __((SKEW_KEY_3D_DBL *skew, IGRdouble *range, IGRdouble *range2));

#if defined(__cplusplus)
}
#endif


#undef __
