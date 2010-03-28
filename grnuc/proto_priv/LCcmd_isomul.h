#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/lcobjgo/LCcmd_isomul.I */
extern int LCmultiple_connect __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect, IGRint index, OM_S_OBJID go_objid, GRspacenum go_osnum, IGRint go_index, IGRint preset));

#if defined(__cplusplus)
}
#endif


#undef __
