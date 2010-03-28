#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/flib/create.c */
extern bool create_flib __((char *flib_name));

#if defined(__cplusplus)
}
#endif


#undef __
