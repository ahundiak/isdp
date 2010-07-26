#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciconstant.c */
extern int CSTfind __((int type, PCIpointer data));
extern int CSTenter __((int type, PCIpointer data, int indx));
extern void CSTfree __((void));
extern void CSTdump __((FILE *dump));
extern int mkCST __((PCItype *type, PCIpointer value));
extern int mkCSTint __((int u));

#if defined(__cplusplus)
}
#endif


#undef __
