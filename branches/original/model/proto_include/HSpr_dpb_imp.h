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

/* HSNCdpbi.I */

extern void HSNCget_dpb_super          __(( OM_S_OBJID *, OMuword *));
extern void HSNCget_verification_parms __(( IGRint *, IGRint *, IGRint *));				    
extern int HSNCput_verification_parms  __(( IGRint, IGRint, IGRint ));

/* HScolor_info.C */

extern void   HSgetMachineInfo       __(( IGRint *, IGRint *, IGRint *));

/* HSconvert.I */

extern IGRlong HSconvert_shading_window_to_wireframe __(( IGRlong *, OM_S_OBJID, OMuword, IGRint, IGRint ));
extern IGRlong HSconvert_wireframe_window_to_shading __(( IGRlong *, OM_S_OBJID, OMuword, IGRint, IGRint, IGRuchar, IGRint, IGRint ));

/* HSdpb2i.I */

extern void   HSget_dpb_super             __(( OM_S_OBJID *, OMuword *));			    
extern IGRint HSdpb_copy_data_to_other_os __(( OMuword ));
extern IGRint HSdpb_get_shading_tolerance __(( IGRdouble *));
extern IGRint HSdpb_put_shading_tolerance __(( IGRdouble ));
extern IGRint HSdpb_get_shading_accuracy  __(( IGRint *));
extern IGRint HSdpb_set_shading_accuracy  __(( IGRint ));
extern IGRint HSdpb_get_shading_flags     __(( IGRuint *, IGRuint *, IGRuint *, IGRuint *, IGRuint *));
extern IGRint HSdpb_put_shading_flags     __(( IGRuint *, IGRuint *, IGRuint *, IGRuint *, IGRuint *));
extern IGRint HSdpb_get_rendering_bundles __(( struct HSrender_bundle *, struct HSextra_render_bundle *));
extern IGRint HSdpb_set_rendering_bundles __(( struct HSrender_bundle *, struct HSextra_render_bundle *));
extern IGRint HSdpb_get_shading_depth_cues __(( IGRuchar *));
extern IGRint HSdpb_set_shading_depth_cues __(( IGRuchar ));
extern IGRint HSdpb_get_vhl_layers        __(( IGRushort *, IGRushort *, IGRushort *));
extern IGRint HSdpb_set_vhl_layers        __(( IGRushort, IGRushort, IGRushort ));
extern IGRint HSdpb_get_render_image_info __(( IGRchar *, IGRint *, IGRint *, IGRchar *, IGRchar *));
extern IGRint HSdpb_set_render_image_info __(( IGRchar *, IGRint, IGRint, IGRchar *, IGRchar *));
extern IGRint HSdpb_get_last_styles       __(( IGRuchar *, IGRuchar *));
extern IGRint HSdpb_set_last_styles       __(( IGRuchar *, IGRuchar *));
extern IGRint HSdpb_get_hplot_info        __(( IGRuint *, IGRchar *, IGRchar *, IGRchar *, IGRchar *, IGRdouble *, 
                                               IGRdouble *, IGRdouble *, IGRint *, IGRchar *, IGRdouble *, IGRint *, IGRint *));
extern IGRint HSdpb_set_hplot_info        __(( IGRuint *, IGRchar *, IGRchar *, IGRchar *, IGRchar *, IGRdouble *, 
                                               IGRdouble *, IGRdouble *, IGRint *, IGRchar *, IGRdouble *, IGRint *, IGRint *));
extern IGRint HSdpb_get_place_light_info  __(( IGRint *, IGRuint *));
extern IGRint HSdpb_set_place_light_info  __(( IGRint, IGRuint ));
extern IGRint HSdpb_get_display_image_delays __(( IGRdouble *, IGRdouble *));
extern IGRint HSdpb_set_display_image_delays __(( IGRdouble *, IGRdouble *));
					  
/* HSedgeII_vlt.C */

extern IGRint HSbuild_rhl2_vlt              __(( void ));
extern IGRint HScalibrate_edgeII_vlts       __(( IGRint ));
extern IGRint HSallocate_edgeII_vlts        __(( void ));
extern IGRint HSclear_window                __(( IGRint ));
extern IGRint HSassign_edgeII_vlt_to_window __(( IGRint, IGRint, IGRboolean, IGRboolean ));

/* HSfemmode.C */

extern void   HSget_fem_style __(( IGRint *));
extern IGRint HSset_fem_style __(( IGRint ));
extern void   HSget_fem_mesh  __(( IGRint *));
extern IGRint HSset_fem_mesh  __(( IGRint ));

/* HSlight_src.I */

extern IGRlong HSget_light_objid_and_os __(( int, OM_S_OBJID, OMuword, OM_S_OBJID *, OMuword *));

/*				 
extern int HSget_light __(( struct HS_light_source *, int ));
extern int HSput_light __(( struct HS_light_source *, int, struct GRid *));
*/
			       
extern void HSget_global_lights   __(( struct HS_light_source *, struct HS_light_source *));			     
extern IGRint HSset_global_lights __(( struct HS_light_source *, struct HS_light_source *));
			       
/* HSmodes.C */

extern void   HSget_symbology_modes __(( IGRint *, IGRint *, IGRint *, IGRint *));
extern IGRint HSset_symbology_modes __(( IGRint *, IGRint *, IGRint *, IGRint *));
extern void   HSget_accuracy_mode   __(( IGRint *));
extern IGRint HSset_accuracy_mode   __(( IGRint ));
extern void   HSget_trans_grid      __(( IGRint *));
extern IGRint HSset_trans_grid      __(( IGRint ));
extern void   HSget_cull_mode       __(( IGRint *));
extern IGRint HSset_cull_mode       __(( IGRint ));

/* HSrhl_info.C */

extern void   HSget_rhl_info __(( IGRint *));
extern IGRint HSset_rhl_info __(( IGRint *));

/* HSshad_symb.I */

extern IGRint HSget_element_shading_symb __(( OM_S_OBJID, OMuword, IGRint *, IGRint *, IGRdouble *, IGRdouble *, IGRdouble *, 
                                              IGRuchar *, unsigned short *, IGRuchar *, IGRuchar *, IGRuchar *, unsigned char *));
extern IGRint HSset_element_shading_symb __(( OM_S_OBJID, OMuword, IGRint *, IGRint *, IGRdouble *, IGRdouble *, IGRdouble *, 
                                              IGRuchar *, unsigned short *, IGRuchar *, IGRuchar *, IGRuchar *, unsigned char *));
extern IGRint HSget_active_shading_symb  __(( IGRint *, IGRint *, IGRdouble *, IGRdouble *, IGRdouble *, IGRuchar *, 
                                              unsigned short *, IGRuchar *, IGRuchar *, IGRuchar *, unsigned char *));
extern IGRint HSset_active_shading_symb  __(( IGRint *, IGRint *, IGRdouble *, IGRdouble *, IGRdouble *, IGRuchar *, 
                                              unsigned short *, IGRuchar *, IGRuchar *, IGRuchar *, unsigned char *));
			       

/* NCVdpbi.I */

#if defined(__cplusplus)
}
#endif


#undef __
