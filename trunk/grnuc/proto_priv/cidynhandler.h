#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cidynhandler.I */
extern int PPLdynamics __((CIdynargs *dynargs, struct EX_button *crsrpos, double *windmat, struct GRid *objects, int *obcount, struct DPele_header *dynbuff, int *bfcount, char *in_dum1, char *in_dum2, char *in_dum3, char **outdum1, char **outdum2, char **outdum3));
extern int CIdpdynamics __((struct ci_instruction *ins, CIco_resp *evdata, CIruntime *runparms, short *state));

#if defined(__cplusplus)
}
#endif


#undef __
