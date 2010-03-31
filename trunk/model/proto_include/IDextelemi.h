#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* IDextelemi.I */
extern IGRint IDDYextelem __((
    IGRint FunctionIndex, 
    struct GRevent *events[], 
    struct GRmd_env *LocateContext, 
    GRobjid MyId, GRspacenum my_os, 
    OM_S_CHANSELECT *MyChannelStruct, 
    struct GRid *ObjectsGrid));

#if defined(__cplusplus)
}
#endif

