#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cifstack.C */
extern int STCalloc __((void));
extern int STCpushA __((int var));
extern int STCpushV __((int var, int size, int nbytes));
extern int STCpullA __((int var));
extern int STCpullV __((int var, int size, int nbytes));
extern int STCpop __((int nbytes));
extern int CIpushV __((void *addr, int size, int nbytes));

#if defined(__cplusplus)
}
#endif


#undef __
