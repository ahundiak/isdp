#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/passdim.I */
extern IGRint DMglupdate __((IGRint target, IGRchar g_type, IGRchar g_mask, IGRchar d_type, IGRchar d_mask, IGRboolean compute, struct GRmd_env *md_env));
extern IGRint DMpass_message __((OM_p_MESSAGE p_msg, IGRint target, OMuword osnum, struct GRmd_env *md_env, IGRboolean all_contexts));
extern IGRint DMget_components __((struct GRid owner, IGRint *p_size, struct GRid **p_root, IGRint *p_count));
extern IGRint DMpass_to_feadim __((struct GRid fea, OM_p_MESSAGE p_msg));
extern IGRint DMget_obj_type __((struct GRid node, IGRboolean *is_owner, IGRboolean *is_node, IGRboolean load_classid));
extern IGRint DMcopy_to_ram __((int type, char *p_data, int size));
extern IGRint DMdisplay_invisible __((IGRint type, struct GRmd_env *md_env));
extern IGRint DMtransform_point __((IGRpoint point, IGRmatrix matrix));
extern IGRint DMtransform_matrix __((IGRpoint matrix, struct GRmd_env *md_env));
extern IGRint DMchgdpmode __((enum GRdpmode *mode));
extern IGRint DMdim_imported __((OM_S_OBJID dim_id, OMuword dim_os, struct GRid *impdim, struct GRid *context, IGRboolean *imported));
extern IGRint DMdisplay_status __((IGRint *msg, OM_S_OBJID dim_id, OMuword dim_os, struct GRmd_env *md_env, IGRmatrix vw_rot, IGRint type, IGRdouble view_angle));
extern IGRint DMdisplay_update __((IGRchar g_type, IGRchar g_mask, IGRchar d_type, IGRchar d_mask, IGRboolean erase, IGRboolean display, IGRboolean parallel_only, enum GRdpmode mode, IGRmatrix vw_orientation, IGRint target, struct GRmd_env *md_env));
extern IGRint DMcompare_dim __((IGRint set0_clear1, struct GRmd_env *md_env));
extern IGRint DMcheck_normal __((IGRint *msg, IGRint type, IGRdouble view_angle, IGRdouble dm_norm[3 ], IGRdouble vw_norm[3 ]));
extern IGRint DMget_normal __((IGRint *msg, OM_S_OBJID dim_id, OMuword dim_os, IGRint dim_type, IGRdouble dm_norm[3 ], IGRdouble *lbsys_mat, IGRdouble *text_mat, struct GRmd_env *md_env));
extern IGRint DMpost_conversion __((struct GRmd_env *md_env));
extern IGRint DMadd_dim_to_rtree __((IGRlong *msg, struct GRid *dim_grid, char *dim_info));

#if defined(__cplusplus)
}
#endif


#undef __
