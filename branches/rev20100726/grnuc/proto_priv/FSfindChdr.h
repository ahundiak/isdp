#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/FS_src/FSfindChdr.c */
extern int FSfindChardir __((cft_chardir_rec *chdir_dat, cft_chardir_rec *end_chdir, cft_chardir_rec **chdir_ptr, unsigned int bits_char, short *char_name));

#if defined(__cplusplus)
}
#endif


#undef __
