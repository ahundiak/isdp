#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciop.c */
extern int OPusr __((int e, int a1, int o, int a2));
extern int cicast __((int *e, PCItype *cast, int a));
extern int OPbin __((int e, int a1, int o, int a2));
extern int OPunr __((int e, int o, int a));
extern int OPadd __((int e, int a1, int o, int a2));
extern int OPmul __((int e, int a1, int o, int a2));
extern int OPmod __((int e, int a1, int o, int a2));
extern int OPrel __((int e, int a1, int o, int a2));
extern int OPuminus __((int e, int o, int a));
extern int OPlogneg __((int e, int o, int a));
extern int OPbitneg __((int e, int o, int a));
extern int OPlog __((int e, int a1, int o, int a2));
extern int OPbit __((int e, int a1, int o, int a2));
extern int OPshf __((int e, int a1, int o, int a2));
extern int OPadr __((int e, int o, int a));
extern int OPind __((int e, int o, int a));
extern int AOPbrk __((int E, int A, int o, int I));
extern int OPasg __((int e, int l, int o, int r));

#if defined(__cplusplus)
}
#endif


#undef __
