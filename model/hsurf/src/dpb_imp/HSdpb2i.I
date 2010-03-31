
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation HSdpb2;

/*
DESCRIPTION
	Implementation of the HSdpb2 object for shading
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "OMminimum.h"
#include "OMlimits.h"
#include "OMmacros.h"

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "exmacros.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igewindef.h"
#include "igewinmacros.h"

#include "bsvalues.h"

#include "hssymbmacros.h"
#include "hsmacdef.h"
#include "hsdef.h"

#include "hslight.h"
#include "hsurf.h"

/* New Prototypes */
#include "HSdlist.h"

#if defined(__STDC__) || defined(__cplusplus)
        extern int HScrebundentry(         IGRlong *msg,
	          struct HSrender_bundle *entry,
		  struct HSextra_render_bundle *app_entry,
		  IGRint *index,
		  GRobjid mod_id,
		  GRspacenum mod_osnum );
#else
	extern int HScrebundentry(msg,entry,app_entry,index,mod_id,mod_osnum)
	          IGRlong         *msg;
	          struct HSrender_bundle  *entry;
	          struct HSextra_render_bundle *app_entry;
	          IGRint          *index;
	          GRobjid         mod_id;
	          GRspacenum      mod_osnum;
#endif																							  

extern int HSdlist_setup_feedback_gragad( void );

%safe
#include "HSpr_dpb_imp.h"
%endsafe

static OM_S_OBJID HSstatic_dpb2_id;
static OMuword    HSstatic_dpb2_os;

extern OM_S_OBJID HSglobal_IGEcolor_id;
extern OMuword    HSglobal_IGEcolor_os;

/*--- debug -----------------------------------------------------------------*/

method debug()

/*
DESCRIPTION
	Print out instance data
*/

	{
	fprintf( stderr, "HSdpb2 INSTANCE DATA\n\n" );
	fprintf( stderr, "   SHADING-FLAGS: 0x%X\n", me->shading_flags );
	fprintf( stderr, "   RENDERING-FLAGS: 0x%X\n", me->rendering_flags );
	fprintf( stderr, "   SAVE-IMAGE-FLAGS: 0x%X\n", me->save_image_flags );
	fprintf( stderr, "   VHL-FLAGS: 0x%X\n", me->vhl_flags );
	fprintf( stderr, "   REND-ATTR-FLAGS: 0x%X\n", me->rend_attr_flags );
	fprintf( stderr, "   TOLERANCE: %lf  ACCURACY: %d\n", me->tolerance, me->accuracy );
	fprintf( stderr, "   FAR-DEPTH-CUE: %d\n", me->far_depth_cue );
	fprintf( stderr, "   EYE-SEPARATION: %lf\n", me->eye_separation );
	fprintf( stderr, "   LAST-SHADING-STYLE: %d\n", me->last_shading_style );
	fprintf( stderr, "   LAST-REGION-STYLE: %d\n", me->last_region_style );

	fprintf( stderr, "\n" );
	fprintf( stderr, "   HPLOT-FLAGS: 0x%X\n", me->hplot_flags );
	fprintf( stderr, "   PLOT-FILE: %s\n", me->plot_file );
	fprintf( stderr, "   RASTER-FILE: %s\n", me->raster_file );
	fprintf( stderr, "   TEXT-FILE: %s\n", me->text_file );
	fprintf( stderr, "   PLOT-QUEUE: %s\n", me->plot_queue );
	fprintf( stderr, "   PLOT-X-SIZE: %lf\n", me->plot_x_size );
	fprintf( stderr, "   PLOT-Y-SIZE: %lf\n", me->plot_y_size );
	fprintf( stderr, "   PLOT-SCALE: %lf\n", me->plot_scale );
	fprintf( stderr, "   NUM-COPIES: %d\n", me->num_copies );
	fprintf( stderr, "   DATE: %s\n", me->date );
	fprintf( stderr, "   LINE-WIDTH-CONST: %lf\n", me->line_width_const );
	fprintf( stderr, "   MAX-LINE-WIDTH: %d\n", me->max_line_width );
	fprintf( stderr, "   RASTER TYPE: %d\n", me->raster_type );

	fprintf( stderr, "\n" );
	fprintf( stderr, "   RENDER IMAGE FILE NAME: %s\n", me->image_filename );
	fprintf( stderr, "   RENDER IMAGE DEVICE RES: %s\n", me->device_res );
	fprintf( stderr, "   RENDER IMAGE MEDIA SIZE: %s\n", me->media_size );
	fprintf( stderr, "   RENDER IMAGE WIDTH,HEIGHT: %d,%d\n", me->image_width, me->image_height );

	fprintf( stderr, "\n" );
	fprintf( stderr, "   LAST LIGHT NUM: %d\n", me->last_light_num );
	fprintf( stderr, "   PLACE LIGHT FLAGS: 0x%X\n", me->light_flags );

	fprintf( stderr, "\n" );
	fprintf( stderr, "   DISPLAY IMAGE CYCLE DELAYS: %lf %lf\n", me->d_expansion[0], me->d_expansion[1] );
	fprintf( stderr, "   DISPLAY IMAGE FRAME DELAYS: %lf %lf\n", me->d_expansion[2], me->d_expansion[3] );

	fprintf( stderr, "\n" );
	fprintf( stderr, "   AMB RED: %d  AMB GREEN: %d  AMB BLUE: %d\n",
	         me->amb_red, me->amb_green, me->amb_blue );
	
	fprintf( stderr, "\n" );
	fprintf( stderr, "   RENDER BUNDLE\n" );
	fprintf( stderr, "      SHADING-STYLE: %d\n", me->rend_bundle.shad_style );
	fprintf( stderr, "      TEXTURE-ORIENT: %d\n", me->rend_bundle.tex_orient );
	fprintf( stderr, "      TEXTURE-INDEX: %d\n", me->rend_bundle.tex_index );
	fprintf( stderr, "      FINISH: %d\n", me->rend_bundle.finish );
	fprintf( stderr, "      TRANSPARENCY: %d\n", me->rend_bundle.trans );
	fprintf( stderr, "      DIFFUSE REFLECTION: %d\n", me->rend_bundle.diff_refl );
	fprintf( stderr, "      SPECUALR REFLECTION: %d\n", me->rend_bundle.spec_refl );
	fprintf( stderr, "      RED: %d  GREEN: %d  BLUE: %d\n",
	          me->rend_bundle.red, me->rend_bundle.green, me->rend_bundle.blue );


	fprintf( stderr, "\n" );
	fprintf( stderr, "   EXTRA RENDER BUNDLE\n" );
	fprintf( stderr, "      REFRACTION: %f\n", me->extra_rend_bundle.refraction );
	fprintf( stderr, "      PATTERN X OFFSET: %f\n", me->extra_rend_bundle.pattern_x_offset );
	fprintf( stderr, "      PATTERN Y OFFSET: %f\n", me->extra_rend_bundle.pattern_y_offset );
	fprintf( stderr, "      PATTERN ROT ANGLE: %f\n", me->extra_rend_bundle.pattern_rot_angle );
	fprintf( stderr, "      PATTERN SCALE: %f\n", me->extra_rend_bundle.pattern_scale );
	fprintf( stderr, "      FLAGS: 0x%X\n", me->extra_rend_bundle.flags );
	fprintf( stderr, "      REFLECTION: %d\n", me->extra_rend_bundle.reflection );

	return( OM_S_SUCCESS );
	}  /* debug */


/*--- super_construct -------------------------------------------------------*/

method super_construct()

/*
DESCRIPTION
	Load default instance data 
*/

	{
	IGRlong    msg;
	IGRint     ii;
	IGRint     bundle_index;
	OM_S_OBJID mod_id;

	me->shading_flags = HS_SHADING_SHADE_MODE | HS_SHADING_TABLE_CALC |
	                    HS_SHADING_TRANS_MODE | HS_SHADING_WINDOW_ACCUR;

	me->rendering_flags = HS_RENDER_SIZE_WINDOW | HS_RENDER_FULL_RES;

	me->save_image_flags = HS_SAVE_IMAGE_AS_IS | HS_DIS_IMAGE_SCALE_ONE;

	me->vhl_flags = HS_VHL_LOW_RES | HS_VHL_REF_DISPLAY_OFF | HS_VHL_HIDING;

	me->rend_attr_flags = HS_REND_ATTR_COPY_TRANS | HS_REND_ATTR_COPY_DIFFUSE |
	                      HS_REND_ATTR_COPY_SPECULAR | HS_REND_ATTR_COPY_FINISH |
	                      HS_REND_ATTR_COPY_COLOR | HS_REND_ATTR_COPY_TEXTURE |
	                      HS_REND_ATTR_COPY_TO_ORIG | HS_REND_ATTR_COPY_TO_OTHER;

	me->tolerance = 0.5;
	me->accuracy = 3;
	me->far_depth_cue = 255;

	me->eye_separation = 2.5;

	me->last_shading_style = HS_STYLE_SMOOTH;
	me->last_region_style = HS_STYLE_SMOOTH;

	me->vhl_visible_layer = 1022;
	me->vhl_hidden_layer = 1023;
	me->vhl_text_layer = 1022;

	me->amb_red = me->amb_green = me->amb_blue = 31;

	for ( ii = 0; ii < MAX_LIGHTS; ii++ )
	   {
	   me->dblight[ii].location[0] = 0.0;
	   me->dblight[ii].location[1] = 0.0;
	   me->dblight[ii].location[2] = 1.0;

	   me->dblight[ii].radius = 10.0;
	   me->dblight[ii].angle = 90.0 * M_PI / 360.0;

	   me->dblight[ii].red = me->dblight[ii].green = me->dblight[ii].blue = 255;
	   }

	me->hplot_flags = HS_PLOT_PLOT_BY_SIZE | HS_PLOT_WINDOW_CONTENTS | HS_PLOT_EDGE_COLOR;
	me->plot_file[0] = '\0';
	me->raster_file[0] = '\0';
	me->text_file[0] = '\0';
	me->plot_queue[0] = '\0';
	me->plot_x_size = 1.0;
	me->plot_y_size = 1.0;
	me->plot_scale = 1.0;
	me->num_copies = 1;
	me->date[0] = '\0';
	me->line_width_const = 0.01;
	me->max_line_width = 16;
	me->raster_type = 25;

	me->image_filename[0] = '\0';
	me->device_res[0] = '\0';
	me->media_size[0] = '\0';

	me->rend_bundle.shad_style = HS_STYLE_SMOOTH;
	me->rend_bundle.tex_orient = 0;
	me->rend_bundle.tex_index = 0;
	me->rend_bundle.finish = 11;
	me->rend_bundle.trans = 0;
	me->rend_bundle.diff_refl = 255;
	me->rend_bundle.spec_refl = 128;
	me->rend_bundle.red = 0;
	me->rend_bundle.green = 0;
	me->rend_bundle.blue = 0;

	me->extra_rend_bundle.refraction = 1.0;
	me->extra_rend_bundle.pattern_x_offset = 0.0;
	me->extra_rend_bundle.pattern_y_offset = 0.0;
	me->extra_rend_bundle.pattern_rot_angle = 0.0;
	me->extra_rend_bundle.pattern_scale = 1.0;
	me->extra_rend_bundle.flags = 0;
	me->extra_rend_bundle.reflection = (.4 * 255) + 0.5;

	ex$get_modid( mod_osnum = OM_Gw_current_OS, mod_id = &mod_id );

	/* "create" this bundle */
	hs$create_symb_entry( msg = &msg,
	                      entry = &me->rend_bundle,
	                      app_entry = NULL,
	                      index = &bundle_index,
	                      mod_id = mod_id ); 

	return( OM_S_SUCCESS );
	}


/*--- wake_up --------------------------------------------------------------*/

method wake_up()

/*
DESCRIPTION
	Save my object id if I'm in the master file
*/

	{
	OM_S_OBJID cur_mod_id;
	OMuword    cur_mod_os;
	ex$get_cur_mod( osnum = &cur_mod_os, id = &cur_mod_id );
	if ( cur_mod_os == OM_Gw_current_OS )
	   {
	   HSstatic_dpb2_id = my_id;
	   HSstatic_dpb2_os = OM_Gw_current_OS;

	   /* get the ID,OS of the IGEcolor object which is used to    */
	   /* speed up the conversion of a color index to an rgb value */
	   /* See HSget_rgb_value().                                   */
	   ex$get_super( mod_id        = cur_mod_id,
	                 mod_osnum     = cur_mod_os,
	                 super_name    = "IGECOLOR",
	                 super_class   = "IGEcolor",
	                 super_id      = &HSglobal_IGEcolor_id,
	                 super_osnum   = &HSglobal_IGEcolor_os );
	   }

	/* make sure the expansion VLA's are the correct size */

	/*
	   d_expansion usage:
             0-1 : Display image cycle delay
	     2-3 : Display image frame delay
	*/
	if ( om$dimension_of( varray = me->d_expansion ) < 4 )
	   {
	   om$vla_set_dimension( varray = me->d_expansion, size = 4 );

	   me->d_expansion[0] = 10.0;
	   me->d_expansion[1] = 1.0;
	   me->d_expansion[2] = 5.0;
	   me->d_expansion[3] = 0.0;
	   }

        /* initialize shading display list processing */
        HSdlist_setup_feedback_gragad();

	return( OM_S_SUCCESS );
	}


/*--- copy_instance_to_other_HSdpb2 ---------------------------------------------*/

method copy_instance_to_other_HSdpb2( OM_S_OBJID objid; OMuword osnum )

/*
DESCRIPTION
	This message is used to copy all of the instance data in an HSdpb2
	object to another HSdpb2 object.
*/

	{
	struct HS_light_source amb;

	om$send( msg = message HSdpb2.put_shading_tol( me->tolerance ),
	         targetid = objid, targetos = osnum );

	om$send( msg = message HSdpb2.put_shading_flags( &me->shading_flags, &me->rendering_flags,
	                                                 &me->save_image_flags, &me->vhl_flags,
	                                                 &me->rend_attr_flags ),
	         targetid = objid, targetos = osnum );


	amb.red = me->amb_red; amb.green = me->amb_green; amb.blue = me->amb_blue;
	om$send( msg = message HSdpb2.set_ambient_light( amb ),
	         targetid = objid, targetos = osnum );
	        
	om$send( msg = message HSdpb2.set_shading_accuracy( me->accuracy ),
	         targetid = objid, targetos = osnum );

	om$send( msg = message HSdpb2.set_rendering_bundles( &me->rend_bundle,
	                                                     NULL),
	         targetid = objid, targetos = osnum );

	om$send( msg = message HSdpb2.set_depth_cues( me->far_depth_cue ),
	         targetid = objid, targetos = osnum );

	om$send( msg = message HSdpb2.set_vhl_layers( me->vhl_visible_layer,
	                                              me->vhl_hidden_layer,
	                                              me->vhl_text_layer ),
	         targetid = objid, targetos = osnum );


	om$send( msg = message HSdpb2.set_render_image_info( me->image_filename,
	                                                     me->image_width, me->image_height,
	                                                     me->device_res, me->media_size ),
	         targetid = objid, targetos = osnum );

	om$send( msg = message HSdpb2.set_last_styles( &me->last_shading_style,
		                                       &me->last_region_style ),
	         targetid = objid, targetos = osnum );

	om$send( msg      = message HSdpb2.set_hplot_info( &me->hplot_flags, me->plot_file, me->raster_file,
	                                                   me->text_file, me->plot_queue, &me->plot_x_size,
	                                                   &me->plot_y_size, &me->plot_scale, &me->num_copies,
	                                                   me->date, &me->line_width_const, 
	                                                   &me->max_line_width, &me->raster_type ),
	         targetid = objid, targetos = osnum );

	return( OM_S_SUCCESS );
	}  /* copy_instance_to_other_HSdpb2 */


/*--- get_shading_tol -----------------------------------------------------------*/

method get_shading_tol( IGRdouble *shading_tol )

/*
DESCRIPTION
	Get the shading tolerance from the instance data
*/

	{
	*shading_tol = me->tolerance;
	return( OM_S_SUCCESS );
	}


/*--- put_shading_tol -----------------------------------------------------------*/

method put_shading_tol( IGRdouble shading_tol )

/*
DESCRIPTION
	Put a shading tolerance into the instance data
*/

	{
	if ( (shading_tol >= 0.25) && (shading_tol <= 16.0) )
	   {
	   me->tolerance = shading_tol;
	   return( OM_S_SUCCESS );
	   }
	else
	   return( OM_E_ERROR );
	}


/*--- get_shading_flags -----------------------------------------------------*/

method get_shading_flags( IGRuint *shading_flags; IGRuint *rendering_flags;
	                  IGRuint *save_image_flags; IGRuint *vhl_flags;
	                  IGRuint *rend_attr_flags )

/*
DESCRIPTION
	Get the shading flags from the instance data
*/

	{
	if ( shading_flags )
	   *shading_flags = me->shading_flags;

	if ( rendering_flags )
	   *rendering_flags = me->rendering_flags;

	if ( save_image_flags )
	   *save_image_flags = me->save_image_flags;

	if ( vhl_flags )
	   *vhl_flags = me->vhl_flags;

	if ( rend_attr_flags )
	   *rend_attr_flags = me->rend_attr_flags;

	return( OM_S_SUCCESS );
	}


/*--- put_shading_flags -----------------------------------------------------*/

method put_shading_flags( IGRuint *shading_flags; IGRuint *rendering_flags;
	                  IGRuint *save_image_flags; IGRuint *vhl_flags;
	                  IGRuint *rend_attr_flags )

/*
DESCRIPTION
	Put the shading flags into the instance data
*/

	{
	if ( shading_flags )
	   me->shading_flags = *shading_flags;

	if ( rendering_flags )
	   me->rendering_flags = *rendering_flags;

	if ( save_image_flags )
	   me->save_image_flags = *save_image_flags;

	if ( vhl_flags )
	   me->vhl_flags = *vhl_flags;

	if ( rend_attr_flags )
	   me->rend_attr_flags = *rend_attr_flags;

	return( OM_S_SUCCESS );
	}


/*--- get_global_lights -----------------------------------------------------*/

method get_global_lights( struct HS_light_source *lights )

/*
DESCRIPTION
	Get global lights from the instance data.
	This method will no longer work because light data is not
	stored in the HSdpb2 object = >must use macro
*/

	{
	return( OM_E_ERROR );
	}


/*--- set_global_lights -----------------------------------------------------*/

method set_global_lights( struct HS_light_source *lights )

/*
DESCRIPTION
	Put global lights into the instance data
	This method will no longer work because light data is not
	stored in the HSdpb2 object = >must use macro
*/

	{
	return( OM_E_ERROR );
	}


/*--- get_ambient_light -----------------------------------------------------*/

method get_ambient_light( struct HS_light_source *amb )

/*
DESCRIPTION
	Get ambient light from the instance data
*/

	{
	amb->flags = HS_LIGHT_AMBIENT | HS_LIGHT_ENABLED;
	amb->location[0] = amb->location[1] = amb->location[2] = 0.0;
	amb->target[0] = amb->target[1] = amb->target[2] = 0.0;
	amb->direction[0] = amb->direction[1] = amb->direction[2] = 0.0;
	amb->radius = 0.0;
	amb->angle = 0.0;
	amb->red = me->amb_red;
	amb->green = me->amb_green;
	amb->blue = me->amb_blue;

	return( OM_S_SUCCESS );
	}


/*--- set_ambient_light -----------------------------------------------------*/

method set_ambient_light( struct HS_light_source amb )

/*
DESCRIPTION
	Put ambient light into the instance data
*/

	{
	me->amb_red = amb.red;
	me->amb_green = amb.green;
	me->amb_blue = amb.blue;

	return( OM_S_SUCCESS );
	}

/*--- get_shading_accuracy -----------------------------------------------------------*/

method get_shading_accuracy( IGRint *accuracy )

/*
DESCRIPTION
	Get the shading accuracy from the instance data
*/

	{
	*accuracy = me->accuracy;

	return( OM_S_SUCCESS );
	}


/*--- set_shading_accuracy -----------------------------------------------------------*/

method set_shading_accuracy( IGRint accuracy )

/*
DESCRIPTION
	Put a shading accuracy into the instance data
*/

	{
	if ( (accuracy >= 1) && (accuracy <= 15) )
	   {
	   me->accuracy = accuracy;
	   return( OM_S_SUCCESS );
	   }
	else
	   return( OM_E_ERROR );
	}


/*--- get_rendering_bundles -----------------------------------------------------------*/

method get_rendering_bundles( struct HSrender_bundle *rend_bundle;
	                      struct HSextra_render_bundle *extra_rend_bundle )

/*
DESCRIPTION
	Get the rendering bundles from the instance data
*/

	{
	if ( rend_bundle )
	   memcpy( rend_bundle, &me->rend_bundle, sizeof( struct HSrender_bundle ) );

	if ( extra_rend_bundle )
	   memcpy( extra_rend_bundle, &me->extra_rend_bundle, sizeof( struct HSextra_render_bundle ) );

	return( OM_S_SUCCESS );
	}


/*--- set_rendering_bundles -----------------------------------------------------------*/

method set_rendering_bundles( struct HSrender_bundle *rend_bundle;
	                      struct HSextra_render_bundle *extra_rend_bundle )

/*
DESCRIPTION
	Set the rendering bundles in the instance data
*/

	{
	
         
        IGRlong  msg;
        IGRint index;

	if ( rend_bundle )
	   memcpy( &me->rend_bundle, rend_bundle, sizeof( struct HSrender_bundle ) );

	if ( extra_rend_bundle )
	   memcpy( &me->extra_rend_bundle, extra_rend_bundle, sizeof( struct HSextra_render_bundle ) );

     
	/* Create new bundle */
        if (extra_rend_bundle)
	    hs$create_symb_entry( msg = &msg,
	                          index = &index,
	                          entry = &me->rend_bundle,
	                          app_entry = &me->extra_rend_bundle );
        else
	    hs$create_symb_entry( msg = &msg,
	                          index = &index,
	                          entry = &me->rend_bundle,
	                          app_entry = NULL);
        
	return( OM_S_SUCCESS );
	}


/*--- get_depth_cues -----------------------------------------------------------*/

method get_depth_cues( IGRuchar *far_depth_cue )

/*
DESCRIPTION
	Get the shading depth cues from the instance data
*/

	{
	*far_depth_cue = me->far_depth_cue;

	return( OM_S_SUCCESS );
	}

/*--- set_depth_cues -----------------------------------------------------------*/

method set_depth_cues( IGRuchar far_depth_cue )

/*
DESCRIPTION
	Set the shading depth cues in the instance data
*/

	{
	me->far_depth_cue = far_depth_cue;

	return( OM_S_SUCCESS );
	}

/*--- get_vhl_layers -----------------------------------------------------------*/

method get_vhl_layers( IGRushort *vhl_visible_layer;
	               IGRushort *vhl_hidden_layer;
	               IGRushort *vhl_text_layer )

/*
DESCRIPTION
	Get the layers used for VHL curve output
*/

	{
	*vhl_visible_layer = me->vhl_visible_layer;
	*vhl_hidden_layer = me->vhl_hidden_layer;
	*vhl_text_layer = me->vhl_text_layer;

	return( OM_S_SUCCESS );
	}

/*--- set_vhl_layers -----------------------------------------------------------*/

method set_vhl_layers( IGRushort vhl_visible_layer;
	               IGRushort vhl_hidden_layer;
	               IGRushort vhl_text_layer )

/*
DESCRIPTION
	Set the layers used for VHL curve output
*/

	{
	if ( (vhl_visible_layer <= 1023) &&
	     (vhl_hidden_layer <= 1023) &&
	     (vhl_text_layer <= 1023) )
	   {
	   me->vhl_visible_layer = vhl_visible_layer;
	   me->vhl_hidden_layer = vhl_hidden_layer;
	   me->vhl_text_layer = vhl_text_layer ;

	   return( OM_S_SUCCESS );
	   }
	else
	   return( OM_E_ERROR );
	}

/*--- get_render_image_info ---------------------------------------------------------*/

method get_render_image_info( IGRchar *image_filename; IGRint *width; IGRint *height;
	                      IGRchar *device_res; IGRchar *media_size )

/*
DESCRIPTION
	Gets the render image information
*/

	{
	strcpy( image_filename, me->image_filename );
	*width = me->image_width;
	*height = me->image_height;
	strcpy( device_res, me->device_res );
	strcpy( media_size, me->media_size );

	return( OM_S_SUCCESS );
	}


/*--- set_render_image_info ---------------------------------------------------------*/

method set_render_image_info( IGRchar *image_filename; IGRint width; IGRint height;
	                      IGRchar *device_res; IGRchar *media_size )

/*
DESCRIPTION
	Gets the render image information
*/

	{
	IGRint string_size;

	me->image_width = width;
	me->image_height = height;

	string_size = strlen( image_filename ) + 1;
	if ( string_size > om$dimension_of( varray = me->image_filename ) )
	   {
	   om$vla_set_dimension( varray = me->image_filename, size = string_size );
	   }
	strcpy( me->image_filename, image_filename );

	string_size = strlen( device_res ) + 1;
	if ( string_size > om$dimension_of( varray = me->device_res ) )
	   {
	   om$vla_set_dimension( varray = me->device_res, size = string_size );
	   }
	strcpy( me->device_res, device_res );

	string_size = strlen( media_size ) + 1;
	if ( string_size > om$dimension_of( varray = me->media_size ) )
	   {
	   om$vla_set_dimension( varray = me->media_size, size = string_size );
	   }
	strcpy( me->media_size, media_size );

	return( OM_S_SUCCESS );
	}

/*--- get_last_styles ---------------------------------------------------------*/

method get_last_styles( IGRuchar *last_shading_style;
	                IGRuchar *last_region_style )

/*
DESCRIPTION
	Gets the last styles used to shade a window or update a region
*/

	{
	if ( last_shading_style )
	   *last_shading_style = me->last_shading_style;

	if ( last_region_style )
	   *last_region_style = me->last_region_style;

	return( OM_S_SUCCESS );
	}


/*--- set_last_styles ---------------------------------------------------------*/

method set_last_styles( IGRuchar *last_shading_style;
	                IGRuchar *last_region_style )

/*
DESCRIPTION
	Sets the last styles used to shade a window or update a region
*/

	{
	if ( last_shading_style )
	   me->last_shading_style = *last_shading_style;

	if ( last_region_style )
	   me->last_region_style = *last_region_style;

	return( OM_S_SUCCESS );
	}



/*--- get_hplot_info -----------------------------------------------*/

method get_hplot_info( IGRuint         *hplot_flags;
	               IGRchar         *plot_file;
	               IGRchar         *raster_file;
	               IGRchar         *text_file;
	               IGRchar         *plot_queue;
	               IGRdouble       *plot_x_size;
	               IGRdouble       *plot_y_size;
	               IGRdouble       *plot_scale;
	               IGRint          *num_copies;
	               IGRchar         *date;
	               IGRdouble       *line_width_const;
	               IGRint          *max_line_width;
	               IGRint          *raster_type )

/*
DESCRIPTION
	Gets the hplot information
*/

	{
	if ( hplot_flags )
	   *hplot_flags = me->hplot_flags;

	if ( plot_file )
	   strcpy( plot_file, me->plot_file );

	if ( raster_file )
	   strcpy( raster_file, me->raster_file );

	if ( text_file )
	   strcpy( text_file, me->text_file );

	if ( plot_queue )
	   strcpy( plot_queue, me->plot_queue );

	if ( plot_x_size )
	   *plot_x_size = me->plot_x_size;

	if ( plot_y_size )
	   *plot_y_size = me->plot_y_size;

	if ( plot_scale )
	   *plot_scale = me->plot_scale;

	if ( num_copies )
	   *num_copies = me->num_copies;

	if ( date )
	   strcpy( date, me->date );

	if ( line_width_const )
	   *line_width_const = me->line_width_const;

	if ( max_line_width )
	   *max_line_width = me->max_line_width;

	if ( raster_type )
	   *raster_type = me->raster_type;

	return( OM_S_SUCCESS );
	}  /* get_hplot_info */


/*--- set_hplot_info -----------------------------------------------*/

method set_hplot_info( IGRuint         *hplot_flags;
	               IGRchar         *plot_file;
	               IGRchar         *raster_file;
	               IGRchar         *text_file;
	               IGRchar         *plot_queue;
	               IGRdouble       *plot_x_size;
	               IGRdouble       *plot_y_size;
	               IGRdouble       *plot_scale;
	               IGRint          *num_copies;
	               IGRchar         *date;
	               IGRdouble       *line_width_const;
	               IGRint          *max_line_width;
	               IGRint          *raster_type )

/*
DESCRIPTION
	Sets the hplot information
*/

	{
	if ( hplot_flags )
	   me->hplot_flags = *hplot_flags;

	if ( plot_file )
	   strcpy( me->plot_file, plot_file );

	if ( raster_file )
	   strcpy( me->raster_file, raster_file );

	if ( text_file )
	   strcpy( me->text_file, text_file );

	if ( plot_queue )
	   strcpy( me->plot_queue, plot_queue );

	if ( plot_x_size )
	   me->plot_x_size = *plot_x_size;

	if ( plot_y_size )
	   me->plot_y_size = *plot_y_size;

	if ( plot_scale )
	   me->plot_scale = *plot_scale;

	if ( num_copies )
	   me->num_copies = *num_copies;

	if ( date )
	   strcpy( me->date, date );

	if ( line_width_const )
	   me->line_width_const = *line_width_const;

	if ( max_line_width )
	   me->max_line_width = *max_line_width;

	if ( raster_type )
	   me->raster_type = *raster_type;

	return( OM_S_SUCCESS );
	}  /* set_hplot_info */

/*--- get_place_light_info ------------------------------------------------*/

method get_place_light_info( IGRint *last_light_num; IGRuint *light_flags )

/*
DESCRIPTION
	Gets the place light information
*/

	{
	*last_light_num = me->last_light_num;
	*light_flags = me->light_flags;
	
	return( OM_S_SUCCESS );
	}


/*--- set_place_light_info ------------------------------------------------*/

method set_place_light_info( IGRint last_light_num; IGRuint light_flags )

/*
DESCRIPTION
	Sets the place light information
*/

	{
	me->last_light_num = last_light_num;
	me->light_flags = light_flags;
	
	return( OM_S_SUCCESS );
	}

/*--- get_display_image_delays ----------------------------------------------*/

method get_display_image_delays( IGRdouble *cycle_delays; IGRdouble *frame_delays )

/*
DESCRIPTION
	Gets the display image cycle delays
*/

	{
	memcpy( cycle_delays, me->d_expansion, sizeof( IGRdouble ) * 2 );
	memcpy( frame_delays, &me->d_expansion[2], sizeof( IGRdouble ) * 2 );
	return( OM_S_SUCCESS );
	}

/*--- set_display_image_delays ----------------------------------------------*/

method set_display_image_delays( IGRdouble *cycle_delays; IGRdouble *frame_delays )

/*
DESCRIPTION
	Sets the display image cycle delays
*/

	{
	memcpy( me->d_expansion, cycle_delays, sizeof( IGRdouble ) * 2 );
	memcpy( &me->d_expansion[2], frame_delays, sizeof( IGRdouble ) * 2 );
	return( OM_S_SUCCESS );
	}


/* ################## FUNCTIONS USED TO ACCESS DPB DATA ################## */

/* Functions return 0 if successful, 1 if a failure occurs */


/*--- HSget_dpb_super -----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_dpb_super( OM_S_OBJID *super_id,
				 OMuword *super_os )
#else
	void HSget_dpb_super( super_id, super_os )

	OM_S_OBJID	*super_id;
	OMuword		*super_os;
#endif

	{
	OM_S_OBJID	temp_mod_id;
	OMuword		temp_mod_os;

	ex$get_cur_mod( osnum = &temp_mod_os, id = &temp_mod_id );

	ex$get_super( mod_id      = temp_mod_id,
	              mod_osnum   = temp_mod_os,
	              super_name  = "HSdpb2",
	              super_class = "HSdpb2",
	              super_id    = super_id,
	              super_osnum = super_os,
	              create      = 1 );
	}  /* HSget_dpb_super */


/*--- HSdpb_copy_data_to_other_os -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_copy_data_to_other_os( OMuword osnum )
#else
	IGRint HSdpb_copy_data_to_other_os( osnum )

	OMuword osnum;
#endif

	{
	IGRlong    sts;
	OM_S_OBJID mod_id;
	OM_S_OBJID super_id;
	OMuword    super_os;
	OM_S_OBJID other_super_id;
	OMuword    other_super_os;

	ex$get_modid( mod_osnum = osnum, mod_id = &mod_id );

	/* get the object id of the HSdpb2 in the other object space */
	ex$get_super( mod_id      = mod_id,
	              mod_osnum   = osnum,
	              super_name  = "HSdpb2",
	              super_class = "HSdpb2",
	              super_id    = &other_super_id,
	              super_osnum = &other_super_os,
	              create      = 1 );

	HSget_dpb_super( &super_id, &super_os );

	sts = om$send( msg = message HSdpb2.copy_instance_to_other_HSdpb2( other_super_id, other_super_os ),
	               targetid = super_id, targetos = super_os, senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_copy_data_to_other_os */


/*--- HSdpb_get_shading_tolerance -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_shading_tolerance( IGRdouble *tolerance )
#else
	IGRint HSdpb_get_shading_tolerance( tolerance )

	IGRdouble  *tolerance;
#endif

/*
DESCRIPTION
	This function reads the shading tolerance from the
	current module.
*/

	{
	IGRlong    sts;

	sts = om$send( msg      = message HSdpb2.get_shading_tol( tolerance ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_shading_tolerance */


/*--- HSdpb_put_shading_tolerance -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_put_shading_tolerance( IGRdouble tolerance )
#else
	IGRint HSdpb_put_shading_tolerance( tolerance )

	IGRdouble  tolerance;
#endif

/*
DESCRIPTION
	This function changes the shading tolerance for the
	current module.
*/

	{
	IGRlong    sts;

	sts = om$send( msg      = message HSdpb2.put_shading_tol( tolerance ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1  );
	}  /* HSdpb_put_shading_tolerance */


/*--- HSdpb_get_shading_accuracy -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_shading_accuracy( IGRint *accuracy )
#else
	IGRint HSdpb_get_shading_accuracy( accuracy )

	IGRint  *accuracy;
#endif

/*
DESCRIPTION
	This function reads the shading accuracy from the
	current module.
*/

	{
	IGRlong    sts;

	sts = om$send( msg      = message HSdpb2.get_shading_accuracy( accuracy ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_shading_accuracy */


/*--- HSdpb_set_shading_accuracy -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_set_shading_accuracy( IGRint accuracy )
#else
	IGRint HSdpb_set_shading_accuracy( accuracy )

	IGRint  accuracy;
#endif

/*
DESCRIPTION
	This function changes the shading accuracy for the
	current module.
*/

	{
	IGRlong    sts;

	sts = om$send( msg      = message HSdpb2.set_shading_accuracy( accuracy ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_set_shading_accuracy */


/*--- HSdpb_get_shading_flags ---------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_shading_flags( IGRuint *shading_flags,
					IGRuint *rendering_flags,
					IGRuint *save_image_flags,
					IGRuint *vhl_flags,
					IGRuint *rend_attr_flags )
#else
	IGRint HSdpb_get_shading_flags( shading_flags, rendering_flags,
		                        save_image_flags, vhl_flags, rend_attr_flags )

	IGRuint 	*shading_flags, *rendering_flags,
	                *save_image_flags, *vhl_flags, *rend_attr_flags;
#endif

/*
DESCRIPTION
	This function reads the shading flags from the
	current module.
*/

	{
	IGRlong    sts;

	sts = om$send( msg      = message HSdpb2.get_shading_flags( shading_flags, rendering_flags,
	                                                            save_image_flags, vhl_flags,
	                                                            rend_attr_flags ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_shading_flags */


/*--- HSdpb_put_shading_flags ---------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_put_shading_flags( IGRuint *shading_flags,
					IGRuint *rendering_flags,
					IGRuint *save_image_flags,
					IGRuint *vhl_flags,
					IGRuint *rend_attr_flags )
#else
	IGRint HSdpb_put_shading_flags( shading_flags, rendering_flags,
		                        save_image_flags, vhl_flags, rend_attr_flags )

	IGRuint 	*shading_flags, *rendering_flags,
	                *save_image_flags, *vhl_flags, *rend_attr_flags;
#endif

/*
DESCRIPTION
	This function changes the shading flags for the
	current module.
*/

	{
	IGRlong    sts;

	sts = om$send( msg      = message HSdpb2.put_shading_flags( shading_flags, rendering_flags,
	                                                            save_image_flags, vhl_flags,
	                                                            rend_attr_flags ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_put_shading_flags */


/*--- HSdpb_get_rendering_bundles -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_rendering_bundles( struct HSrender_bundle *rend_bundle,
				      struct HSextra_render_bundle *extra_rend_bundle )
#else
	IGRint HSdpb_get_rendering_bundles( rend_bundle, extra_rend_bundle )

	struct HSrender_bundle       *rend_bundle;
	struct HSextra_render_bundle *extra_rend_bundle;
#endif

/*
DESCRIPTION
	This function reads the rendering bundles from the
	current module.
*/

	{
	IGRlong    sts;

	sts = om$send( msg      = message HSdpb2.get_rendering_bundles( rend_bundle, extra_rend_bundle ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_rendering_bundles */


/*--- HSdpb_set_rendering_bundles -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_set_rendering_bundles( struct HSrender_bundle  *rend_bundle,
				      struct HSextra_render_bundle *extra_rend_bundle )
#else
	IGRint HSdpb_set_rendering_bundles( rend_bundle, extra_rend_bundle )

	struct HSrender_bundle       *rend_bundle;
	struct HSextra_render_bundle *extra_rend_bundle;
#endif

/*
DESCRIPTION
	This function sets the rendering bundles into the
	current module.
*/

	{
	IGRlong    sts;

	sts = om$send( msg      = message HSdpb2.set_rendering_bundles( rend_bundle, extra_rend_bundle ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_set_rendering_bundles */


/*--- HSdpb_get_shading_depth_cues -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_shading_depth_cues( IGRuchar *far_depth_cue )
#else
	IGRint HSdpb_get_shading_depth_cues( far_depth_cue )

	IGRuchar *far_depth_cue;
#endif

/*
DESCRIPTION
	This function reads the shading depth cues from the
	current module.
*/

	{
	IGRlong    sts;

	sts = om$send( msg      = message HSdpb2.get_depth_cues( far_depth_cue ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1  );
	}  /* HSdpb_get_shading_depth_cues */


/*--- HSdpb_set_shading_depth_cues -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_set_shading_depth_cues( IGRuchar far_depth_cue )
#else
	IGRint HSdpb_set_shading_depth_cues( far_depth_cue )

	IGRuchar far_depth_cue;
#endif

/*
DESCRIPTION
	This function sets the shading depth cues in the
	current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.set_depth_cues( far_depth_cue ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_shading_depth_cues */


/*--- HSdpb_get_vhl_layers -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_vhl_layers( IGRushort *vhl_visible_layer,
				     IGRushort *vhl_hidden_layer,
				     IGRushort *vhl_text_layer )
#else
	IGRint HSdpb_get_vhl_layers( vhl_visible_layer, vhl_hidden_layer, vhl_text_layer )

	IGRushort *vhl_visible_layer, *vhl_hidden_layer, *vhl_text_layer;
#endif

/*
DESCRIPTION
	This function gets the vhl layers in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.get_vhl_layers( vhl_visible_layer,
	                                                         vhl_hidden_layer,
	                                                         vhl_text_layer ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_vhl_layers */


/*--- HSdpb_set_vhl_layers -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_set_vhl_layers( IGRushort vhl_visible_layer,
				     IGRushort vhl_hidden_layer,
				     IGRushort vhl_text_layer )
#else
	IGRint HSdpb_set_vhl_layers( vhl_visible_layer, vhl_hidden_layer, vhl_text_layer )

	IGRushort vhl_visible_layer, vhl_hidden_layer, vhl_text_layer;
#endif

/*
DESCRIPTION
	This function sets the vhl layers in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.set_vhl_layers( vhl_visible_layer,
	                                                         vhl_hidden_layer,
	                                                         vhl_text_layer ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_set_vhl_layers */


/*--- HSdpb_get_render_image_info -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_render_image_info( IGRchar *image_filename,
					     IGRint *width,
					     IGRint *height,
					    IGRchar *device_res,
					    IGRchar *media_size )
#else
	IGRint HSdpb_get_render_image_info( image_filename, width, height, device_res, media_size )

	IGRchar *image_filename;
	IGRint  *width;
	IGRint  *height;
	IGRchar *device_res;
	IGRchar *media_size;
#endif

/*
DESCRIPTION
	This function gets the render image info in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.get_render_image_info( image_filename,
	                                                                width, height,
	                                                                device_res, media_size ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_render_image_info */

/*--- HSdpb_get_render_image_info -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_set_render_image_info( IGRchar *image_filename,
					     IGRint width,
					     IGRint height,
					    IGRchar *device_res,
					    IGRchar *media_size )
#else
	IGRint HSdpb_set_render_image_info( image_filename, width, height, device_res, media_size )

	IGRchar *image_filename;
	IGRint  width;
	IGRint  height;
	IGRchar *device_res;
	IGRchar *media_size;
#endif

/*
DESCRIPTION
	This function sets the render image info in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.set_render_image_info( image_filename,
	                                                                width, height,
	                                                                device_res, media_size ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_set_render_image_info */


/*--- HSdpb_get_last_styles -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_last_styles( IGRuchar *last_shading_style,
				      IGRuchar *last_region_style )
#else
	IGRint HSdpb_get_last_styles( last_shading_style, last_region_style )

	IGRuchar  *last_shading_style, *last_region_style;
#endif

/*
DESCRIPTION
	This function gets the last styles in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.get_last_styles( last_shading_style,
	                                                          last_region_style ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_last_styles */


/*--- HSdpb_set_last_styles -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_set_last_styles( IGRuchar *last_shading_style,
				      IGRuchar *last_region_style )
#else
	IGRint HSdpb_set_last_styles( last_shading_style, last_region_style )

	IGRuchar  *last_shading_style, *last_region_style;
#endif

/*
DESCRIPTION
	This function sets the last styles in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.set_last_styles( last_shading_style,
	                                                          last_region_style ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_set_last_styles */


/*--- HSdpb_get_hplot_info ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_hplot_info( IGRuint *hplot_flags,
				     IGRchar *plot_file,
				     IGRchar *raster_file,
				     IGRchar *text_file,
				     IGRchar *plot_queue,
				   IGRdouble *plot_x_size,
				   IGRdouble *plot_y_size,
				   IGRdouble *plot_scale,
				      IGRint *num_copies,
				     IGRchar *date,
				   IGRdouble *line_width_const,
				      IGRint *max_line_width,
				      IGRint *raster_type )
#else
	IGRint HSdpb_get_hplot_info( hplot_flags, plot_file, raster_file, text_file, plot_queue,
		                     plot_x_size, plot_y_size, plot_scale, num_copies, date,
		                     line_width_const, max_line_width, raster_type )

	IGRuint         *hplot_flags;
	IGRchar         *plot_file;
	IGRchar         *raster_file;
	IGRchar         *text_file;
	IGRchar         *plot_queue;
	IGRdouble       *plot_x_size;
	IGRdouble       *plot_y_size;
	IGRdouble       *plot_scale;
	IGRint          *num_copies;
	IGRchar         *date;
	IGRdouble       *line_width_const;
	IGRint          *max_line_width;
	IGRint          *raster_type;
#endif

/*
DESCRIPTION
	This function gets the HPLOT info from the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.get_hplot_info( hplot_flags, plot_file, raster_file,
	                                                         text_file, plot_queue, plot_x_size,
	                                                         plot_y_size, plot_scale, num_copies,
	                                                         date, line_width_const, 
	                                                         max_line_width, raster_type ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	
	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_hplot_info */


/*--- HSdpb_set_hplot_info ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_set_hplot_info( IGRuint *hplot_flags,
				     IGRchar *plot_file,
				     IGRchar *raster_file,
				     IGRchar *text_file,
				     IGRchar *plot_queue,
				   IGRdouble *plot_x_size,
				   IGRdouble *plot_y_size,
				   IGRdouble *plot_scale,
				      IGRint *num_copies,
				     IGRchar *date,
				   IGRdouble *line_width_const,
				      IGRint *max_line_width,
				      IGRint *raster_type )
#else
	IGRint HSdpb_set_hplot_info( hplot_flags, plot_file, raster_file, text_file, plot_queue,
		                     plot_x_size, plot_y_size, plot_scale, num_copies, date,
		                     line_width_const, max_line_width, raster_type )

	IGRuint         *hplot_flags;
	IGRchar         *plot_file;
	IGRchar         *raster_file;
	IGRchar         *text_file;
	IGRchar         *plot_queue;
	IGRdouble       *plot_x_size;
	IGRdouble       *plot_y_size;
	IGRdouble       *plot_scale;
	IGRint          *num_copies;
	IGRchar         *date;
	IGRdouble       *line_width_const;
	IGRint          *max_line_width;
	IGRint          *raster_type;
#endif

/*
DESCRIPTION
	This function sets the HPLOT info in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.set_hplot_info( hplot_flags, plot_file, raster_file,
	                                                         text_file, plot_queue, plot_x_size,
	                                                         plot_y_size, plot_scale, num_copies,
	                                                         date, line_width_const, 
	                                                         max_line_width, raster_type ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	
	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_set_hplot_info */

/*--- HSdpb_get_place_light_info -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_place_light_info( IGRint *last_light_num,
					  IGRuint *light_flags )
#else
	IGRint HSdpb_get_place_light_info( last_light_num, light_flags )

	IGRint *last_light_num;
	IGRuint *light_flags;
#endif

/*
DESCRIPTION
	This function gets the place light info in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.get_place_light_info( last_light_num, light_flags ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_place_light_info */


/*--- HSdpb_set_place_light_info -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_set_place_light_info( IGRint last_light_num,
					  IGRuint light_flags )
#else
	IGRint HSdpb_set_place_light_info( last_light_num, light_flags )

	IGRint last_light_num;
	IGRuint light_flags;
#endif

/*
DESCRIPTION
	This function sets the place light info in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.set_place_light_info( last_light_num, light_flags ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_set_place_light_info */

/*--- HSdpb_get_display_image_delays -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_get_display_image_delays( IGRdouble *cycle_delays,
					       IGRdouble *frame_delays )
#else
	IGRint HSdpb_get_display_image_delays( cycle_delays, frame_delays )

	IGRdouble *cycle_delays, *frame_delays;
#endif

/*
DESCRIPTION
	This function gets the place light info in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.get_display_image_delays( cycle_delays, frame_delays ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_get_display_image_delays */

/*--- HSdpb_set_display_image_delays -----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdpb_set_display_image_delays( IGRdouble *cycle_delays,
					       IGRdouble *frame_delays )
#else
	IGRint HSdpb_set_display_image_delays( cycle_delays, frame_delays )

	IGRdouble *cycle_delays, *frame_delays;
#endif

/*
DESCRIPTION
	This function sets the place light info in the current module.
*/

	{
	IGRlong sts;

	sts = om$send( msg      = message HSdpb2.set_display_image_delays( cycle_delays, frame_delays ),
	               targetid = HSstatic_dpb2_id,
	               targetos = HSstatic_dpb2_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* HSdpb_set_display_image_delays */

end implementation HSdpb2;

