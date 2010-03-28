#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/FS_src/FSsortChdr.c */
extern void FSsortCharDirs __((cft_chardir_rec *beg_chdir, unsigned int num_chars));

#if defined(__cplusplus)
}
#endif


#undef __
