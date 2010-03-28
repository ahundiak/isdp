#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciswitch.c */
extern int SWbegin __((int *exp, PCIident tst, PCIident end));
extern int SWcase __((int val));
extern int SWdefc __((void));
static int SWval __((Ushort lab));
static int SWcmp __((SWlabel *l1, SWlabel *l2));
extern int SWend __((int exp, int pre, PCIident tst, PCIident end));
extern void SWfree __((void));

#if defined(__cplusplus)
}
#endif


#undef __
