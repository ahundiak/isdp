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

#include "igrtypedef.h"
#include "igewindow.h"


/* HSckzrange.c */


extern int HSdebug_range_test_init    __((
   void ));

extern int HSdebug_range_test_info    __((
   void ));

extern int HScheck_range_with_zbuffer __((
   struct IGRbsp_surface *,
   IGRdouble *));


/* HSdriver.c */


extern void HSreset_transformation_matrix __((
   IGRint,
   IGRdouble m1[4][4],
   IGRdouble m2[4][4],
   IGRdouble m3[4][4],
   
                                               IGRdouble m4[4][4],
   IGRdouble *,
   IGRdouble *,
   IGRdouble *,
   IGRdouble *,
   
                                               IGRdouble *,
   IGRint x_dits,
   IGRint y_dits));


extern void HSrepaint_shading_window      __((
   IGRint,
   struct IGEdit_range * ));


extern void HSshade_object                __((
   IGRint,
   IGRint,
   IGRint,
   char *,
   char *,
   IGRdouble *,
   IGRdouble *,
   
                                               IGRdouble *,
   IGRdouble *,
   IGRint,
   IGRint,
   IGRdouble,
   IGRdouble,
   
                                               IGRdouble,
   IGRint,
   IGRint,
   IGRboolean,
   IGRboolean,
   IGRboolean,
   
                                               IGRdouble *,
   IGRint,
   struct HS_element_rendering_parms *,
   IGRint *));


/* HSgetedges.I */


extern struct IGRbsp_curve *HSconstruct_iso_edge __((
   struct IGRbsp_surface *,
   IGRint,
   IGRdouble));

extern void HSgenerate_natural_edges             __((
   IGRint *,
   struct IGRbsp_surface *,
   struct GRmdenv_info *,
   
                                                      int,
   int,
   int,
   int,
   int,
   double,
   double *));

extern void HSget_curve_clip_memory              __((
   IGRint,
   IGRdouble **,
   IGRdouble **,
   IGRdouble **,
   IGRdouble **));

extern void HSclip_and_remove_SOs                __((
   struct IGRbsp_curve *,
   GRobjid,
   GRspacenum,
   struct GRmd_env *,
   struct GRmd_env *));

extern void HScreate_sharp_edges                 __((
   IGRint *,
   struct IGRbsp_surface *,
   GRobjid,
   GRspacenum,
   int,
   int,
   
                                                      int,
   int,
   int,
   double,
   double *));

extern int HSget_surface_edges                   __((
   IGRint *,
   GRobjid,
   GRspacenum,
   struct IGRbsp_surface *,
   
                                                      struct GRmdenv_info *,
   int,
   int,
   int,
   int,
   int,
   double,
   
                                                      double *,
   IGRdouble m1[4][4],
   IGRint,
   IGRboolean,
   IGRdouble *));


/* HStildriver.C */


extern IGRboolean HSinit_display   __((
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   struct DPgra_gad *,
   IGRuchar,
   IGRuchar,
   IGRdouble m1[4][4]));

extern void HSdelete               __((
   IGRint ));

extern void HSget_window_based_cht __((
   IGRdouble *,
   IGRint,
   IGRdouble,
   IGRdouble *));

extern void HScheck_status         __((
   void ));

extern void HStile_object          __((
   struct DPele_header *,
   enum GRdpmode *,
   IGRint,
   struct IGRdisplay *,
   struct DPgra_gad *));

extern void HSrender_object        __((
   struct IGRbsp_surface *,
   IGRint,
   IGRint,
   IGRdouble *,
   IGRdouble *,
   struct HS_element_rendering_parms *,
   IGRint,
   IGRboolean,
   IGRint *,
   IGRboolean));

/* HStilopt.I */


extern void HSget_bounded_uv_range __((
   OM_S_OBJID,
   OMuword,
   struct IGRbsp_surface *,
   IGRdouble *,
   IGRdouble *));

extern void HSget_dpb_data         __((
   IGRint,
   IGRint,
   IGRint *,
   IGRint *,
   IGRint *,
   IGRint *,
   IGRint *,
   IGRint *,
   IGRint *,
   IGRdouble *,
   IGRdouble *,
   IGRdouble *));

extern IGRboolean HSfrom_solid     __((
   OM_S_OBJID,
   OMuword ));

extern IGRboolean HSget_top_range  __((
   IGRdouble *));

extern IGRdouble HSget_pt_basis    __((
   OM_S_OBJID,
   OMuword ));

extern IGRint HSget_rgb_value      __((
   IGRint ));

extern IGRint HSsetup_fem_simulated_ramp __((
   void));

extern int HSlogical_color_to_physical_slot __((
   IGRint log_color,
   WLuint32 context_no ));

/* HStl_dexel.C */


extern void HSsetup_nc_window         __((
   IGRint,
   IGRdouble *));

extern void HSget_dexel_facet_parms   __((
   IGRint *,
   IGRint *,
   IGRboolean *));

extern void HSset_dexel_color         __((
   IGRboolean,
   IGRint,
   IGRint *));

extern void HSset_dexel_shading_style __((
   unsigned int ));

extern void HSadjust_dexels           __((
   IGRint *,
   IGRint,
   IGRint,
   IGRint,
   IGRint));

extern void HSdisable_dexels          __((
   void ));

extern void HSadd_dexel_vertex        __((
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRdouble)); 

extern IGRboolean HScheck_dexel_memory __((
   IGRint ));

extern void HSrestore_dexel_memory    __((
   IGRint ));

/* HStl_feedbck.C */


extern void HSdump_fb_buffer        __((
   IGRint *));

extern void HSsave_surface          __((
   IGRint,
   IGRint,
   IGRint,
   IGRdouble *));

extern int  HSsave_TriMesh          __((
   int,
   struct HStri_mesh *));

extern void HSsave_trimesh_polyline  __((
   IGRint,
   IGRpoint *));
#if defined( ENV5 )

extern void HSdump_edgeII_fb_buffer __((
   IGRint *));

extern void HSdisplay_fb_EDGEII     __((
   IGRint *,
   IGRint,
   IGRdouble m1[4][4],
   IGRdouble *,
   IGRdouble m2[4][4],
   IGRdouble m3[4][4],
   struct HS_light_source *,
   struct HS_light_source *,
   IGRdouble *,
   IGRdouble *,
   IGRdouble *,
   IGRdouble *));

extern int  HSdisplay_fb_FPE        __((
   IGRint *,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   IGRdouble m1[4][4],
   IGRdouble *,IGRdouble *,IGRint ));
#endif

extern void HSsave_facet            __((
   struct HSloop *));

extern void HSdisplay_fb_NOFPE      __((
   IGRint *,
   IGRint,
   IGRdouble m1[4][4],
   IGRdouble m2[4][4],
   IGRdouble *,
   IGRint,
   IGRint,
   IGRint,
   IGRint,
   struct HS_light_source *,
   struct HS_light_source *,
   IGRdouble *,
   IGRdouble *,
   IGRdouble,
   IGRdouble,
   IGRdouble,
   IGRboolean *,
   IGRint));

extern void HSenable_feedback       __((
   IGRint,
   IGRint,
   IGRint,
   IGRdouble,
   IGRint ));

extern void HSdisable_feedback      __((
   void ));


extern IGRint HSsetinq_db_allowed_flag __((
   IGRint,
   IGRint ));

#if defined(__cplusplus)
}
#endif


#undef __
