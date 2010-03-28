#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPasap_intfc.C */
extern void DPset_ASAPII_use __((IGRboolean flag));
extern void DPsave_ASAPII_window_number __((IGRint win_no));
extern IGRboolean DPusing_ASAPII __((void));
extern void DPsave_ASAPII_symbology __((IGRint color, IGRint style, IGRint weight));
extern void DPget_data_from_ASAPII __((void));
extern void DPget_final_linestrings_from_ASAPII __((void));
extern IGRint DPget_request_buf_ptrs __((IGRint size, IGRint type, IGRchar **buf_ptr, IGRchar **asap_ptr));
extern IGRint DPasapII_send_transformation_matrix __((IGRint gpipe_id, IGRdouble trans_matrix[4 ][4 ], IGRdouble world_tol, IGRdouble dev_tol));
extern IGRint DPasapII_stroke_linestring __((IGRint gpipe_id, IGRdouble *points, IGRint num_points));
extern IGRint DPasapII_stroke_curve __((IGRint gpipe_id, IGRint order, IGRint num_poles, IGRdouble *poles, IGRdouble *knots, IGRdouble *weights, IGRint rational, IGRint num_boundaries, IGRdouble *boundaries, IGRint base_color, IGRint *attr_index, GPattribute *attr_bundle, IGRint bundle_size, IGRint options));
extern IGRint DPasapII_stroke_surface __((IGRint gpipe_id, IGRint u_order, IGRint v_order, IGRint u_num_poles, IGRint v_num_poles, IGRdouble *poles, IGRdouble *u_knots, IGRdouble *v_knots, IGRdouble *weights, IGRint rational, IGRint u_num_rules, IGRint v_num_rules, IGRdouble *u_rule_values, IGRdouble *v_rule_values, IGRint *u_num_bound, IGRint *v_num_bound, IGRdouble **u_bdrys, IGRdouble **v_bdrys, IGRint num_boundaries, GPboundary *boundaries, IGRint options));
extern IGRint DPasapII_send_clip_range __((IGRint gpipe_id, IGRdouble range[6 ], IGRint front, IGRint back));

#if defined(__cplusplus)
}
#endif


#undef __
