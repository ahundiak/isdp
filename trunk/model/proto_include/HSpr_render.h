/*
 * HSpr_render_.h: The prototype file for the 
 * hsurf/src/render_imp directory
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

/*---HRclassify.I-----------------------------------------------------*/

extern void HRget_components          __(( struct GRid *, IGRint *, struct GRid ** ));
extern void HRclassify_located_object __(( struct GRid *, IGRmatrix, IGRshort, IGRint *, IGRboolean ));

/*---HRcollect.C------------------------------------------------------*/

extern void HRcollect_elements __(( struct GRid *, OM_S_CHANSELECT *, struct HRbucket_info *, IGRint *master_layers ));

/*---HRcolor_rgb.c----------------------------------------------------*/

extern void HRinit_rgb   __(( int, int, int, int ));
extern void HRfinish_rgb __(( int, int ));
extern int HRindex_rgb   __(( int, int, int, int, int )); 

/*---HRdisplay.c------------------------------------------------------*/

extern void HRadd_in_background    __(( IGRint, IGRint, IGRuint, IGRuint, IGRuint )); 
extern void HRstart_scanline       __(( void ));
extern void HRstop_scanline        __(( int, int ));
extern void HRprocess_span         __(( IGRint, IGRint, IGRint, IGRdouble, IGRdouble, IGRdouble, IGRdouble, HRuv, HRuv, HRuv, HRuv, HRuv, HRuv, IGRint, IGRint, IGRint, IGRint, IGRint, IGRint, struct HRspecial_rendering_parms *, IGRuint, IGRuint, IGRuint, IGRboolean )); 
extern void HRinit_display_parms   __(( IGRint, IGRint * )); 
extern void HRfree_display_parms   __(( void ));
extern void HRset_rendering_lights __(( struct HS_light_source * ));

/*---HRget_env.c---------------------------------------------------------*/

extern struct HRenv_record *HRget_environment_info __(( IGRint, IGRmatrix, IGRshort, IGRint * ));
 
/*---HRget_geom.I--------------------------------------------------------*/

extern void HRget_surface_geometry  __(( struct HRsurface_record *, struct IGRbsp_surface **, IGRdouble *, IGRdouble ));
extern void HRfree_surface_geometry __(( struct IGRbsp_surface * ));

/*---HRget_range.c-------------------------------------------------------*/

extern void HRget_dit_range __(( IGRint, IGRdouble *, IGRdouble *, IGRdouble * ));

/*---HRmake_rle.c--------------------------------------------------------*/

extern void HRwrite_line_in_rle27 __(( int, int, unsigned short *, unsigned short *, unsigned short * )); 
extern int HRinit_rle             __(( int, int, char * )); 
extern int HRfini_rle             __(( int, int, int )); 

/*---HRmake_spans.c------------------------------------------------------*/

extern void HRprocess_scanline    __(( int, int ));
extern void HRactivate_trapezoids __(( struct HRspan_trapezoid * ));

/*---HRmem_man.c---------------------------------------------------------*/

extern void HRsave_pool_address                        __(( IGRchar *, IGRint ));
extern void HRinit_pool_memory_management              __(( void ));
extern void HRfree_pool_memory                         __(( void ));
extern struct HRenv_record *HRalloc_env_record         __(( void ));
extern struct HRsurface_record *HRalloc_surface_record __(( void ));
extern struct HRspan_trapezoid *HRalloc_span_trap      __(( void ));
extern struct HRspan_deltas *HRalloc_span_deltas       __(( void ));
extern struct HRtrapezoid_uv *HRalloc_trapezoid_uv     __(( void ));
extern struct HRtexture_list *HRalloc_texture_list     __(( void ));
extern struct HRspan_intersect *HRalloc_span_intersect __(( void ));
extern void HRfree_env_record                          __(( struct HRenv_record * ));
extern void HRfree_surface_record                      __(( struct HRsurface_record * ));
extern void HRfree_span_trap                           __(( struct HRspan_trapezoid * ));
extern void HRfree_span_deltas                         __(( struct HRspan_deltas * ));
extern void HRfree_trapezoid_uv                        __(( struct HRtrapezoid_uv * ));
extern void HRfree_texture_interp_parms                __(( struct HRtexture_interp_parms * ));
extern void HRfree_texture_list                        __(( struct HRtexture_list * ));
extern void HRfree_span_intersect                      __(( struct HRspan_intersect * ));

extern struct HRtexture_interp_parms *HRalloc_texture_interp_parms __(( void ));

/*---HRmipmap.c--------------------------------------------------------------*/

extern void MMinit_texture_memory __(( void ));
extern void MMfree_texture_memory __(( void ));
extern void MMdisplay_mipmap      __(( unsigned char * ));
extern void HRopen_texture_file   __(( char *, int *, char * ));
extern void MMload                __(( struct HRtexture_list * ));

/*---HRpower.c----------------------------------------------------------------*/

extern int HRpower __(( int , int ));

/*---HRreclaim.c--------------------------------------------------------------*/

extern void HRreclaim_trapezoids __(( void ));

/*---HRrender.C---------------------------------------------------------------*/

extern void HRrender_image __(( IGRlong *, struct GRid *, OM_S_CHANSELECT *, IGRchar *, IGRint, IGRint, IGRint, IGRint, IGRint, IGRboolean, struct GRid * )); 

/*---HRrender_win.C------------------------------------------------------------*/

extern void HRinit_rendering_window   __(( WLuint32 *, WLuint32 *, int *, int *, int )); 
extern void HRdelete_rendering_window __(( WLuint32, int ));

/*---HRsort.c------------------------------------------------------------------*/

extern void HRbucket_sort_surface   __(( struct HRsurface_record *, IGRint ));
extern void HRbucket_sort_trapezoid __(( struct HRspan_trapezoid *, IGRint ));

/*---HRtexturize.c-------------------------------------------------------------*/

extern int HRget_RGB __(( HRuv, HRuv, float, unsigned int *, unsigned int *, unsigned int *, struct HRtexture_list * ));

#if defined(__cplusplus)
}
#endif


#undef __
