#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/ciclone.I */
extern int ci_clonage __((long *msg, OM_S_OBJID ci_orig, OM_S_OBJID *ci_clone, OM_S_OBJID sender_id, OMuword sender_os));

#if defined(__cplusplus)
}
#endif


#undef __
