#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ptngo/GRepbldbox.C */
extern int GRbuildbox __((long *msg, int left, double xrange, double yrange, double *box));

#if defined(__cplusplus)
}
#endif


#undef __
