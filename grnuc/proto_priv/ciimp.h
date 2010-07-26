#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciimp.c */
extern int REXvalid __((char *rex));
extern int REXcompile __((PCIstring in, char *compiled));
extern int REXmatch __((char *pattern, char *match));
extern int mkIMP __((PCIstring imprex, PCItype *type));
extern void IMPfree __((void));
extern int IMPfind __((char *match, PCItype *type));

#if defined(__cplusplus)
}
#endif


#undef __
