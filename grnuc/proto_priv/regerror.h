#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/SUNregex/regerror.c */
extern void regerror __((char *s));

#if defined(__cplusplus)
}
#endif


#undef __
