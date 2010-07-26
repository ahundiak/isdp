#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPcodpbi.I */
extern IGRint DPcodpb_get_cct_data __((IGRushort *cct_flags, IGRchar *ctable_filename));
extern IGRint DPcodpb_set_cct_data __((IGRushort cct_flags, IGRchar *ctable_filename));
extern IGRint DPcodpb_get_persp_flags __((IGRushort *persp_flags));
extern IGRint DPcodpb_set_persp_flags __((IGRushort persp_flags));
extern IGRint DPcodpb_get_sws_flags __((IGRushort *sws_flags));
extern IGRint DPcodpb_set_sws_flags __((IGRushort sws_flags));
extern IGRint DPcodpb_get_dls_flags __((IGRushort *dls_flags));
extern IGRint DPcodpb_set_dls_flags __((IGRushort dls_flags));
extern IGRint DPcodpb_get_mvv_flags __((IGRushort *mvv_flags));
extern IGRint DPcodpb_set_mvv_flags __((IGRushort mvv_flags));
extern IGRint DPcodpb_get_layer_flags __((IGRushort *layer_flags));
extern IGRint DPcodpb_set_layer_flags __((IGRushort layer_flags));
extern IGRint DPcodpb_get_dvd_flags __((IGRushort *dvd_flags));
extern IGRint DPcodpb_set_dvd_flags __((IGRushort dvd_flags));
extern IGRint DPcodpb_get_pixel_tolerance __((IGRchar *pixel_tol));
extern IGRint DPcodpb_set_pixel_tolerance __((IGRchar pixel_tol));
extern IGRint DPcodpb_get_dvd_speed __((IGRchar *dvd_speed));
extern IGRint DPcodpb_set_dvd_speed __((IGRchar dvd_speed));

#if defined(__cplusplus)
}
#endif


#undef __
