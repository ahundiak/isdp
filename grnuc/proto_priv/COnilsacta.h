#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/ln/COnilsacta.C */
extern IGRlong CO_ni_place_line_at_active_angle __((IGRlong *ReturnMsg, struct GRevent *Events[], enum GRdpmode *DisplayMode, IGRboolean newflag, struct GRmd_env *ModuleInfo, struct IGRdisplay *ActiveDisplay, IGRshort *ActiveLevel, IGRchar *attr, IGRchar *name, struct GRid *LineSegmentGrid, struct GRid *DisplayGrid, IGRchar *classname, GRclassid classid, OM_S_NEIGHBOR neighbor, OM_S_OBJID cob_id, GRspacenum cob_os, OM_S_CHANSELECT *p_co_chanselect, IGRint co_index));

#if defined(__cplusplus)
}
#endif


#undef __