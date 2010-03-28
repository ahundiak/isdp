#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/ln/COniperbis.I */
extern IGRlong CO_ni_perbis __((IGRlong *msg, struct GRevent *Events[], struct GRmd_env *ConstructInfo, IGRboolean NewFlag, struct IGRdisplay *ActiveDisplay, IGRshort *ActiveLevel, IGRchar *Attributes, IGRchar *Name, struct GRid *LineSegmentGrid, IGRchar *ClassName, GRclassid ClassID, OM_S_NEIGHBOR Neighbor, OM_S_OBJID CobID, GRspacenum CobOS, OM_S_CHANSELECT *p_co_chanselect, IGRint co_index, enum GRdpmode LocateDisplayMode, enum GRdpmode ConstructDisplayMode, struct GRid *DisplayGrid, struct GRmd_env *ModuleInfo[], struct GRid *ObjectsGrid[]));

#if defined(__cplusplus)
}
#endif


#undef __
