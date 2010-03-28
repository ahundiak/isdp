#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/macro/ACpretendini.I */
extern int AStrans_rst __((struct ret_struct *rst, double *matrix));

#if defined(__cplusplus)
}
#endif


#undef __
