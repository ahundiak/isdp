#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COplotmisc.C */
extern int COcknamln __((char *name));
extern int COcvtsize __((double *x, double *y, char *unit));

#if defined(__cplusplus)
}
#endif


#undef __
