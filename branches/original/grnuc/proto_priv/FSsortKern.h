#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/FS_src/FSsortKern.c */
extern void FSsortKernTbl __((cft_kern_pair_rec *knpr_dat, unsigned int num_pairs));
extern void FSquicksort_pairs __((cft_kern_pair_rec *beg_pair, cft_kern_pair_rec *end_pair, int index));

#if defined(__cplusplus)
}
#endif


#undef __
