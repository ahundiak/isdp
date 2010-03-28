#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cii.I */
extern int CIconstruct __((long *msg, char *cfname, int mode, OM_S_OBJID *cfid, OM_S_OBJID sender_id, OMuword sender_os));
extern short CIread_options __((char *tag));
extern int CIgetinstrno __((int type, struct instance_ci *xdata, char *fname));
extern int cireveil __((CIruntime *runenv));

#if defined(__cplusplus)
}
#endif


#undef __
