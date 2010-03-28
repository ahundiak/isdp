#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cioprins.c */
extern void INSinit __((void));
extern int INSloadR __((unsigned size, unsigned sign));
extern int INSloadV __((Ushort var));
extern int INSladrV __((Ushort var));
extern int INSladrR __((void));
extern int INScadd __((unsigned const));
extern int INScopyVR __((Ushort to));
extern int INScopyrA __((int to, unsigned size));
extern int INScopyrR __((unsigned size));
extern int INScopyrr __((unsigned size));
extern int INSbop __((char *op));
extern int INSuop __((char *op));

#if defined(__cplusplus)
}
#endif


#undef __
