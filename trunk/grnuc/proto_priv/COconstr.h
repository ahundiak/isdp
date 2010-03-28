#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/COconstr.I */
extern IGRlong COConstructObject __((IGRlong *msg, enum GRdpmode *display_mode, IGRboolean newflag, short unsigned properties, IGRchar *geometry, struct GRmd_env *module, struct IGRdisplay *symbology, IGRshort *level, IGRchar *attr, IGRchar *name, struct GRid *new_objects_grid, struct GRid *display_grid, IGRchar *classname, GRclassid classid, GRobjid objid, GRobjecthdr *object, OM_S_NEIGHBOR neighbor, OM_S_OBJID cob_id, GRspacenum cob_os, OM_S_CHANSELECT *p_co_chanselect, IGRint from_index));

#if defined(__cplusplus)
}
#endif


#undef __
