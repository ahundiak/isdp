#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/setup/ciomerr.C */
extern int CIomerr __((CIco_resp *coev, CIruntime *run, char *file, int line, long OMcode, char *class, char *mess, OM_S_OBJID objid, char *channame, OMuword osnum, char *osname));
static char *OMerrtext __((long code, char *severity));

#if defined(__cplusplus)
}
#endif


#undef __
