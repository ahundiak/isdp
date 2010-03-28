#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/citypedef.c */
static int TDFenter __((PCIident tag, int it));
extern int TDFfind __((PCIident tag, PCItype *type));
static int TDFalloc __((deftype **t, unsigned l));
extern void TDFfree __((void));
extern PCItype *TDFeq __((int it));
extern unsigned TDFalign __((int it));
extern unsigned TDFsizeof __((int it));
extern char *TDFname __((int it));
extern int TDFmultidim __((int it));
extern int mkTDF __((PCItype *T, PCIident N));
extern void TDFdump __((FILE *f));

#if defined(__cplusplus)
}
#endif


#undef __
