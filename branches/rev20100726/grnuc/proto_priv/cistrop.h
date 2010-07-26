#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cistrop.c */
extern void FAOreset __((void));
extern int FAOflush __((int *e));
extern int FAOdot __((int *exp, int Struct, PCIop *o, PCIident Field));
extern int FAOarw __((int *exp, int Struct, PCIop *o, PCIident Field));

#if defined(__cplusplus)
}
#endif


#undef __
