#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COchcmd.C */
extern int COchcmd __((int from, int to, PIplotdata *pd, PIcreate *cd));

#if defined(__cplusplus)
}
#endif


#undef __
