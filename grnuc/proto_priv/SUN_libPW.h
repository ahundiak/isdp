#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/SUN_libPW.c */
#ifdef RUN_X
extern char *regex __((regexp *expr, char *match));
extern char *regcmp __((char *pat));
#endif

#if defined(__cplusplus)
}
#endif


#undef __
