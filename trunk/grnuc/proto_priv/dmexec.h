#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/dmexec.I */
extern IGRint DMbroadcast __((IGRint *msg, IGRint level, OM_S_MESSAGE msglist[], IGRint msgcount, struct GRid *p_root));
extern IGRint DMdisplay_dimension __((IGRint *msg, IGRint level, IGRint control, struct GRmd_env *md_env, struct GRid *p_root));
extern IGRint DMmod_graph_batch_cp __((IGRint flag, IGRboolean *cp_mode, IGRint *graph, IGRint *batch));
extern IGRint DMcopy_dimension __((IGRint *msg, struct GRmd_env *from_env, struct GRmd_env *to_env, OM_S_OBJID old_parent, OM_S_OBJID new_parent, struct GRid *p_root, struct GRid *p_copy));
extern IGRint DMdelete_dimension __((IGRint *msg, IGRint delete_graph, struct GRmd_env *md_env, struct GRid *p_root));
extern IGRint DMmake_grgrp __((OM_S_OBJECT_LINKAGE list[], IGRint *count, struct GRmd_env *md_env));
extern IGRint DMdelete_components __((OM_S_OBJECT_LINKAGE list[], IGRint *count, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
