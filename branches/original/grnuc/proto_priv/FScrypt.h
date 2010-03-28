#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/FS_src/FScrypt.c */
extern int FSencryptBuff __((Char16 *buff, unsigned int numWords));
extern int FSdecryptBuff __((Char16 *buff, unsigned int numWords));

#if defined(__cplusplus)
}
#endif


#undef __
