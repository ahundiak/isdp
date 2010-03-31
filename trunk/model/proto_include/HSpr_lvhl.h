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

/*---HSclassify.I---------------------------------------------------------------*/

extern void HSpvhl_init_xhatch_object_node_pool        __(( void ));
extern struct xhatch_node_info *HSpvhl_get_xhatch_node __(( void ));
extern struct object_node_info *HSpvhl_get_object_node __(( void ));
extern void HSpvhl_set_object_level                    __(( struct GRid *, IGRint )); 
extern void HSpvhl_get_objects_of_type_on_channel      __(( GRobjid, GRspacenum, char *, OMuword, struct GRid **, IGRint *)); 
extern IGRint HSpvhl_match_first_object_on_channel     __(( GRobjid, GRspacenum, char *, GRobjid, GRspacenum )); 
extern IGRint HSget_object_level                       __(( struct GRid *));
extern void HSpvhl_build_xhatch_node                   __(( struct GRobj_env *, struct xhatch_node_info **)); 
extern void HSget_components                           __(( struct GRid *, struct GRmd_env *, IGRint *, struct GRid **));
extern void HSclassify_located_object                  __(( struct GRid *, struct GRmd_env *, IGRmatrix, IGRshort *, struct GRid *, IGRint,IGRint (*)(IGRshort, IGRboolean), void (*)(),void (*)(), void (*)( OM_S_OBJID, OMuword, IGRdouble *, IGRshort, struct GRmd_env *), IGRchar *, IGRboolean *));

/*---HSlv_allocat.c----------------------------------------------------------*/

extern int HSlvhl_allocate_zbuffer_memory __(( int, int *, int *, int *, int *, int, int *, int *));
extern void HSlvhl_free_zbuffer_memory    __(( int ));

/*---HSlv_collect.C-----------------------------------------------------------*/

extern IGRboolean HSlvhl_collect_elements         __((  struct GRid *, struct GRid *, OM_S_CHANSELECT *, unsigned char, IGRboolean, IGRboolean, IGRboolean, IGRboolean, IGRboolean, IGRboolean, unsigned short, unsigned short, unsigned short, IGRboolean, IGRboolean, IGRboolean, unsigned char)); 
extern IGRboolean HSare_there_read_only_ref_files __((  struct GRid *, OM_S_CHANSELECT *));

/*---HSlv_cptext.I------------------------------------------------------------*/

extern void HSlvhl_copy_text __(( OM_S_OBJID, OMuword, IGRdouble *, IGRshort, struct GRmd_env *)); 

/*---HSlv_display.I------------------------------------------------------------*/

extern IGRboolean HSlvhl_init_display_object __(( struct GRid *, unsigned char, IGRboolean)); 
extern void HSlvhl_fini_display_object       __(( void ));
extern void HSlvhl_dump_the_soos             __(( void ));
extern IGRboolean HSremove_VEso_on_edge      __(( GRobjid, GRspacenum, GRobjid, GRspacenum, struct GRmd_env *, struct GRmd_env *, double, double, IGRboolean, IGRboolean)); 
extern void HSget_manual_soos_on_edge        __(( GRobjid, GRspacenum, IGRmatrix, IGRshort *, struct GRmd_env *, struct IGRdisplay *)); 
extern void HSdump_soos_on_edge              __(( GRobjid, GRspacenum, IGRmatrix, IGRshort *, struct GRmd_env *, struct IGRdisplay *)); 
extern void HSlvhl_display_surface           __(( struct GRid *, IGRshort *, IGRmatrix, struct GRmd_env *, IGRint, struct HSplot_info *)); 
extern void HSlvhl_display_curve             __(( struct GRid *, IGRshort *, IGRmatrix, struct GRmd_env *, struct HSplot_info *));
 
/*---HSlv_timing.C----------------------------------------------------------------*/

extern void HSlvhl_display_timing __(( long ));
extern void HSlvhl_init_timing    __(( void ));
extern void HSlvhl_update_timing  __(( void ));
extern void HSlvhl_fini_timing    __(( void ));

/*---HSlv_window.c----------------------------------------------------------------*/

extern int HSlvhl_init_window __(( int, int, struct DPgra_gad *, int, int)); 

/*---HSlvhl_scrv.c----------------------------------------------------------------*/

extern void HSlvhl_init_curve_pool    __(( void ));
extern void HSlvhl_add_curve_to_pool  __(( int ));
extern void HSlvhl_reset_curve_pool   __(( void ));
extern int HSlvhl_get_curve_from_pool __(( void ));

/*---HSlvhl_util.I-----------------------------------------------------------------*/

extern void HSlvhl_set_active_z               __(( double ));
extern IGRboolean HSis_os_read_only           __(( OMuword ));
extern void HSget_temp_curve_storage          __(( struct IGRbsp_curve *, struct IGRbsp_curve *));
extern void HSlvhl_split_and_tile_curve       __(( IGRint *, struct IGRbsp_curve *, double, double, int, int, int, int, int, double, double *)); 
extern void HSlvhl_create_curve               __(( struct IGRbsp_curve *, double, double, unsigned short, unsigned char, unsigned char, short)); 
extern char intersect                         __(( double, double , double *));
extern void HSget_model_space_counterpart     __(( IGRboolean, OM_S_OBJID, OMuword, struct GRmdenv_info *, GRobjid *));
extern void HSlvhl_output_soo_span            __(( struct IGRbsp_curve *, double, double, int));
extern void HSlvhl_output_curve_span          __(( struct IGRbsp_curve *, double, double, int));
extern void HSlvhl_add_curves_to_rtree        __(( void ));
extern void HSlvhl_init_os_info               __(( void ));
extern void HSlvhl_free_os_info               __(( void ));
extern void HSlvhl_create_soos_for_os         __(( void ));
extern IGRint HSlvhl_build_os_info_list       __(( IGRshort, IGRboolean ));
extern void HSget_num_activated_completed     __(( IGRint *, IGRint *)); 
extern void HSinit_activated_completed        __(( void ));
extern void HSupdate_activated_completed      __(( void ));
extern IGRint HSget_curve_geometry_from_pline __(( GRobjid, GRspacenum, struct GRmdenv_info *, struct IGRbsp_curve **));

#if defined(__cplusplus)
}
#endif


#undef __
