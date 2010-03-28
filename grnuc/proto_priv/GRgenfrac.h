#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRgenfrac.C */
extern IGRboolean GRgen_fraction __((IGRlong *msg, IGRuchar *string, IGRuchar *fraction, IGRshort *num_chars));

#if defined(__cplusplus)
}
#endif


#undef __
