#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/mod/COniex1in.I */
extern IGRlong CO_ni_extend_1_insect __((IGRlong *msg, struct GRevent *Events[], struct GRmd_env *ModuleInfo[], enum GRdpmode DisplayMode, struct GRid *DisplayGrid, GRobjid my_id, GRspacenum MyOs, OM_S_CHANSELECT *MyChannelStruct, struct GRid *ObjectsGrid[]));

#if defined(__cplusplus)
}
#endif


#undef __
