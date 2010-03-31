#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/*---HPclassify.I--------------------------------------------*/

extern IGRint HPclassify_located_object __(( IGRlong *, struct GRid *, struct GRmd_env *, IGRmatrix, IGRshort, IGRint *, IGRshort *, IGRshort *, struct GRid *, IGRdouble *));

/*---HPcollect.I---------------------------------------------*/

extern IGRint HPcollect_element_to_plot __((struct HSplot_info *, struct GRid *, OM_S_CHANSELECT *, IGRint *)); 

/*---HPf_attach.c--------------------------------------------*/

extern int HPcreate_textfile_with_raster_attachment __((IGRchar *, IGRchar *, IGRchar *));

/*---HPf_cancel.C--------------------------------------------*/

extern IGRint HPcancel_plot __(( IGRint,  struct HSplot_info *));

/*---HPf_dispform.C------------------------------------------*/

extern void HPdisplay_create_form __((struct HSplot_info *));
extern void HPdisplay_submit_form __((struct HSplot_info *));
extern void HPdisplay_queue_form  __((struct HSplot_info *));
extern void HPdisplay_option_form __((struct HSplot_info *));

/*---HPf_execute.C-------------------------------------------*/

extern IGRint HPexecute __(( struct HSplot_info *, IGRchar *)); 

/*---HPf_filedef.c-------------------------------------------*/

extern IGRint HPfiledef __(( IGRint, IGRchar *, IGRchar *, IGRchar *, IGRchar *, IGRchar *, IGRdouble *, IGRdouble *, IGRdouble *, IGRint *, IGRdouble *, IGRint *, IGRint *, IGRint *)); 

/*---HPf_notify.C---------------------------------------------*/

extern void HPcreate_form_notify __((IGRint gadget_label, struct HSplot_info *));
extern void HPsubmit_form_notify __((IGRint gadget_label, struct HSplot_info *));
extern void HPstatus_form_notify __((IGRint gadget_label, struct HSplot_info *));
extern void HPoption_form_notify __((IGRint gadget_label, struct HSplot_info *));

/*---HPf_plotmisc.c-------------------------------------------*/

extern IGRint HPcvtsize __(( IGRdouble *, IGRchar, IGRchar)); 

/*---HPf_pqinfo.C---------------------------------------------*/

extern IGRint HPpqinfo        __(( IGRchar *, IGRdouble *, IGRdouble *, IGRdouble *, IGRchar *)); 
extern IGRint HPspqlist       __(( Form, IGRint *,char *,unsigned int *)); 
extern IGRint HPspformatqinfo __(( IGRchar *, IGRdouble, IGRdouble, IGRdouble, IGRchar *, IGRchar *));
 
/*---HPf_qprreq.C---------------------------------------------*/

extern IGRint HPqprreq __(( struct HSplot_info *, IGRchar *)); 

/*---HPf_sizeplot.C-------------------------------------------*/

extern int HPsizescale           __(( struct HSplot_info *, int, Form)); 
extern int HPconvert_to_outunits __(( double, double, int, char *, char *)); 
extern int HPshow_size           __(( struct HSplot_info *));

/*---HPf_update.C---------------------------------------------*/

extern IGRint HPupdate_queue_status __(( struct HSplot_info *));
extern IGRint HPget_qstat_command   __(( IGRchar *, IGRchar *)); 

/*---HPf_verify.c---------------------------------------------*/

extern int HPverify __(( char *, int ));

/*---HPfind_fence.I-------------------------------------------*/

extern void HPfind_fence __(( struct HSplot_info *));

/*---HPfind_seed.C--------------------------------------------*/

extern IGRint HPfind_seedfile __(( IGRchar *));

/*---HPsubmit_job.C-------------------------------------------*/

extern int HPsubmit_job __(( char *plotfile_name, char *, char *, char *, char *));

/*---HPuniq_name.c--------------------------------------------*/

extern void HPgenerate_unique_name __((char *, char *)); 

/*---HPwrite_curv.I-------------------------------------------*/

extern void HPwrite_curve __(( struct GRid *, IGRshort *, IGRmatrix, struct GRmd_env *, struct HSplot_info *));
 
/*---HPwrite_hdr.I--------------------------------------------*/

extern IGRint HPwrite_header __(( struct HSplot_info *, IGRint ));

/*---HPwrite_surf.I-------------------------------------------*/

extern void HPwrite_surface __(( struct GRid *, IGRshort *, IGRmatrix, struct GRmd_env *, IGRint, struct HSplot_info *)); 

/*---HPwrite_util.C-------------------------------------------*/

extern void HPget_max_width_active_style __(( short *, short *)); 
extern void HPwrite_init                 __(( void ));
extern IGRint HPwrite_plotfile_header    __(( struct HSplot_info *, IGRdouble *, IGRdouble *, IGRdouble *));
extern IGRint HPwrite_colortable         __(( struct HSplot_info *)); 
extern IGRint HPwrite_trans_grid         __(( struct HSplot_info *));
extern IGRint HPwrite_depth_cues         __(( struct HSplot_info *));
extern IGRint HPwrite_light_sources      __(( struct HSplot_info *));

extern IGRint HPwrite_view_orientation_and_range __(( struct HSplot_info *, IGRdouble *, IGRdouble *)); 
extern IGRint HPwrite_perspective_flag           __(( struct HSplot_info *, IGRint )); 
extern IGRint HPwrite_other_matrices             __(( struct HSplot_info *, IGRdouble *, IGRdouble *, IGRdouble *)); 
extern IGRint HPwrite_hidden_symbology_parms     __(( struct HSplot_info *)); 
extern IGRint HPwrite_line_style                 __(( IGRint *, unsigned short )); 
extern IGRlong HPwrite_symbology                 __(( IGRint *, struct IGRdisplay *)); 
extern IGRlong HPwrite_rendering                 __(( IGRint *, IGRint, IGRshort, IGRint *)); 
extern IGRlong HPwrite_draw_range                __(( IGRint *, IGRint, IGRint, GRrange)); 
extern IGRlong HPconvert_curve                   __(( struct IGRbsp_bdry_pts *, struct IGRbsp_curve **)); 
extern IGRlong HPwrite_surface_info              __(( IGRint *, struct IGRbsp_surface *, IGRshort )); 
extern IGRlong HPwrite_curve_info                __(( IGRint *, struct IGRbsp_curve *, IGRint, IGRboolean)); 
extern IGRlong HPwrite_curve_soo                 __(( IGRint *, IGRdouble *, struct IGRdisplay *, IGRint, IGRint * ));

#if defined(__cplusplus)
}
#endif


#undef __
