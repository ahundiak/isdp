#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/so/DEinit.I */
extern int DEget_soo __((OM_S_OBJID *p_objid, GRspacenum *p_osnum, GRspacenum osnum));
extern int _DEinit __((void));

#if defined(__cplusplus)
}
#endif


#undef __
