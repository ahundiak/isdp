#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/ciexec.I */
extern int CIexec __((struct ci_instruction *func, CIco_resp *exevdata, CIruntime *runparms, short *state));
extern int ci_exec __((char *file_name, OM_S_OBJID *p_file_id, char *entry, int load, int verif, int init, int run, int delete, OM_S_OBJID sender_id, OMuword sender_os, void *retval, int retsize, int *retcode));
extern int ciSCIdelete __((struct ci_instruction *func));
extern int ciSCIinq_files __((struct ci_instruction *func));
extern int ciSCIinq_objects __((struct ci_instruction *func));

#if defined(__cplusplus)
}
#endif


#undef __
