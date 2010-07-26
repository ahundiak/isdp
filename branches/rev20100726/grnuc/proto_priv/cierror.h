#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/setup/cierror.I */
extern OMuword CIosnum __((void));
extern int CIfm_wait_for_end __((Form form));
extern int CIerror_form_process __((int form, struct FI_X_data_st *button));
extern long CIerror __((int *action, CIco_resp *evdata, CIruntime *runinfo, char *file, int line, int severity, char *errtype, char *l1, char *l2, char *l3, char *l4, char *l5));

#if defined(__cplusplus)
}
#endif


#undef __
