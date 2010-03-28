#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/setup/cifiutil.I */
extern int CIfm_put __((Form form, struct FI_X_data_st *gad));
extern int CIfm_get __((Form form, struct FI_X_data_st *gad));
extern void CIfm_erase __((Form form, int reset, int endf));
extern void CIfm_delete __((Form fid));
static void CIfm_form_notification __((int f_label, int g_label, double value, Form form));
extern int CIfm_init __((char *file, int lab, OM_S_OBJID coid, OMuword coos, int cons, Form *form_p));
extern int CIfm_display __((Form form, int flag));
extern int CIfm_help __((struct GRid *co, char *topic));
extern int CIexpand __((char *path, char *expanded, int size));

#if defined(__cplusplus)
}
#endif


#undef __
