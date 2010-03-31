#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VEadd_nodes.c */
extern void VEinsert_temp_node __((IGRdouble parm, struct VEedge_header *edge, IGRdouble knot_tol));
extern void VEremove_nested_overlaps __((struct VEedge_header *edge));
extern void VEinsert_overlap_temp_node __((IGRdouble parm, IGRshort p_visib, IGRshort n_visib, IGRdouble knot_tol, struct VEtemp_node **p_node, struct VEtemp_node **t_node));
extern void VEadd_overlap_region __((IGRdouble parm0, IGRdouble parm1, struct VEedge_header *edge, IGRshort visib_type, IGRdouble knot_tol));

/* VEcalcovlap.c */
extern void VEfind_self_overlaps_for_collinear_edge __((struct VEedge_header *edge, IGRboolean *changes_made, IGRdouble *elem_range, IGRdouble knot_tol));
extern void VEadd_knots_at_transition_points __((struct IGRbsp_curve *curve, IGRdouble knot_tol));

/* VEcedges_sh.c */
extern int VEcompare_edges_sh __((struct VEedge_header *edge0, struct VEedge_header *edge1, struct VEelement_header *element, IGRboolean doing_hiding, IGRboolean intersection_misses));

/* VEcompedges.c */
extern IGRboolean VEnot_hiding_with_self_hidden_pt __((struct VEedge_header *edge, IGRdouble par));
extern void VEcompare_edges __((struct VEedge_header *edge0, struct VEedge_header *edge1, struct VEelement_header *element0, struct VEelement_header *element1, IGRboolean e0_hides_e1, IGRboolean e1_hides_e0, IGRboolean pseudo_int, IGRboolean self_hiding));

/* VEcompsurfs.c */
extern void VEset_element_visibility_status __((struct VEelement_header *element));
extern void VEcomp_surfs __((struct VEelement_header *dom_element, struct VEelement_header *pass_element, IGRboolean doing_hiding, IGRboolean self_hiding));

/* VEcvcv_int.c */
extern void VEcvcv_int __((IGRint *rc, struct VEelement_header *elem0, struct VEelement_header *elem1, struct VEedge_header *edge0, struct VEedge_header *edge1, IGRint *n_int, IGRpoint **int_pts, IGRdouble **par0, IGRdouble **par1, IGRint *n_over, IGRpoint **end_pts, IGRdouble **over0, IGRdouble **over1, IGRboolean *free_ints, IGRboolean *free_overs, IGRboolean intersection_misses, IGRboolean pseudo_int, IGRdouble *edge_based_dist_tol));
extern void VEcv_slfint __((IGRint *rc, struct VEedge_header *edge, struct IGRbsp_curve *curve, IGRdouble to_world_scale, IGRint *n_int, IGRdouble **a_par, IGRdouble **b_par, IGRint *n_over, IGRdouble **c_over, IGRdouble **d_over, IGRdouble **e_over, IGRdouble **f_over, IGRdouble *edge_based_dist_tol));
extern void VEcvcv_int_3d __((IGRint *rc, struct IGRbsp_curve *curve0, struct IGRbsp_curve *curve1, IGRint *n_int, IGRpoint **int_pts, IGRdouble **par0, IGRdouble **par1, IGRint *n_over, IGRpoint **end_pts, IGRdouble **over0, IGRdouble **over1, IGRboolean *free_ints, IGRboolean *free_overs));

/* VEdisj_z_ce.c */
extern void VEdisjoint_z_compare_edges __((struct VEedge_header *near_edge, struct VEedge_header *far_edge, struct VEelement_header *near_element, struct VEelement_header *far_element, IGRboolean near_can_hide_far, IGRboolean pseudo_int));

/* VEmerge.c */
extern void VEmerge_visibs __((struct VEedge_header *edge));

/* VEmult_proj.c */
extern IGRboolean VEis_corresponding_edge_in_edge_list __((struct VEedge_header *edge, struct VEelement_header *other_element));
extern void VEset_visibilities_mult_proj __((struct VEelement_header *element, struct VEelement_header *hiding_element, IGRboolean self_hiding, IGRboolean doing_hiding));

/* VEoverlap.c */
extern void VEprocess_overlap __((struct VEedge_header *edge0, struct VEedge_header *edge1, IGRdouble *e0_parm, IGRdouble *e1_parm, IGRdouble *e0_xyz, IGRdouble *e1_xyz, IGRboolean elem0_can_hide_elem1, IGRboolean elem1_can_hide_elem0, IGRdouble z_tolerance, IGRdouble knot_tol0, IGRdouble knot_tol1, IGRboolean self_hiding));
extern IGRboolean VEoverlap_is_really_intersection __((IGRpoint pt0, IGRpoint pt1, IGRpoint pt2, IGRpoint pt3, IGRdouble z_tolerance));

/* VEsave_cvcv.c */
extern void VEsave_intersection_info __((struct VEedge_header *edge0, struct VEedge_header *edge1, struct VEelement_header *elem0, struct VEelement_header *elem1, IGRint num_int, IGRint num_over, IGRdouble *par0, IGRdouble *par1, IGRdouble *over0, IGRdouble *over1));
extern IGRboolean VEretrieve_intersection_info __((struct VEedge_header *edge0, struct VEedge_header *edge1, IGRint *num_int, IGRint *num_over, IGRdouble **par0, IGRdouble **par1, IGRdouble **over0, IGRdouble **over1));
extern void VEremove_intersection_info __((IGRboolean one_edge, struct VEedge_header *edge0, struct VEedge_header *edge1));

/* VEselfhide.c */
extern void VEinit_temp_list __((struct VEedge_header *edge));
extern void VEself_hide __((struct VEelement_header *element, IGRboolean doing_hiding));

#if defined(__cplusplus)
}
#endif


#undef __

