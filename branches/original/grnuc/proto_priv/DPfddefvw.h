#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPfddefvw.I */
extern int DPfind_defaultvw __((IGRlong *msg, IGRlong flag, GRspacenum osnum, GRobjid *objid));

#if defined(__cplusplus)
}
#endif


#undef __
