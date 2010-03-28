#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciregister.c */
extern void REGreset __((void));
extern int mkREG __((PCItype *T));

#if defined(__cplusplus)
}
#endif


#undef __
