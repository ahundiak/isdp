#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/COprojev.I */
extern IGRlong COproject_event __((IGRlong *msg, struct GRevent *Event, struct GRmd_env *ModuleInfo, IGRpoint ProjectedPoint, struct GRparms *ProjectedParms, GRobjid my_id, OM_S_CHANSELECT *MyChannelStruct, struct GRid *ObjectsGrid));

#if defined(__cplusplus)
}
#endif


#undef __
