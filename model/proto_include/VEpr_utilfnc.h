#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VEb_scripts.C */
extern void VEescape_special_characters __((char *string1, char *string2));
extern int VE_initialize_bg __((OM_S_OBJID gragad_id, char *working_dir, char *unique, char *server, char *nodename, int keep_files, char *start_time, char outfile[]));
extern int VEwrite_check_bg_results_script __((char *working_dir, char *unique, char *server, char outfile[]));
extern int VEwrite_retrieve_bg_results_script __((char *working_dir, char *unique, char *server, char *result_name, IGRboolean synchronous, char outfile[]));
extern IGRint VEverify_server_connection __((IGRchar *server, IGRchar *user_name, IGRchar *password));

/* VEbatch_func.C */
extern void VEparse_log_file_for_status __((IGRchar *filename, IGRchar *start_time, IGRint *num_processing, IGRint *num_activated, IGRint *num_completed, IGRint *num_minutes, IGRint *num_seconds));
extern IGRboolean VEget_directory_names __((IGRchar *working_dir, IGRint working_dir_size, IGRchar *support_dir, IGRint support_dir_size, IGRchar *cur_filename, IGRint cur_filename_size));
extern void VEgenerate_unique_name __((IGRchar *node_name, IGRchar *unique_name));
extern FILE *VEcreate_log_file __((IGRchar *working_dir, IGRchar *unique_name, IGRchar *node_name, IGRchar *orig_name, IGRchar *view_name, IGRchar *server_name, IGRchar *results_name));
extern void VEcopy_color_table_info __((struct GRid *invis_module));
extern IGRboolean VEcopy_seed_file __((IGRchar *fname));
extern void VEturn_windows_off __((OM_S_OBJID ve_id));
extern IGRboolean VEvalidate_server_name __((IGRchar *server, IGRchar *valid_server));

/* VEclip_curve.c */
extern void VEdelete_edge __((struct VEedge_header **edge_address));
extern IGRboolean VEclip_curve __((struct VEedge_header **edge_list, struct VEplane *clipping_planes, IGRboolean *was_clipped));

/* VEconfirm.c */
extern IGRboolean VEconfirm __((IGRchar *msg));

/* VEdir_func.C */
extern IGRboolean VEcreate_default_directory __((IGRshort invis_os));
extern void VEcreate_env_directories __((IGRshort invis_os, IGRshort attach_id));
extern void VEadd_env_objects_to_dir __((IGRshort invis_os, IGRshort attach_id, IGRlong clip_diag_id, IGRlong color_id, IGRlong style_id, IGRlong weight_id));
extern void VEadd_to_objects_dir __((IGRshort invis_os, IGRshort attach_id, IGRlong objid));
extern void VEcollect_elements_in_batch __((struct GRid *fence_grid));

/* VEedge_func.c */
extern struct VEvisib_node *VEconstruct_visib_list __((struct IGRbsp_curve *curve, IGRshort visib));
extern void VEadd_edges_to_list __((struct VEedge_header *edges, struct VEedge_header **head, struct VEedge_header **tail));
extern struct VEedge_header *VEconstruct_iso_edge __((struct IGRbsp_surface *surf, IGRint par_option, IGRdouble parm, IGRshort edge_type));
extern void VEremove_totally_overlapped_edges __((struct VEelement_header *element));

/* VEgap_func.c */
extern void VEmark_degenerate_spans __((struct IGRbsp_curve *curve, struct VEvisib_node *visib_list, struct IGRbsp_curve *temp_curve));
extern void VEgap_edge __((struct VEedge_header *edge, IGRboolean creating_hidden_edges));

/* VEmem_man.c */
extern void VEinit_memory_management __((void));
extern void VEfree_memory __((void));
extern void VEget_temp_curve_storage __((struct IGRbsp_curve *curve, IGRint num_poles, IGRint num_knots, IGRboolean rational));
extern void VEget_unweighted_pole_storage __((IGRint num_poles, IGRdouble **poles));
extern void VEget_curve_clip_memory __((IGRint max_poles, IGRdouble **int_points, IGRdouble **int_params, IGRdouble **start_params, IGRdouble **end_params));
extern void VEget_sharp_knot_storage __((IGRint num_u, IGRint num_v, IGRdouble **u_knots, IGRdouble **v_knots));
extern struct BSgeom_bsp_curve *VEalloc_geom_curve __((IGRshort order, IGRlong num_poles, IGRboolean rational, IGRshort num_boundaries));
extern void VEfree_geom_curve __((struct BSgeom_bsp_curve *gmcurve));
extern struct VEelement_header *VEalloc_element_header __((void));
extern struct VEedge_header *VEalloc_edge_header __((void));
extern struct VEvisib_node *VEalloc_visib_node __((IGRdouble u_val));
extern struct VEtemp_node *VEalloc_temp_node __((IGRdouble u_val));
extern struct VEpt_proj_node *VEalloc_pt_proj_node __((void));
extern struct VEid_list *VEalloc_id_list_node __((void));
extern struct VEsaved_int_node *VEalloc_saved_int_node __((IGRint num_int, IGRint num_over, IGRint bucket_no));
extern void VEfree_saved_int_node __((struct VEsaved_int_node *node));
extern void VEfree_element_header __((struct VEelement_header *elem));
extern void VEfree_edge_header __((struct VEedge_header *edge));
extern void VEfree_visib_node __((struct VEvisib_node *node));
extern void VEfree_visib_node_list __((struct VEvisib_node *node_list));
extern void VEfree_temp_node __((struct VEtemp_node *node));
extern void VEfree_temp_node_list __((struct VEtemp_node *node_list));
extern void VEfree_pt_proj_node __((struct VEpt_proj_node *node));
extern void VEfree_pt_proj_node_list __((struct VEpt_proj_node *node_list));
extern void VEfree_id_list_node __((struct VEid_list *node));

/* VErange.c */
extern void VEfind_curve_range __((struct IGRbsp_curve *curve, IGRdouble range[6 ]));
extern void VEupdate_element_range __((struct VEelement_header *element, IGRboolean was_clipped, IGRboolean missing_link));

/* VEset_ranges.c */
extern void VEset_edge_ranges __((struct VEelement_header *element));

/* VEsplit.c */
extern struct IGRbsp_curve *VEcurve_split __((struct IGRbsp_curve *parent_curve, IGRdouble start_u, IGRdouble end_u));
extern struct BSgeom_bsp_curve *VEgeom_curve_split __((struct BSgeom_bsp_curve *parent_curve, IGRdouble start_u, IGRdouble end_u));
extern struct VEedge_header *VEedge_split __((struct VEedge_header *parent_edge, IGRdouble u_start, IGRdouble u_end));
extern void VEsplit_out_temp_list_overlaps __((struct VEedge_header *edge, struct VEedge_header **head, struct VEedge_header **tail));
extern void VEsplit_out_hidden_pieces __((struct VEedge_header *edge, struct VEedge_header **visib_head, struct VEedge_header **visib_tail, struct VEedge_header **hidden_head, struct VEedge_header **hidden_tail));

/* VEstatus.C */
extern void VEinit_heartbeat __((IGRchar *string));
extern void VEupdate_heartbeat __((void));
extern void VEupdate_num_finished __((void));
extern void VEupdate_num_activated __((void));
extern void VEdisplay_processing_message __((void));
extern void VEinit_messages __((void));
extern void VEissue_abort_message __((void));
extern void VEinit_batch_logging __((IGRchar *unique));
extern void VEstop_batch_logging __((void));

/* VEsurf_red.c */
extern void VEsurface_reduction __((struct VEelement_header *element));

/* VEtransform.c */
extern void VEtransform_3D_points __((IGRdouble matrix[4 ][4 ], IGRint num_points, IGRdouble *points, IGRdouble *weights));
extern void VEassign_clipping_planes_from_range __((struct VEplane *clip_planes, IGRdouble *range));
extern void VEdetermine_clipping_planes __((struct VEenv_info *env, IGRboolean is_master_env));
extern IGRboolean VEset_transformations __((struct DPgra_gad *gra_gad));
extern void VEget_range __((IGRint num_poles, IGRdouble *poles, IGRdouble *weights, IGRdouble *range, IGRboolean transform));
extern void VEset_fence_clip __((struct IGRbsp_curve *fence));
extern void VEtrans_curve_to_view __((struct IGRbsp_curve *curve));
extern IGRboolean VEcopy_and_trans_to_view __(( IGRchar **geom, IGRint type));
extern void VEtrans_to_world __((IGRchar *geom, IGRint type));
extern void VEtrans_to_world_without_projecting __((IGRchar *geom, IGRint type));
extern void VEget_curve_points_in_dits __((struct IGRbsp_curve *curve, IGRdouble end_pt0[3 ], IGRdouble end_pt1[3 ]));

/* VExy_collin.c */
extern void VEget_xyslope __((IGRlong num_points, IGRpoint points[], IGRdouble *weights, IGRdouble *dx, IGRdouble *dy));
extern IGRboolean VExy_collinear __((IGRlong num_points, IGRpoint points[], IGRdouble *weights));

#if defined(__cplusplus)
}
#endif


#undef __

