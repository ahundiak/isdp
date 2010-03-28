#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cr/COnicrdiam.C */
extern IGRlong CO_ni_place_circle_by_diameter __((IGRlong *msg, struct GRevent *Events[], enum GRdpmode *DisplayMode, IGRboolean newflag, struct GRmd_env *ModuleInfo, struct IGRdisplay *ActiveDisplay, IGRshort *ActiveLevel, IGRchar *attr, IGRchar *name, struct GRid *CircleGrid, struct GRid *DisplayGrid, IGRchar *classname, GRclassid classid, OM_S_NEIGHBOR neighbor, OM_S_OBJID cob_id, GRspacenum cob_os, OM_S_CHANSELECT *p_co_chanselect, IGRint co_index));

#if defined(__cplusplus)
}
#endif


#undef __
