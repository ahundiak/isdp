#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRfltfrac.C */
extern int GRIO_float_to_frac __((int reduce_flag, double value, int denominator, char *string));
extern int GRIO_gcd __((int n, int d));

#if defined(__cplusplus)
}
#endif


#undef __
