#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/SUNregex/regsub.c */
extern void regsub __((regexp *prog, char *source, char *dest));

#if defined(__cplusplus)
}
#endif


#undef __
