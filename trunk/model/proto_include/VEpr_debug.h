#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VEdebug.c */
extern void VEdebug_surface __((struct IGRbsp_surface *surf, IGRboolean flag));
extern void VEdebug_curve __((struct IGRbsp_curve *curve, IGRboolean flag));
extern void VElog_cvcv_int_data __((struct IGRbsp_curve *curve0, struct IGRbsp_curve *curve1));
extern void VElog_cvslf_int_data __((struct IGRbsp_curve *curve));
extern void VElog_pt_proj_data __((IGRdouble *point, IGRdouble *vector, struct IGRbsp_surface *surface));
extern void VElog_parting_line_data __((struct IGRbsp_surface *surf, IGRdouble *u_range, IGRdouble *v_range));

/* VEelem_debug.c */
extern void VEwrite_curve_type __((struct BSgeom_bsp_curve *gmcurve, IGRboolean new_line));
extern void VEvisib_list_debug __((struct VEvisib_node *node));
extern void VEtemp_list_debug __((struct VEtemp_node *node));
extern void VEedge_debug __((struct VEedge_header *edge));
extern void VEelement_debug __((struct VEelement_header *element));
extern void VEactive_list_debug __((struct VEelement_header *list));
extern void VEsaved_int_list_debug __((struct VEsaved_int_node *list));
extern void VElog_mult_proj_data __((struct VEelement_header *hiding_element, IGRint proj_count, IGRpoint *points, IGRint num_vecs, IGRpoint *vecs, IGRboolean bi_directional, IGRint alloc));
extern void VElog_mult_proj_output __((IGRint proj_count, IGRint *num, IGRpoint *proj_pts, IGRdouble *uv_par));

#if defined(__cplusplus)
}
#endif


#undef __

