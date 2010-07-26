#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cimess.C */
extern int CIsend __((struct ci_instruction *instr, CIco_resp *evdata, CIruntime *runenv, short *state));
extern int cimkmess __((struct ci_instruction *mess, CIco_resp *evdata, CIruntime *runenv, long *p_OMsts));

#if defined(__cplusplus)
}
#endif


#undef __
