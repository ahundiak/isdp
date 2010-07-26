#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/setup/cisetup.I */
extern int CIsu_get_path __((char *rel, UNIXpath abs));
extern char *CIsu_read __((void));
extern char *CIiniopt __((void));
extern void CIputopt __((options *O));
extern char *CIgetopt __((options *O));
static char incbuf [MAXINCDIRS * __((int CIsplit_path (search, paths, size )char search[CIPATHLEN +1 ]));
extern void CIsu_putenv __((char *var, int index));
extern char *CIsu_write __((void));
extern int CIsu_get __((struct FI_X_data_st *gad));
extern int CIsu_clear __((void));
extern int CIsu_msg __((char *text));
extern int CIinfo_CCI_PATH __((void));
extern int CIinfo_EXT_PATH __((void));
extern void CIsu_put_cipath __((void));
extern int CIsu_get_includes __((int max_index));
extern void CIsu_get_cipath __((int max_index));
extern void CIsu_defaults __((void));
extern int CIsu_set_on_off __((int lb, int flag));
extern int CIsu_init __((void));
extern int CIsu_upd_current __((void));
extern int CIsu_wakeup __((OM_S_OBJID coid, OMuword coos, int req, Form *fid));
extern void CIsu_sysdef __((void));
extern char *CIsu_save __((int wrtflg));
extern int CIsu_delete __((Form fid));
extern int CIsu_sleep __((Form fid));
extern char *CIsu_chk_file __((path file, int mode));
extern int CIsu_ls_deleted __((void));

#if defined(__cplusplus)
}
#endif


#undef __
