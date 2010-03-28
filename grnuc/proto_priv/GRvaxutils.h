#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GRvaxutils.c */
extern void UTConvertShort __((int num_swaps, unsigned short *buffer));
extern void UTConvertLong __((int num_swaps, unsigned long *buffer));
extern void UTConvertDouble __((int num_swaps, double *buffer));

#if defined(__cplusplus)
}
#endif


#undef __
