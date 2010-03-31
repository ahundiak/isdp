/*
 * HSpr_tiler_f.h: The prototype file for the 
 * hsurf/src/tiler_func directory
 */
 

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

#if defined( XGL )

/*---HStl_xgl.c-----------------------------------------------------*/

extern void HSsetup_XGL_lights __((
   struct HS_light_source global_lights[MAX_LIGHTS],
   struct HS_light_source *ambient_light ));

extern void HSsetup_XGL_window __((
   IGRdouble transformation_matrix[4][4],
   IGRdouble *vw_vol,
   IGRdouble eye_pt[3],
   IGRdouble vrp[3],
   IGRdouble vpn[3],
   IGRdouble vup[3],
   IGRint x_dits,
   IGRint y_dits,
   IGRboolean init_zbuffer ));

extern void HSdelete_XGL_shading_window __((
   void ));

extern int HSsend_mesh_to_XGL __((
   int dummy,
   struct HStri_mesh *tri_mesh ));

extern void HSsend_polyline_to_XGL __((
   int num_points,
   IGRpoint *points ));

extern void HSdraw_point_XGL  __((
    IGRpoint ));

extern void HSpaint_screen_XGL __((
   void ));

#endif

#if defined( OPENGL )

/*---HStl_opengl.c-----------------------------------------------------*/

extern void HSsetup_OPENGL_lights __((
   struct HS_light_source global_lights[MAX_LIGHTS],
   struct HS_light_source *ambient_light ));

extern void HSsetup_OPENGL_window __((
   IGRdouble transformation_matrix[4][4],
   IGRdouble *vw_vol,
   IGRdouble eye_pt[3],
   IGRdouble vrp[3],
   IGRdouble vpn[3],
   IGRdouble vup[3],
   IGRint x_dits,
   IGRint y_dits,
   IGRboolean init_zbuffer ));

extern void HSdelete_OPENGL_shading_window __((
   void ));

extern int HSsend_mesh_to_OPENGL __((
   int dummy,
   struct HStri_mesh *tri_mesh ));

extern void HSsend_polyline_to_OPENGL __((
   int num_points,
   IGRpoint *points ));

extern void HSdraw_point_OPENGL  __((
    IGRpoint ));

extern void HSpaint_screen_OPENGL __((
   void ));

#endif

/*---HSe2_facet.c-----------------------------------------------------*/

extern char *Malloc __((
   int ));

extern void Free __((
   char * ));

extern struct HStri_vertex **HSgetArray __((
   int ));

extern struct PolygonVert *HSalloc_VertPtr __((
   void ));

extern struct HStri_vertex *HSalloc_tri_vertex __((
   void ));

extern struct HStri_loop *HSalloc_tri_loop __((
   void ));

extern void HSend_tri_loop __((
   void ));

extern void HSdispose_tri_facet __((
   void ));

extern void HSadd_tri_vertex __((
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRboolean,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble )); 

extern void HSdoTriMesh __((
   void ));

extern int HSconvert_to_trimesh __((
   struct HSfem_tri_mesh *,
   struct HStri_mesh * ));

/*---HSinit_hdwr.c---------------------------------------------------*/


extern IGRint HScheck_hardware_support __((
   WLuint16,
   WLuint32,
   IGRboolean )); 

extern IGRint HSusing_GPIPE __((
   IGRint ));

extern void HSset_active_max_z __((
   int,
   int,
   int,
   int ));

/*---HSinit_paint.c---------------------------------------------------*/


extern void HSsilly_stub __((
   void ));

extern void HSraster_stub __((
   void ));

extern void HSinit_paint_fem __((
   IGRint *,
   IGRint * ));

extern void HSinit_paint_rop_ramp __((
   IGRint *color,
   IGRint *request_code ));

extern void HSinit_paint_ROP __((
   IGRint *,
   IGRint * ));

extern void HSinit_paint_IFB __((
   IGRint *,
   IGRint * ));

extern void HSinit_paint_EG __((
   IGRint *,
   IGRint * )); 

extern void HSinit_paint_OPENGL __((
   IGRint *,
   IGRint * )); 

extern void HSinit_paint_XGL __((
   IGRint *,
   IGRint * ));

/*---HSinit_wind.c----------------------------------------------------*/


extern void HSinitialize_buffers __((
   void ));

extern void HSinit_window_ROP __((
   IGRint,
   IGRint ));

extern void HSinit_window_IFB __((
   IGRint,
   IGRint ));

extern void HSinit_window_FPE __((
   IGRint,
   IGRint ));

extern void HSinit_window_EG __((
   IGRint,
   IGRint )); 

extern void HSinit_window_OPENGL __((
   IGRint,
   IGRint )); 

extern void HSinit_window_XGL __((
   IGRint,
   IGRint )); 

/*---HSmemory.c-------------------------------------------------------*/


extern void HMdebug_dump_chunks __((
   IGRint ));

extern void HMget_workstation_info __((
   int *,
   int *,
   int *,
   int *,
   int * ));

extern char *HMallocate __((
   int,
   int,
   int *,
   struct HS_window_parms * ));

extern char *HMreallocate __((
   int,
   int,
   int *,
   struct HS_window_parms *,
   char * ));

extern char *HMinit __((
   int,
   int,
   int *,
   struct HS_window_parms * ));

extern void HMfree __((
   int,
   char * ));

extern IGRint HMdispose __((
   void ));

/*---HSset_ele.c------------------------------------------------------------*/


extern void HSdump_element_parms __((
   void ));

extern void HSset_element_color __((
   unsigned int ));

extern void HSset_element_weights __((
   IGRint,
   IGRint ));

extern void HSset_element_delete_flag __((
   IGRboolean ));

extern void HSset_ele_clip_range __((
   IGRdouble * ));

extern void HSset_element_facet_type __((
   IGRint ));

extern void HSset_element_cull_flag __((
   IGRint ));

extern void HSset_element_edge_marking_flag __((
   IGRboolean ));

extern void HSset_element_tolerances __((
   IGRdouble,
   IGRdouble,
   IGRdouble ));

extern void HSset_element_geometry __((
   struct IGRbsp_surface * ));

extern void HSset_element_rendering_parms __((
   struct HS_element_rendering_parms * ));

extern void HSset_element_fem_parms __((
   IGRboolean,
   IGRdouble,
   IGRdouble,
   IGRdouble ));

/*---HSset_facet.c-----------------------------------------------------------*/


extern void HSset_facet_normal __((
   IGRdouble,
   IGRdouble,
   IGRdouble ));

extern void HSset_unscaled_facet_normal __((
   IGRdouble,
   IGRdouble,
   IGRdouble ));

extern void HSsave_and_scale_facet_normal __((
   void ));

extern void HSnormalize_facet_normal __((
   void ));

extern void HSnegate_facet_normal __((
   void ));

extern void HSset_front_facing_flag __((
   IGRboolean ));

/*---HSset_glob.c-------------------------------------------------------------*/


extern void HSdump_tiling_parms __((
   void ));

extern void HSset_window_object_info __((
   struct GRid * ));

extern IGRint HSset_shade_config __((
   IGRint,
   unsigned long,
   IGRint,
   IGRint,
   IGRint ));

extern void HSset_hardware_type __((
   IGRboolean ));

extern IGRint HSset_transparency __((
   IGRboolean ));

extern IGRint HSset_edge2_usage __((
   IGRboolean));

extern void HSset_show_hidden_mode __((
   IGRboolean ));

extern void HSset_feedback_mode __((
   IGRboolean ));

extern void HSset_feedback_full_mode __((
   IGRboolean ));

extern void HSset_dexel_mode __((
   IGRboolean ));

extern void HSset_rendering_mode __((
   IGRboolean ));

extern void HSset_processing_mode __((
   unsigned int ));

extern void HSset_clip_mode __((
   IGRboolean ));

extern void HSset_hidden_line_display_mode __((
   IGRboolean ));

extern void HSset_shaded_plot_mode __((
   IGRboolean ));

extern void HSset_maximum_z __((
   IGRdouble ));

extern void HSset_status __((
   IGRint ));

extern void HSset_paint_offset __((
   IGRint,
   IGRint ));

extern void HSset_region_update __((
   IGRboolean ));

extern void HSget_region_update __((
   IGRboolean * ));

extern void HSset_region_style __((
   IGRint ));

extern void HSset_region_original_style __((
   IGRint ));

extern void HSget_region_original_style __((
   IGRint * ));

extern void HSget_region_style __((
   IGRint * ));

extern void HSset_region_xy_minmax __((
   IGRint,
   IGRint,
   IGRint,
   IGRint ));

extern void HSget_region_xy_minmax __((
   IGRint *,
   IGRint *,
   IGRint *,
   IGRint * ));

extern void HSset_region_window_dits __((
   IGRint,
   IGRint )); 

extern void HSget_region_window_dits __((
   IGRint *,
   IGRint *));

extern void HSget_region_hardware_type __((
   IGRint *));

extern void HSset_region_hardware_type __((
   IGRint ));

extern void HSset_ambient_light_intensities __(( struct HS_light_source * ));

extern IGRint HSset_fem_ramp __(( 
   IGRint num_shades_fem,
   IGRint start_slot_fem ));

/*---HSset_win.c--------------------------------------------------------------------*/


extern void HSdump_window_parms __((
   void ));

extern void HSactivate_window __((
   IGRint ));

extern void HScalc_window_buffer_size __((
   int *,
   int *,
   int *,
   int * ));

extern void HSallocate_active_window_buffers __((
   IGRint,
   IGRint,
   IGRint ));

extern void HSset_default_active_window_functions __((
   IGRint ));

extern void HSinitialize_active_window_functions __((
   void ));

extern IGRboolean HSinit_shading_window __((
   WLuint16,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   OM_S_OBJID,
   OMuword ));

extern void HSdelete_active_window __((
   void ));

extern void HSset_active_transformation __((
   IGRdouble m1[4][4] ));

extern void HSset_active_rotation __((
   IGRdouble m1[4][4] ));

extern void HSset_active_lights __((
   struct HS_light_source * ));

extern void HSset_active_perspective_scales __((
   IGRdouble,
   IGRdouble,
   IGRdouble ));

extern void HSset_dit_clip_range __((
   IGRdouble * ));

extern void HSset_active_z_range __((
   IGRdouble,
   IGRdouble ));

extern void HSsetup_shading_window __((
   IGRdouble m1[4][4],
   IGRdouble *,
   IGRdouble *,
   IGRdouble *,
   IGRdouble *,
   IGRdouble *,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRdouble *,
   IGRdouble *,
   IGRdouble m2[4][4],
   IGRdouble m3[4][4],
   struct HS_light_source *,
   struct HS_light_source *,IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRint,
   IGRint,
   IGRint,
   IGRboolean )); 

/*---HStl_bound.c-----------------------------------------------------------*/


extern void HSdispose_bound_list __((
   struct HSbound * ));

extern void HScleanup_boundary_structures __((
   void ));

extern struct HSbound *preprocess_a_boundary __((
   struct HSbound *,
   IGRint,
   IGRdouble *,
   IGRdouble,
   IGRdouble,
   IGRboolean * ));

extern struct HSbound *sift_boundaries __((
   struct HSbound *,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble ));

extern void construct_polygons __((
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRpoint *,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRint,struct HSbound *,
   IGRboolean,
   IGRboolean,
   IGRboolean,
   IGRboolean,
   IGRboolean ));

extern void add_mesh_intersections __((
   struct HSbound *,
   IGRint,
   IGRdouble *,
   IGRint,
   IGRdouble * ));

extern IGRboolean get_horizontal_status __((
   IGRdouble,
   struct HSbound *,
   IGRboolean ));

extern IGRboolean get_vertical_status __((
   IGRdouble,
   struct HSbound *,
   IGRboolean ));

/*---HStl_clip.c----------------------------------------------------------------*/


extern struct HSvertex *clip_3d __((
   struct HSvertex *,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRint ));

extern struct HSvertex *clip_4d __((
   struct HSvertex *,
   IGRint,
   IGRdouble ));

/*---HStl_clipln.c---------------------------------------------------------------*/


extern void adjust_z __((
   IGRdouble *,
   IGRdouble ));

extern void add_to_polyline __((
   long,
   long,
   unsigned long ));

extern void clipln_3d __((
   struct HSvertex *,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble ));

extern void clipln_4d __((
   struct HSvertex *,
   IGRdouble,
   IGRdouble,
   IGRdouble ));

/*---HStl_clipshd.c--------------------------------------------------------------*/


extern void find_smooth_shades __((
   struct HSvertex *,
   IGRshort,
   double,double,
   double ));

extern void find_const_shades __((
   struct HSvertex *,
   IGRshort,
   double,
   double,
   double ));

extern void do_smooth_depth_cueing __((
   struct HSvertex *,
   IGRint ));

extern void do_const_depth_cueing __((
   struct HSvertex *,
   IGRint ));

extern void process_facet __((
   struct HSloop * ));

/*---HStl_curve.c-------------------------------------------------------------------*/


extern void HSbcurve_tiler __((
   IGRint,
   struct IGRbsp_curve *,
   IGRint,
   IGRint,
   IGRboolean,
   IGRint,
   IGRint,
   IGRdouble,
   IGRdouble * ));

extern void HSpline_tiler __((
   IGRint,
   struct IGRpolyline *,
   IGRint,
   IGRint,
   IGRboolean,
   IGRdouble * ));

/*---HStl_edge2.c-----------------------------------------------------------*/


#if defined( ENV5 )
extern void HSdelete_EG_shading_window __((
   void ));

extern void HSsetup_EG_lights __((
   struct HS_light_source *,
   struct HS_light_source * )); 


extern void HSsetup_EG_window __((
   IGRdouble m1[4][4],
   IGRdouble *,
   IGRdouble *,
   IGRdouble *,
   IGRdouble *,
   IGRdouble *,
   IGRint,
   IGRint,
   IGRboolean ));

extern int HSsend_trimesh_to_EG __((
   int vc_no,
   struct HStri_mesh *tri_mesh ));

extern void HSsend_polyline_to_EG __((
   int num_points,
   IGRpoint *points ));

extern void HSdraw_point_EG  __((
    IGRpoint ));
#endif

/*---HStl_facet.c-----------------------------------------------------------*/


extern struct HSvertex *alloc_vertex __((
   void ));

extern void dispose_vertex __((
   struct HSvertex * ));

extern void dispose_vertex_list __((
   struct HSvertex * ));

extern void dispose_facet __((
   struct HSloop * ));

extern void toss_current_facet __((
   void ));

extern void check_memory __((
   void ));

extern void add_vertex_to_loop __((
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRboolean,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble ));

extern void add_fem_vertex_to_loop __((
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRshort,
   IGRboolean ));

extern void add_fem_vertexII __((
   struct fem_vert,
   float,
   float,
   float ));

extern void end_facet_loop __((
   void ));

extern void construct_facet __((
   IGRpoint *,
   IGRint,
   IGRint,
   IGRboolean,
   IGRdouble,
   IGRdouble ));

extern void construct_fem_facet __((
   IGRpoint *,
   IGRint,
   IGRdouble,
   IGRdouble,
   IGRshort,
   IGRboolean,
   IGRint ));

extern void HScreate_fem_facetII __((
   struct fem_vert *,
   struct fem_color *,
   IGRboolean ));

extern void HSset_pvhl_z __((
   int ));

extern void clip_and_shade __((
   void ));

/*---HStl_gpipe.c-------------------------------------------------------------------------*/


extern void HSdelete_GPIPE_shading_window __((
   void ));

extern void HSsetup_GPIPE_lights __((
   struct HS_light_source * ));

extern void HSsetGPmatrix __((
   IGRdouble m1[4][4] ));

extern void HSsetup_GPIPE_window __((
   IGRdouble *,
   IGRdouble m1[4][4],
   IGRdouble * ));

extern void HSdraw_point_FPE __((
   struct polyline_vertex *));

extern void HSpaint_screen_FPE __((
   void ));

/*---HStl_light.c-------------------------------------------------------------------------*/


extern void HSalign_view_lights_to_world __((
   struct HS_light_source *,
   struct HS_light_source * ));

extern void HSsetup_window_lights __((
   struct HS_light_source *,
   struct HS_light_source * ));

/*---HStl_point.c-------------------------------------------------------------------------*/


extern void HSpoint_tiler __((
   IGRint,
   IGRint,
   IGRdouble *,
   IGRint,
   IGRint,
   IGRdouble *,
   IGRdouble *,
   int ));

/*---HStl_style.c-------------------------------------------------------------------------*/


extern int HSset_line_style __((
   int,
   int )); 

/*---HStl_surf.c--------------------------------------------------------------------------*/


extern void HSset_surf_parms __((
   IGRint,
   IGRint));

extern void HSbsurf_tiler __((
   IGRint,
   struct IGRbsp_surface *,
   IGRdouble *,
   IGRint,
   IGRint,
   IGRboolean,
   struct HS_element_rendering_parms *,
   IGRboolean,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRboolean,
   IGRint,
   IGRint,
   IGRdouble,
   IGRdouble *,
   IGRdouble *,
   IGRdouble * ));

extern void HSfem_tiler __((
   IGRint,
   struct IGRbsp_surface *,
   IGRint,
   IGRint,
   IGRdouble *,
   IGRdouble *,
   IGRdouble *,
   IGRint,
   IGRint,
   IGRdouble,
   struct IGResfct *,
   IGRdouble * ));

extern void HSfem_tilerII __((
   IGRint,
   struct HSfem_tri_mesh *,
   IGRdouble *,
   IGRint,
   IGRint,
   IGRdouble ));

extern void HSrender_tiler __((
   IGRint,
   struct IGRbsp_surface *,
   IGRdouble *,
   IGRboolean,
   IGRdouble,IGRdouble,
   IGRdouble,
   struct HS_element_rendering_parms *,
   IGRboolean,
   IGRint,
   IGRint,
   IGRdouble,
   IGRdouble *,
   IGRdouble *,
   IGRdouble * ));

extern IGRint HSget_minimum_x __((
   IGRint,
   struct IGRbsp_surface *,
   IGRdouble *,
   IGRboolean,
   IGRdouble,
   IGRdouble,
   struct HS_element_rendering_parms *,
   IGRint,
   IGRint,
   IGRdouble,
   IGRdouble *,
   IGRdouble * ));

/*---HStl_text.c--------------------------------------------------------------*/


extern void HStext_tiler __((
   IGRint,
   IGRint,
   IGRdouble *,
   IGRint,
   IGRint,
   IGRdouble * ));

/*---HStl_tol.c---------------------------------------------------------------*/


extern void add_pts_between_knots __((
   IGRshort,
   IGRlong,
   IGRdouble *,
   IGRint,
   IGRint *,
   IGRdouble ** ));

extern IGRdouble CHT __((
   IGRint,
   IGRdouble,
   IGRdouble * ));

extern void get_surf_sampling_points __((
   struct IGRbsp_surface *,
   IGRdouble,
   IGRdouble *,
   IGRdouble *,
   IGRint *,
   IGRint *,
   IGRdouble **,
   IGRdouble **,
   int,
   IGRdouble ));

extern void get_curve_sampling_points __((
   struct IGRbsp_curve *,
   IGRdouble,
   IGRint *,
   IGRdouble ** ));

/*---HStl_util.c--------------------------------------------------------------*/

extern IGRboolean front_facing_facet __((
   IGRint,
   IGRdouble * ));

extern IGRboolean HScan_cull_facet __((
   IGRboolean,
   IGRdouble * ));

extern void HScalc_world_view_vector __((
   IGRdouble m1[4][4],
   IGRboolean,
   IGRdouble * ));

extern void HSget_z_span_of_range __((
   IGRdouble *,
   IGRdouble *,
   IGRdouble * ));

extern void HScalc_window_z_range __((
   IGRdouble *,
   IGRdouble *,
   IGRdouble * ));

extern IGRboolean HSoutside_z_range __((
   IGRboolean,
   IGRdouble,
   IGRdouble *));
 
/*---HStl_xform.c----------------------------------------------------------*/


extern void HSreset_plotting_xrange __((
   void ));

extern void HSfetch_plotting_xrange __((
   int *,
   int * ));

extern void transform_points __((
   IGRint,
   IGRint,
   IGRdouble *,
   IGRint ));

extern void HSfem_transform __((
   struct HSfem_tri_mesh * ));

extern void rotate_normals __((
   IGRint,
   IGRdouble * )); 

extern void HSUnRotateVectors __((
   int,
   double * ));

extern void scale_facet_point __((
   IGRdouble * ));

extern void perspective_projection __((
   struct HSvertex * ));

extern void HSconvert_transformation_matrix __((
   IGRdouble m1[4][4],
    IGRdouble m2[4][4] ));

extern void HSconvert_rotation_matrix __((
   IGRdouble m1[4][4],
   IGRdouble m2[4][4] ));
 

#if defined(__cplusplus)
}
#endif


#undef __
