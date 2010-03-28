#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciprepro.c */
extern int CPPopt __((char *opt, char *arg));
extern char *CPPcmd __((SysVfname *pp, SysVfname *name));
extern int CPPrun __((SysVfname fcmd, FILE **input));
extern void CPPfree __((void));

#if defined(__cplusplus)
}
#endif


#undef __
