#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/ciexinstr.C */
static void CIrestore_env __((CItraps *sigenv));
static void CIcatch __((int sig));
static void CIsignals __((CItraps *sigenv));
extern int CIexecinfo __((char **file, int *line, CIco_resp **coev, CIruntime **runp));
extern int CIlineno __((void));
extern int CIexecute __((int *msg, char *file, CIprogseq *program, CIco_resp *coevdata, short *state, CIruntime *runenv));

#if defined(__cplusplus)
}
#endif


#undef __
