#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cibasictype.c */
extern int BSCreduce __((PCItype *t1, PCItype *t2, PCItype *t3, PCItype *reduced));
extern unsigned BSCsizeof __((int ib));
extern unsigned BSCalign __((int ib));

#if defined(__cplusplus)
}
#endif


#undef __
