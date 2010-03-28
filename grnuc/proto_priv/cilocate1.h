#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cilocate.I */
extern int CIlocate __((struct ci_instruction *mess, CIco_resp *lcevdata, CIruntime *runparms, short *state));
extern int CIget_module_info __((struct ci_instruction *func));

#if defined(__cplusplus)
}
#endif


#undef __
