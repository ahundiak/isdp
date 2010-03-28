#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cienum.c */
extern int ENMfind __((PCIident tag, PCItype *type));
extern void ENMfree __((void));
extern int ENMfindV __((PCIident name, int *value));
extern int mkENM __((PCIident tag));
extern int mkENMval __((PCIident name, int *value));
extern PCItype ENMend __((void));
extern void ENMdump __((FILE *F));
extern char *ENMname __((int ie));

#if defined(__cplusplus)
}
#endif


#undef __
