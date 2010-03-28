#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cilabel.c */
static int LABenter __((PCIident lab, int typ, int fcn, int il));
static int LABfind __((PCIident lab, int typ, int fcn));
static int LABalloc __((label **L, unsigned l));
extern void LABfree __((void));
extern int mkLAB __((char *lab, int typ, int pos));
extern int LABresolve __((void));
extern int LABcheck __((void));
extern char *LABname __((PCIident name));

#if defined(__cplusplus)
}
#endif


#undef __
