#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/mod/COniex2in.I */
extern IGRlong CO_ni_extend_2_insect __((IGRlong *msg, struct GRevent *events[], struct GRmd_env *module_info[], enum GRdpmode display_mode, struct GRid *display_grid, GRobjid my_id, GRspacenum my_os, OM_S_CHANSELECT *my_channel_struct, struct GRid *objects_grid[]));

#if defined(__cplusplus)
}
#endif


#undef __
