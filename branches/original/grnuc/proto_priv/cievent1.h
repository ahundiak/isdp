#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cievent.C */
extern int CIgetevent __((struct ci_instruction *func, CIco_resp *getevdata, CIruntime *runparms, short *state));
extern int CIputevent __((struct ci_instruction *func, CIco_resp *putevdata, CIruntime *runparms, short *state));
extern int __ci_build_button __((struct EX_button *pbutton, char *wind_name));
extern int ci_build_button __((long *rc, struct EX_button *pbutton, char *wind_name));
extern int cidocmd __((int type, struct ci_instruction *func, CIco_resp *cmdevdata, CIruntime *runparms, short *state));
extern int ci_can_be_stacked __((struct instance_ci *xdata, char *xdata_info));
extern int CIquiet __((struct ci_instruction *func, CIco_resp *evdata, CIruntime *runparms, short *state));

#if defined(__cplusplus)
}
#endif


#undef __
