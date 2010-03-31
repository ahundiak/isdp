#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VEdpbi.I */
extern void VEget_dpb_super __((OM_S_OBJID *super_id, OMuword *super_os));
extern IGRint VEdpb_copy_data_to_other_os __((OMuword osnum));
extern IGRint VEdpb_get_flags __((IGRuint *flags));
extern IGRint VEdpb_set_flags __((IGRuint flags));
extern IGRint VEdpb_get_gapping_distance __((IGRdouble *gapping_distance));
extern IGRint VEdpb_set_gapping_distance __((IGRdouble gapping_distance));
extern IGRint VEdpb_get_trace_tol __((IGRdouble *trace_tol));
extern IGRint VEdpb_set_trace_tol __((IGRdouble trace_tol));
extern IGRint VEdpb_get_reduction_thresholds __((IGRshort *surf_threshold, IGRshort *curve_threshold));
extern IGRint VEdpb_set_reduction_thresholds __((IGRshort surf_threshold, IGRshort curve_threshold));
extern IGRint VEdpb_get_last_bg_info __((IGRchar *last_server, IGRchar *last_user_name, IGRchar *last_password, IGRchar *last_results_file, IGRchar *last_start_time));
extern IGRint VEdpb_set_last_bg_info __((IGRchar *last_server, IGRchar *last_user_name, IGRchar *last_password, IGRchar *last_results_file, IGRchar *last_start_time));

#if defined(__cplusplus)
}
#endif


#undef __
