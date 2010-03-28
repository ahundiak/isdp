#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/FS_src/FSfindKern.c */
extern int FSfindKernPair __((cft_kern_pair_rec *knpr_dat, unsigned int num_pairs, unsigned int char_id1, unsigned int char_id2, cft_kern_pair_rec **knpr_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
