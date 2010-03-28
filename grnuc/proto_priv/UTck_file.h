#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/UT_src/UTck_file.c */
extern int UTcheck_file __((Typepath pathname));

#if defined(__cplusplus)
}
#endif


#undef __
