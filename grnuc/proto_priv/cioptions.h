#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cioptions.c */
extern int PCIsetopt __((char *s));

#if defined(__cplusplus)
}
#endif


#undef __
