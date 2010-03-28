#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/citypes.c */
extern unsigned TYPalign __((PCItype *t));
extern unsigned TYPsizeof __((PCItype *t));
extern int TYPcompare __((PCItype t1, PCItype t2));
extern PCItype TYPbasic __((int basic));
extern PCItype *pTYPbasic __((int basic));
extern void TYPeq __((PCItype **t1, PCItype **t2));
extern int TYPareeq __((PCItype *T1, PCItype *T2));
extern int TYPari __((PCItype *t1, PCIop *o, PCItype *t2, PCItype *tr));
static int TYPptrcpt __((PCItype *p1, PCItype *p2));
extern int TYPptr __((PCItype *t1, PCIop *o, PCItype *t2, PCItype *tr));
extern int TYPmisc __((PCItype *t1, PCIop *o, PCItype *t2, PCItype *tr));
extern int TYPmatch __((PCItype *t1, PCIop *o, PCItype *t2, PCItype *tr));
extern int TYPcast __((PCItype *cast, PCItype *t, PCIop *o, int *is_void));
extern int TYPisdim __((int d));
extern int TYPfuncall __((PCItype *formal, PCItype *actual, int fundef));
extern char *BSCname __((int ib));
extern void TYPname __((PCItype *T, char **def, char **nam));
extern void TYPind __((PCItype *arr, PCItype *elt));
extern int TYPscalar __((PCItype *T));
extern int TYPdump __((char *text, PCItype *T));
extern int TYPderived __((Uchar *modifier));
extern int TYPvoid __((PCItype *T));
extern int TYPvoidptr __((PCItype *T));

#if defined(__cplusplus)
}
#endif


#undef __
