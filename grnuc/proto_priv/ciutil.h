#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciutil.c */
extern int CVTtoint __((int val));
extern int CVTtodbl __((int val));
extern int IDfind __((PCIident id));
extern void civersion __((void));
extern char *itoa __((char *string, int integer));
extern void MKname __((int type, PCIident name, PCIpointer data1, PCIpointer data2, PCIpointer data3));
extern void GRobjinit __((int v));
extern int mkLST __((PCIlist **list, int elt));
extern PCIlist *LSTcat __((PCIlist *l1, PCIlist *l2));
extern void CTXdefault __((PCItype *T, PCIcontext *C));

#if defined(__cplusplus)
}
#endif


#undef __
