#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/stubs/EMunwindstub.c */
extern int EMunwind_stupid_sets __((void));

#if defined(__cplusplus)
}
#endif


#undef __
