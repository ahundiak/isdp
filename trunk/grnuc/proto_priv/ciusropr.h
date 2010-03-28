#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciusropr.c */
extern void UOPsave __((char *name));
extern int UOPfind __((int O, PCItype *T1, PCItype *T2));
extern char *UOPid __((PCIident opid));
extern int mkUOP __((PCItype *T, int O));
extern int UOPbegin __((void));
extern int UOPend __((void));
extern int mkUOParg __((PCIcontext *C, PCIident A));
extern int UOPcmp __((PCIident opid, PCIident code, char *opnam));
extern int UOPisarg __((PCIident A));
extern int UOPcall __((int *res, int o1, int op, int o2));
extern void UOPfree __((void));
extern void UOPdump __((FILE *F));

#if defined(__cplusplus)
}
#endif


#undef __
