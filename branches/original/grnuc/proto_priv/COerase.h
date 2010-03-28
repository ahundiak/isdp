#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/COerase.I */
extern IGRlong COEraseSendRedraw __((IGRlong *msg, IGRshort *matrix_type, IGRmatrix matrix, enum GRdpmode erase_mode, struct GRid *erase_grid, OM_S_MESSAGE *passon_message, enum GRdpmode draw_mode, struct GRid *draw_grid, GRobjid co_objid, OM_S_CHANSELECT *channel_struct, IGRint from_index, IGRint to_index, struct GRid *object_grid));

#if defined(__cplusplus)
}
#endif


#undef __
