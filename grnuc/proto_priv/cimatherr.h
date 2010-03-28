#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/setup/cimatherr.C */
extern int matherr __((struct exception *x));

#if defined(__cplusplus)
}
#endif


#undef __
