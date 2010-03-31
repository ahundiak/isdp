
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsmacros_include
#define hsmacros_include 1

/***
	This file contains the macros used to get/set HSURF global data.
	
	Dependencies:

	    hsdef.h
	    hsmacdef.h
***/


/*--- hs$change_device_colors -----------------------------------------------*/

/*
	This macro changes the device colors in the HSctbl object for a 
	given number of planes.
	   
	Parameters:
	   
	   num_planes - IGRshort
	   num_colors - IGRshort
	   num_shades - IGRshort
	   mod_id     - OM_S_OBJID
	   mod_osnum  - OMuword

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef hs$change_device_colors( num_planes,
	                        num_colors,
	                        num_shades,
	                        mod_id = NULL_OBJID,
	                        mod_osnum = OM_Gw_current_OS )
					
	HSchange_device_colors( num_planes, num_colors, num_shades, mod_id, mod_osnum )
	
#endomdef


/*--- hs$change_user_colors -----------------------------------------------*/

/*
	This macro changes the user colors in the HSctbl object.
	   
	Parameters:
	   
	   num_colors - IGRshort
	   num_shades - IGRshort
	   mod_id     - OM_S_OBJID
	   mod_osnum  - OMuword

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef hs$change_user_colors( num_colors,
	                      num_shades,
	                      mod_id = NULL_OBJID,
	                      mod_osnum = OM_Gw_current_OS )

	HSchange_user_colors( num_colors, num_shades, mod_id, mod_osnum )
	
#endomdef

/*--- hs$read_device_colors -----------------------------------------------*/

/*
	This macro reads the device colors in the HSctbl object for a
	given number of planes.
	   
	Parameters:
	   
	   num_planes  - IGRshort
	   *num_colors - IGRshort
	   *num_shades - IGRshort
	   mod_id      - OM_S_OBJID
	   mod_osnum   - OMuword

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef hs$read_device_colors( num_planes,
	                      num_colors,
	                      num_shades,
	                      mod_id = NULL_OBJID,
	                      mod_osnum = OM_Gw_current_OS )
					
	HSread_device_colors( num_planes, num_colors, num_shades, mod_id, mod_osnum )
	
#endomdef


/*--- hs$get_fem_style ----------------------------------------------------*/

/*
	This macro returns the shading style for FEM contour tiles.
	   
	Parameters:
	   
	   *fem_style - IGRint - defined in hsdef.h
*/

#omdef hs$get_fem_style( fem_style )

	HSget_fem_style( fem_style )
	
#endomdef


/*--- hs$set_fem_style ----------------------------------------------------*/

/*
	This macro changes the shading style for FEM contour tiles.
	   
	Parameters:
	   
	   fem_style - IGRint - defined in hsdef.h

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE (fem_style out of range)
*/

#omdef hs$set_fem_style( fem_style )

	HSset_fem_style( fem_style )
	
#endomdef

/*--- hs$get_fem_mesh -----------------------------------------------------*/

/*
	This macro returns the mesh mode for FEM contour tiles.
	   
	Parameters:
	   
	   *fem_mesh - IGRboolean
*/

#omdef hs$get_fem_mesh( fem_mesh )

	HSget_fem_mesh( fem_mesh )
	
#endomdef


/*--- hs$set_fem_mesh -----------------------------------------------------*/

/*
	This macro changes the mesh mode for FEM contour tiles.
	   
	Parameters:
	   
	   fem_mesh - IGRint

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE (fem_mesh out of range)
*/

#omdef hs$set_fem_mesh( fem_mesh )

	HSset_fem_mesh( fem_mesh )
	
#endomdef

/*--- hs$get_shading_tolerance --------------------------------------------*/

/*
	This macro returns the global shading tolerance.
	   
	Parameters:
	   
	   *tolerance - IGRdouble

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef hs$get_shading_tolerance( tolerance )

	HSdpb_get_shading_tolerance( tolerance )
	
#endomdef


/*--- hs$put_shading_tolerance --------------------------------------------*/

/*
	This macro changes the global shading tolerance.
	   
	Parameters:
	   
	   tolerance - IGRdouble

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef hs$put_shading_tolerance( tolerance )

	HSdpb_put_shading_tolerance( tolerance )
	
#endomdef

/*--- hs$get_shading_accuracy --------------------------------------------*/

/*
	This macro returns the global shading accuracy.
	   
	Parameters:
	   
	   *accuracy - IGRint

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef hs$get_shading_accuracy( accuracy )

	HSdpb_get_shading_accuracy( accuracy )
	
#endomdef


/*--- hs$set_shading_accuracy --------------------------------------------*/

/*
	This macro changes the global shading accuracy.
	   
	Parameters:
	   
	   accuracy - IGRint

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef hs$set_shading_accuracy( accuracy )

	HSdpb_set_shading_accuracy( accuracy )
	
#endomdef

/*--- hs$get_shading_flags ------------------------------------------------*/

/*
	This macro returns the shading flags.
	   
	Parameters:
	   
	   *shading_flags    - IGRuint - NULL, if not desired 
	   *rendering_flags  - IGRuint - NULL, if not desired
	   *save_image_flags - IGRuint - NULL, if not desired
	   *vhl_flags        - IGRuint - NULL, if not desired
	   *rend_attr_flags  - IGRuint - NULL, if not desired

	   See hsdef.h for the bit use of each flags word

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef hs$get_shading_flags( shading_flags = NULL,
	                     rendering_flags = NULL,
	                     save_image_flags = NULL,
	                     vhl_flags = NULL,
	                     rend_attr_flags = NULL )

	HSdpb_get_shading_flags( shading_flags, rendering_flags,
	                         save_image_flags, vhl_flags, rend_attr_flags )
	
#endomdef


/*--- hs$put_shading_flags ------------------------------------------------*/

/*
	This macro changes the shading flags.
	   
	Parameters:
	   
	   *shading_flags    - IGRuint - NULL, if not to be set
	   *rendering_flags  - IGRuint - NULL, if not to be set
	   *save_image_flags - IGRuint - NULL, if not to be set
	   *vhl_flags        - IGRuint - NULL, if not to be set
	   *rend_attr_flags  - IGRuint - NULL, if not to be set

	   See hsdef.h for the bit use of each flags word

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef hs$put_shading_flags( shading_flags = NULL,
	                     rendering_flags = NULL,
	                     save_image_flags = NULL,
	                     vhl_flags = NULL,
	                     rend_attr_flags = NULL )

	HSdpb_put_shading_flags( shading_flags, rendering_flags,
	                         save_image_flags, vhl_flags, rend_attr_flags )
	
#endomdef

/*--- hs$get_element_shading_symb --------------------------------------------*/

/*
	This macro gets the shading symbology of an element	   

	Parameters:
	   
	   objid               - OM_S_OBJID
	   osnum               - OMuword
	   *style              - IGRint            - NULL, if not desired
	   *finish             - IGRint            - NULL, if not desired
	   *diff_refl          - IGRdouble         - NULL, if not desired
	   *spec_refl          - IGRdouble         - NULL, if not desired
	   *transparency       - IGRdouble         - NULL, if not desired
	   *tex_orient         - IGRuchar          - NULL, if not desired
	   *tex_index          - IGRushort         - NULL, if not desired
	   *red                - IGRuchar          - NULL, if not desired
	   *green              - IGRuchar          - NULL, if not desired
	   *blue               - IGRuchar          - NULL, if not desired
	   *app_entry          - unsigned char     - NULL, if not desired
*/

#omdef hs$get_element_shading_symb( objid,
	                            osnum,
	                            style = NULL,
	                            finish = NULL,
	                            diff_refl = NULL,
	                            spec_refl = NULL,
	                            transparency = NULL,
	                            tex_orient = NULL,
	                            tex_index = NULL,
	                            red = NULL,
	                            green = NULL,
	                            blue = NULL,
                                    app_entry = NULL )

	HSget_element_shading_symb( objid, osnum, style, finish, diff_refl, spec_refl, transparency,
	                            tex_orient, tex_index, red, green, blue, app_entry); 
	
#endomdef


/*--- hs$set_element_shading_symb --------------------------------------------*/

/*
	This macro sets the shading symbology of an element	   

	Parameters:
	   
	   objid               - OM_S_OBJID
	   osnum               - OMuword
	   *style              - IGRint            - NULL, if not to be set
	   *finish             - IGRint            - NULL, if not to be set
	   *diff_refl          - IGRdouble         - NULL, if not to be set
	   *spec_refl          - IGRdouble         - NULL, if not to be set
	   *transparency       - IGRdouble         - NULL, if not to be set
	   *tex_orient         - IGRuchar          - NULL, if not to be set
	   *tex_index          - IGRushort         - NULL, if not to be set
	   *red                - IGRuchar          - NULL, if not to be set
	   *green              - IGRuchar          - NULL, if not to be set
	   *blue               - IGRuchar          - NULL, if not to be set
	   *app_entry          - unsigned char     - NULL, if not desired
*/

#omdef hs$set_element_shading_symb( objid,
	                            osnum,
	                            style = NULL,
	                            finish = NULL,
	                            diff_refl = NULL,
	                            spec_refl = NULL,
	                            transparency = NULL,
	                            tex_orient = NULL,
	                            tex_index = NULL,
	                            red = NULL,
	                            green = NULL,
	                            blue = NULL,
	                            refraction = NULL,
	                            pattern_x_offset = NULL,
	                            pattern_y_offset = NULL,
	                            pattern_rot_angle = NULL,
	                            pattern_scale = NULL,
	                            special_rend_flags = NULL,
                                    app_entry = NULL )

	HSset_element_shading_symb( objid, osnum, style, finish, diff_refl, spec_refl, transparency,
	                            tex_orient, tex_index, red, green, blue, app_entry);
	
#endomdef

/*--- hs$get_active_shading_symb --------------------------------------------*/

/*
	This macro gets the active shading symbology

	Parameters:
	   
	   *style              - IGRint            - NULL, if not desired
	   *finish             - IGRint            - NULL, if not desired
	   *diff_refl          - IGRdouble         - NULL, if not desired
	   *spec_refl          - IGRdouble         - NULL, if not desired
	   *transparency       - IGRdouble         - NULL, if not desired
	   *tex_orient         - IGRuchar          - NULL, if not desired
	   *tex_index          - IGRushort         - NULL, if not desired
	   *red                - IGRuchar          - NULL, if not desired
	   *green              - IGRuchar          - NULL, if not desired
	   *blue               - IGRuchar          - NULL, if not desired
	   *app_entry          - unsigned char     - NULL, if not desired
*/

#omdef hs$get_active_shading_symb( style = NULL,
	                           finish = NULL,
	                           diff_refl = NULL,
	                           spec_refl = NULL,
	                           transparency = NULL,
	                           tex_orient = NULL,
	                           tex_index = NULL,
	                           red = NULL,
	                           green = NULL,
	                           blue = NULL,
                                   app_entry  = NULL )

	HSget_active_shading_symb( style, finish, diff_refl, spec_refl, transparency,
	                           tex_orient, tex_index, red, green, blue, app_entry );
	
#endomdef



/*--- hs$set_active_shading_symb --------------------------------------------*/

/*
	This macro sets the active shading symbology

	Parameters:
	   
	   *style              - IGRint            - NULL, if not to be set
	   *finish             - IGRint            - NULL, if not to be set
	   *diff_refl          - IGRdouble         - NULL, if not to be set
	   *spec_refl          - IGRdouble         - NULL, if not to be set
	   *transparency       - IGRdouble         - NULL, if not to be set
	   *tex_orient         - IGRuchar          - NULL, if not to be set
	   *tex_index          - IGRushort         - NULL, if not to be set
	   *red                - IGRuchar          - NULL, if not to be set
	   *green              - IGRuchar          - NULL, if not to be set
	   *blue               - IGRuchar          - NULL, if not to be set
	   *app_entry          - unsigned char     - NULL, if not desired
*/

#omdef hs$set_active_shading_symb( style = NULL,
	                           finish = NULL,
	                           diff_refl = NULL,
	                           spec_refl = NULL,
	                           transparency = NULL,
	                           tex_orient = NULL,
	                           tex_index = NULL,
	                           red = NULL,
	                           green = NULL,
	                           blue = NULL,
                                   app_entry  = NULL )

	HSset_active_shading_symb( style, finish, diff_refl, spec_refl, transparency,
	                           tex_orient, tex_index, red, green, blue, app_entry);
	
#endomdef


/*--- hs$get_global_lights --------------------------------------------*/

/*
	This macro gets the global light sources

	Parameters:
	   
	   lights[8]      - struct HS_light_source    - NULL, if not desired
	   *ambient_light - struct HS_light_source    - NULL, if not desired
*/

#omdef hs$get_global_lights( lights = NULL,
	                     ambient_light = NULL )
					
	HSget_global_lights( lights, ambient_light );
	
#endomdef


/*--- hs$set_global_lights --------------------------------------------*/

/*
	This macro sets the global light sources

	Parameters:

	   lights[8]      - struct HS_light_source  - NULL, if not to be set
	   *ambient_light - struct HS_light_source  - NULL, if not to be set
*/

#omdef hs$set_global_lights( lights = NULL,
	                     ambient_light = NULL )
					
	HSset_global_lights( lights, ambient_light );
	
#endomdef

/*--- hs$get_symbology_modes --------------------------------------------*/

/*
	This macro gets the symbology modes

	Parameters:
	   
	   *style_mode   - IGRint   - NULL, if not desired
	   *finish_mode  - IGRint   - NULL, if not desired
	   *reflect_mode - IGRint   - NULL, if not desired
	   *trans_mode   - IGRint   - NULL, if not desired
*/

#omdef hs$get_symbology_modes(  style_mode = NULL,
	                        finish_mode = NULL,
	                        reflect_mode = NULL,
	                        trans_mode = NULL )
					
	HSget_symbology_modes( style_mode, finish_mode, reflect_mode, trans_mode );
	
#endomdef



/*--- hs$set_symbology_modes --------------------------------------------*/

/*
	This macro sets the symbology modes

	Parameters:
	   
	   *style_mode   - IGRint   - NULL, if not to be set
	   *finish_mode  - IGRint   - NULL, if not to be set
	   *reflect_mode - IGRint   - NULL, if not to be set
	   *trans_mode   - IGRint   - NULL, if not to be set
*/

#omdef hs$set_symbology_modes(  style_mode = NULL,
	                        finish_mode = NULL,
	                        reflect_mode = NULL,
	                        trans_mode = NULL )
					
	HSset_symbology_modes( style_mode, finish_mode, reflect_mode, trans_mode );

#endomdef

/*--- hs$get_rhl_info ----------------------------------------------------*/

/*
	This macro gets the raster hidden line information
	
	Parameters:
	
	  *show_hidden - IGRint      - NULL, if not desired
*/

#omdef hs$get_rhl_info( show_hidden = NULL )
	                   
	HSget_rhl_info( show_hidden );
	
#endomdef


/*--- hs$set_rhl_info ----------------------------------------------------*/

/*
	This macro sets the raster hidden line information
	
	Parameters:
	
	  *show_hidden - IGRint    - NULL, if not to be set

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE
*/

#omdef hs$set_rhl_info( show_hidden = NULL )
	                   
	HSset_rhl_info( show_hidden );
	
#endomdef

/*--- hs$get_trans_grid ----------------------------------------------------------*/

/*
	This macro gets the translucency grid
	
	Parameters:
	
	   *trans_grid - IGRint

	   See hsmacdef.h for defines.
*/

#omdef hs$get_trans_grid( trans_grid )

	HSget_trans_grid( trans_grid )
	
#endomdef


/*--- hs$set_trans_grid ----------------------------------------------------------*/

/*
	This macro sets the translucency grid
	
	Parameters:
	
	   trans_grid - IGRint

	   See hsmacdef.h for defines.

	Return Values:
	
	   0 - success
	   1 - failure ( invalid translucency grid )
*/

#omdef hs$set_trans_grid( trans_grid )

	HSset_trans_grid( trans_grid )
	
#endomdef

/*--- hs$get_accuracy_mode -----------------------------------------------------*/

/*
	This macro gets the accuracy mode
	
	Parameters:
	
	   *acc_mode - IGRint

	   See hsmacdef.h for defines.
*/

#omdef hs$get_accuracy_mode( acc_mode )

	HSget_accuracy_mode( acc_mode );
#endomdef


/*--- hs$set_accuracy_mode -----------------------------------------------------*/

/*
	This macro sets the accuracy mode
	
	Parameters:
	
	   acc_mode - IGRint

	   See hsmacdef.h for defines.

	Return Values:
	
	   0 - success
	   1 - failure ( invalid mode )
*/

#omdef hs$set_accuracy_mode( acc_mode )

	HSset_accuracy_mode( acc_mode );
#endomdef



/*--- hs$get_cull_mode -----------------------------------------------------*/

/*
	This macro gets the culling mode
	
	Parameters:
	
	   *cull_mode - IGRint

	   See hsmacdef.h for defines.
*/

#omdef hs$get_cull_mode( cull_mode )

	HSget_cull_mode( cull_mode );
#endomdef


/*--- hs$set_cull_mode -----------------------------------------------------*/

/*
	This macro sets the culling mode
	
	Parameters:
	
	   cull_mode - IGRint

	   See hsmacdef.h for defines.

	Return Values:
	
	   0 - success
	   1 - failure ( invalid cull mode )
*/

#omdef hs$set_cull_mode( cull_mode )

	HSset_cull_mode( cull_mode );
#endomdef


/*--- hs$get_depth_cues -----------------------------------------------------*/

/*
	This macro gets the active shading depth cues
	
	Parameters:
	
	   *far_depth_cue  - IGRuchar

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$get_depth_cues( far_depth_cue )

	HSdpb_get_shading_depth_cues( far_depth_cue );
#endomdef


/*--- hs$set_depth_cues -----------------------------------------------------*/

/*
	This macro sets the active shading depth cues
	
	Parameters:
	
	   far_depth_cue  - IGRuchar

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$set_depth_cues( far_depth_cue )

	HSdpb_set_shading_depth_cues( far_depth_cue );
#endomdef



/*--- hs$get_vhl_layers -----------------------------------------------------*/

/*
	This macro gets the active vhl output layers
	
	Parameters:
	
	   *vhl_visible_layer - IGRushort
	   *vhl_hidden_layer  - IGRushort
	   *vhl_text_layer    - IGRushort

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$get_vhl_layers( vhl_visible_layer, vhl_hidden_layer, vhl_text_layer )

	HSdpb_get_vhl_layers( vhl_visible_layer, vhl_hidden_layer, vhl_text_layer );
#endomdef


/*--- hs$set_vhl_layers -----------------------------------------------------*/

/*
	This macro sets the active vhl output layers
	
	Parameters:
	
	   vhl_visible_layer - IGRushort
	   vhl_hidden_layer  - IGRushort
	   vhl_text_layer    - IGRushort

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$set_vhl_layers( vhl_visible_layer, vhl_hidden_layer, vhl_text_layer )

	HSdpb_set_vhl_layers( vhl_visible_layer, vhl_hidden_layer, vhl_text_layer );
#endomdef


/*--- hs$get_render_image_info -----------------------------------------------------*/

/*
	This macro gets the render image information
	
	Parameters:
	
	   *image_filename  - IGRchar
	   *width           - IGRint
	   *height          - IGRint
	   *device_res      - IGRchar
	   *media_size      - IGRchar

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$get_render_image_info( image_filename, width, height, device_res, media_size )

	HSdpb_get_render_image_info( image_filename, width, height, device_res, media_size );
#endomdef

/*--- hs$set_render_image_info -----------------------------------------------------*/

/*
	This macro sets the render image information
	
	Parameters:
	
	   *image_filename  - IGRchar
	   width            - IGRint
	   height           - IGRint
	   *device_res      - IGRchar
	   *media_size      - IGRchar

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$set_render_image_info( image_filename, width, height, device_res, media_size )

	HSdpb_set_render_image_info( image_filename, width, height, device_res, media_size );
#endomdef


/*--- hs$get_last_styles -----------------------------------------------------*/

/*
	This macro gets the last styles used to shade a window or a region
	
	Parameters:
	
	   *last_shading_style - IGRuchar  - NULL, if not desired
	   *last_region_style  - IGRuchar  - NULL, if not desired

	   See hsmacdef.h for last style defines

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$get_last_styles( last_shading_style = NULL,
	                   last_region_style = NULL )

	HSdpb_get_last_styles( last_shading_style, last_region_style );
#endomdef


/*--- hs$set_last_styles -----------------------------------------------------*/

/*
	This macro sets the last styles used to shade a window or a region
	
	Parameters:
	
	   *last_shading_style - IGRuchar  - NULL, if not to be set
	   *last_region_style  - IGRuchar  - NULL, if not to be set

	   See hsdef.h for last style defines

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$set_last_styles( last_shading_style = NULL,
	                   last_region_style = NULL )

	HSdpb_set_last_styles( last_shading_style, last_region_style );
#endomdef


/*--- hs$copy_dpb_data_to_other_os -------------------------------*/

/*
	This macros copies HSdpb2 data from the current module to
	an HSdpb2 in another object space.

	Parameters:

	   osnum - OMuword

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef hs$copy_dpb_data_to_other_os( osnum )

	HSdpb_copy_data_to_other_os( osnum );

#endomdef


/*--- hs$get_hplot_info ----------------------------------------*/

/*
	This macro gets the hplot info for the current module

	Parameters:

	   *hplot_flags      - IGRuint   - NULL, if not desired
	   *plot_file        - IGRchar   - NULL, if not desired
	   *raster_file      - IGRchar   - NULL, if not desired
	   *text_file        - IGRchar   - NULL, if not desired
	   *plot_queue       - IGRchar   - NULL, if not desired
	   *plot_x_size      - IGRdouble - NULL, if not desired
	   *plot_y_size      - IGRdouble - NULL, if not desired
	   *plot_scale       - IGRdouble - NULL, if not desired
	   *num_copies       - IGRint    - NULL, if not desired
	   *date             - IGRchar   - NULL, if not desired
	   *line_width_const - IGRdouble - NULL, if not desired
	   *max_line_width   - IGRint    - NULL, if not desired
	   *raster_type      - IGRint    - NULL, if not desired

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef hs$get_hplot_info( hplot_flags = NULL,
	                  plot_file = NULL,
	                  raster_file = NULL,
	                  text_file = NULL,
	                  plot_queue = NULL,
	                  plot_x_size = NULL,
	                  plot_y_size = NULL,
	                  plot_scale = NULL,
	                  num_copies = NULL,
	                  date = NULL,
	                  line_width_const = NULL,
	                  max_line_width = NULL,
	                  raster_type = NULL )

	HSdpb_get_hplot_info( hplot_flags, plot_file, raster_file, text_file, plot_queue,
	                      plot_x_size, plot_y_size, plot_scale, num_copies, date,
	                      line_width_const, max_line_width, raster_type );

#endomdef


/*--- hs$set_hplot_info ----------------------------------------*/

/*
	This macro sets the hplot info in the current module

	Parameters:

	   *hplot_flags      - IGRuint   - NULL, if not to be set
	   *plot_file        - IGRchar   - NULL, if not to be set
	   *raster_file      - IGRchar   - NULL, if not to be set
	   *text_file        - IGRchar   - NULL, if not to be set
	   *plot_queue       - IGRchar   - NULL, if not to be set
	   *plot_x_size      - IGRdouble - NULL, if not to be set
	   *plot_y_size      - IGRdouble - NULL, if not to be set
	   *plot_scale       - IGRdouble - NULL, if not to be set
	   *num_copies       - IGRint    - NULL, if not to be set
	   *date             - IGRchar   - NULL, if not to be set
	   *line_width_const - IGRdouble - NULL, if not to be set
	   *max_line_width   - IGRint    - NULL, if not to be set
	   *raster_type      - IGRint    - NULL, if not to be set

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef hs$set_hplot_info( hplot_flags = NULL,
	                  plot_file = NULL,
	                  raster_file = NULL,
	                  text_file = NULL,
	                  plot_queue = NULL,
	                  plot_x_size = NULL,
	                  plot_y_size = NULL,
	                  plot_scale = NULL,
	                  num_copies = NULL,
	                  date = NULL,
	                  line_width_const = NULL,
	                  max_line_width = NULL,
	                  raster_type = NULL )

	HSdpb_set_hplot_info( hplot_flags, plot_file, raster_file, text_file, plot_queue,
	                      plot_x_size, plot_y_size, plot_scale, num_copies, date,
	                      line_width_const, max_line_width, raster_type );

#endomdef


/*--- hs$get_place_light_info -----------------------------------------------------*/

/*
	This macro gets the place light information
	
	Parameters:
	
	   *last_light_num - IGRint
	   *light_flags    - IGRuint  -- see hsdef.h for bit use 

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$get_place_light_info( last_light_num, light_flags )

	HSdpb_get_place_light_info( last_light_num, light_flags );
#endomdef


/*--- hs$set_place_light_info -----------------------------------------------------*/

/*
	This macro sets the place light information
	
	Parameters:
	
	   last_light_num - IGRint
	   light_flags    - IGRuint  -- see hsdef.h for bit use

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$set_place_light_info( last_light_num, light_flags )

	HSdpb_set_place_light_info( last_light_num, light_flags );
#endomdef


/*--- hs$get_display_image_delays -----------------------------------------------------*/

/*
	This macro gets the save image delays
	
	Parameters:
	
	   *cycle_delays - IGRdouble (2)
	   *frame_delays - IGRdouble (2)

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$get_display_image_delays( cycle_delays, frame_delays )

	HSdpb_get_display_image_delays( cycle_delays, frame_delays );
#endomdef


/*--- hs$set_display_image_delays -----------------------------------------------------*/

/*
	This macro sets the save image delays
	
	Parameters:
	
	   *cycle_delays - IGRdouble (2)
	   *frame_delays - IGRdouble (2)

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$set_display_image_delays( cycle_delays, frame_delays )

	HSdpb_set_display_image_delays( cycle_delays, frame_delays );
#endomdef

#endif
