#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cifunc.C */
extern int cifcall __((struct ci_instruction *instr, CIco_resp *evdata,
CIruntime *runenv, short *state));
extern int cidump __((struct ci_instruction *func));
extern int ciprompt __((struct ci_instruction *func, CIco_resp *evinfo, CIruntime *runparms, short *state));
extern int cimessage __((struct ci_instruction *func, CIco_resp *evinfo, CIruntime *runparms, short *state));
extern int cistatus __((struct ci_instruction *func));
extern int cish __((struct ci_instruction *func));
extern int cimath __((struct ci_instruction *func));
extern int cimath2 __((struct ci_instruction *func));
extern int ciatoi __((struct ci_instruction *func));
extern int ciatof __((struct ci_instruction *func));
extern int cintoa __((struct ci_instruction *func));
extern int cimsonoff __((struct ci_instruction *func));
extern int cimemcpy __((struct ci_instruction *func));
extern int cistrcmp __((struct ci_instruction *func));
extern int cistrlen __((struct ci_instruction *func));
extern int cistrcpy __((struct ci_instruction *func));
extern int cistrcat __((struct ci_instruction *func));
extern int cimy_id __((struct ci_instruction *func, CIco_resp *codata, CIruntime *runparms, short *state));
extern int cimy_os __((struct ci_instruction *func));
extern int cisender_id __((struct ci_instruction *func));
extern int cici_clonage __((struct ci_instruction *func, CIco_resp *codata, CIruntime *runparms, short *state));

#if defined(__cplusplus)
}
#endif


#undef __
