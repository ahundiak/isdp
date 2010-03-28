#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/lcobjgo/LCcmd_isofun.I */
extern int LCconnect __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect, IGRint index, OM_S_OBJID go_objid, GRspacenum go_osnum, IGRint go_index));
extern int LCwild_disconnect __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect));
extern int LCrange_disconnect __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect, IGRint low_index, IGRint high_index));
extern int LCdisconnect __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect, OM_S_OBJID go_objid, GRspacenum go_osnum));
extern int LCdelete __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect));
extern int LCget_channel_count __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect, IGRint *count));
extern int LCget_channel_objects __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect, OM_S_OBJECT_LINKAGE list[], IGRint size, IGRint *count));
extern int LCis_objid_on_channel __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect, OM_S_OBJID go_objid, GRspacenum go_osnum));
extern IGRint LCget_objid_at_index __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect, IGRint index, OM_S_OBJID *go_objid, GRspacenum *go_osnum));
extern IGRint LCget_index __((GRspacenum osnum, OM_S_OBJID objid, OM_p_CHANSELECT p_chanselect, OM_S_OBJID go_objid, GRspacenum go_osnum, IGRint *index));
extern IGRint LCget_buffer __((GRobjid objid, GRspacenum osnum, OM_p_CHANSELECT p_chanselect, OM_S_OBJECT_LINKAGE **buffer, IGRint *cmd_count, IGRboolean *malloced));

#if defined(__cplusplus)
}
#endif


#undef __
