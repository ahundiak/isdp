#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COsizeplot.c */
extern int COsizeplot __((PIplotdata *pd));

#if defined(__cplusplus)
}
#endif


#undef __
