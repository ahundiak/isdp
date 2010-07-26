#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/setup/cisrcls.I */
extern char *CIexmessage __((int code));
extern char *CIls_cnst __((OM_S_OBJID coid, OMuword coos, Form superid));
extern int CIls_upd_selected __((int action, enum LSlabs actdir, int actrow, int actcol, Uname actfil));
extern int CIls_dpdir __((int action, int min, int max));
extern int CIls_init __((void));
extern int CIls_input __((struct FI_X_data_st *p_in, struct GRid *co));
extern int CIls_delete __((int check, Form askerid));
extern int CIls_is_form_on __((void));

#if defined(__cplusplus)
}
#endif


#undef __
