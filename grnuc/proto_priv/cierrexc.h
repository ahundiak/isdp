#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/setup/cierrexc.C */
extern int CIerrexc __((CIco_resp *coev, CIruntime *runp, char *file, int sig, struct ci_instruction *instr));

#if defined(__cplusplus)
}
#endif


#undef __
