#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciusrfcn.c */
extern int UFNfind __((PCIident N));
extern int UFNisarg __((PCIident A));
extern int UFNaddarg __((PCIident A));
extern void UFNfree __((void));
extern int UFNtypeq __((PCItype *T, PCItype *Eq));
extern int mkUFNarg __((PCIcontext *C, PCIident A));
extern int UFNdefault __((void));
extern int UFNbegin __((void));
extern int UFNend __((PCIident F));
extern int UFNmkcall __((Ucall **a, PCIlist *call));
extern int UFNaddcall __((Ucheck *fcn, PCIlist *call));
extern int UFNcheck __((PCIlist *call));
extern int UFNcall __((PCIlist *call));
extern int mkUFN __((PCItype type, PCIident name));
extern int UFN_TYIcmp __((PCIident f1, PCIident f2));
extern void UFNprtargs __((FILE *F, int fcn));
extern void UFNdump __((FILE *F));

#if defined(__cplusplus)
}
#endif


#undef __
