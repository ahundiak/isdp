#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COspcvtsz.C */
extern int COspcvttoout __((double x_in, double y_in, int size, char *x_out, char *y_out));
extern int COspshosize __((PIplotdata *pd));

#if defined(__cplusplus)
}
#endif


#undef __
