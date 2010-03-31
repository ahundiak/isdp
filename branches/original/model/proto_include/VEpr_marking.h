#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VEmk_cvpt.c */
extern struct VEedge_header *VEmark_curve_or_point __((
					struct VEelement_header  *element, 
					struct IGRbsp_curve      *curve, 
					IGRshort                 type, 
					IGRint                   edge_id));

/* VEmk_lpedges.I */
extern void VEset_iso_edge_info __((	struct VEedge_header     *edge, 
					OMuword                  osnum, 
					IGRushort                edge_prop_word));
extern struct BSgeom_bsp_curve *VEget_edge_geometry __((
					struct IGRbsp_surface    *surf, 
					OM_S_OBJID               edge_id, 
					struct VEenv_info        *env, 
					IGRboolean               ok_to_reparameterize));
extern struct VEedge_header *VEget_surf_edges_and_bdrys __((
					struct VEelement_header  *element));

/* VEmk_natural.c */
extern struct VEedge_header *VEgen_natural_edges __((
					struct IGRbsp_surface    *surf));

/* VEmk_part.c */
extern struct VEedge_header *VEmark_parting_lines __((
					struct VEelement_header  *elem));

/* VEmk_rules.I */
extern struct VEedge_header *VEprocess_RLT __((
					struct IGResqbs          *rlt, 
					struct IGRbsp_surface    *surf, 
					IGRboolean               cross_hatching, 
					IGRint                   num_u_sharp, 
					IGRdouble                *sharp_u, 
					IGRint                   num_v_sharp, 
					IGRdouble                *sharp_v));
extern struct VEedge_header *VEmark_rule_lines __((
					IGRint                   surf_id, 
					IGRint                   surf_os,
 					struct IGRbsp_surface    *surf,
 					IGRint                   num_u_sharp,
 					IGRdouble                *sharp_u,
 					IGRint                   num_v_sharp,
 					IGRdouble                *sharp_v));

/* VEmk_shrpmsh.c */
extern struct VEedge_header *VEmark_sharps_and_rules __((
					struct VEelement_header  *elem));

/* VEmk_surf.I */
extern void VEmark_surface_edges __((	struct VEelement_header  *elem));

/* VEmk_xhatch.I */
extern void VEmark_wireframe_cross_hatching __((
					struct VEelement_header  *element));
extern void VEmark_surface_cross_hatching __((
					struct VEelement_header  *element));

#if defined(__cplusplus)
}
#endif


#undef __

