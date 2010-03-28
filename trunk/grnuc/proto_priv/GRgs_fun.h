#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/grsetgo/GRgs_fun.I */
extern IGRint GRgspass __((IGRlong *msg, OM_p_MESSAGE pass_msg, struct GRmd_env *path, GRobjid senderid, GRspacenum senderos, OM_p_CHANSELECT p_chanselect, struct GRid *object_id));
extern IGRint GRgsdisplay __((IGRlong *msg, enum GRdpmode dpmode, struct GRid *display_id, GRobjid senderid, GRspacenum senderos, OM_p_CHANSELECT p_chanselect, struct GRid *object_id));
extern IGRint GRgsflatten __((IGRlong *msg, struct GRlc_locate *attributes, OM_S_CLASSLIST *eligible_classes, OM_S_CLASSLIST *owner_classes, IGRint owner_properties, GRobjid senderid, GRspacenum senderos, OM_p_CHANSELECT p_chanselect, struct GRid *object_id));
extern IGRint GRgsremove_fence __((IGRlong *msg, GRobjid senderid, GRspacenum senderos, OM_p_CHANSELECT p_chanselect, struct GRid *object_id));
extern IGRint GRgsinit __((IGRlong *msg, GRobjid senderid, GRspacenum senderos, IGRint flag, OM_p_CHANSELECT p_chanselect, GRobjid *p_objid, GRspacenum osnum));
extern IGRint GRgs_is_graphics_set __((IGRlong *msg, GRobjid senderid, GRspacenum senderos, OM_p_CHANSELECT p_chanselect, struct GRid *object_id));
extern IGRint GRgs_fun __((IGRlong *msg, IGRint type, GRobjid senderid, GRspacenum senderos, OM_p_CHANSELECT p_chanselect, struct GRid *object_id, IGRchar *arg1, IGRchar *arg2, IGRchar *arg3, IGRchar *arg4, IGRchar *arg5));

#if defined(__cplusplus)
}
#endif


#undef __
