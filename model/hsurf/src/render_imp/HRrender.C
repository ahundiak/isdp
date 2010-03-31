
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 1
#define TIMING 0


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "wl.h"

#include "OMminimum.h"

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"

#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "igr.h"
#include "gr.h"

#include "igrdp.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"

#include "HStl_global.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "hsmachine.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"

#include "msdef.h"
#include "msmacros.h"

#include "hsdef.h"
#include "hsmsg.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hsurferrpriv.h"
#include "hstiler.h"
#include "HSfem_spt.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#if TIMING
#include "sys/types.h"
#include "sys/times.h"
#endif

#include "HSpr_render.h"

/*----------------------------
 *  for functions
 *     CHT
 *     HSinit_shading_window
 *     HSset_rendering_mode
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*-----------------------------
 *  for functions
 *     HSdelete
 *     HSget_window_based_cht
 *     HSinit_display
 *     HSrender_object
 */
 
#include "HSpr_driver.h"

/*--------------------------------
 *  for functions
 *     HSinit_heartbeat
 *     HSupdate_heartbeat
 */
 
#include "HSpr_co_func.h"

/*------------------------------
 *  for function
 *     HSgetMachineInfo
 */
 
#include "hsurf.h"
#include "HSpr_dpb_imp.h"

/*------------------------------*/


/*
 *  Prototype declaration for static functions
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

/* HRrender.C */
static void HRinit_rendering_globals __((	IGRint source_x_dits, 
						IGRint source_y_dits, 
						IGRint dest_wno, 
						IGRint dest_x_dits, 
						IGRint dest_y_dits, 
					    IGRboolean write_to_file, 
					       IGRchar *filename));
					       
static void HRactivate_surfaces __((
			       struct HRsurface_record **surf_list, 
						IGRint pipe_no, 
					     IGRdouble win_cht));
					     

#if defined(__cplusplus)
}
#endif


#undef __

#define FAKE_GPIPE_ID 512

/*--- HRinit_rendering_globals ---------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HRinit_rendering_globals( IGRint source_x_dits,
					      IGRint source_y_dits,
					      IGRint dest_wno,
					      IGRint dest_x_dits,
					      IGRint dest_y_dits,
					  IGRboolean write_to_file,
					     IGRchar *filename )
#else
	static void HRinit_rendering_globals( source_x_dits, source_y_dits,
		                              dest_wno,
		                              dest_x_dits, dest_y_dits,
		                              write_to_file, filename )

	IGRint     source_x_dits, source_y_dits;
	IGRint     dest_wno;
	IGRint     dest_x_dits, dest_y_dits;
	IGRboolean write_to_file;
	IGRchar    *filename;
#endif
/*
DESCRIPTION
	Initialize the globals used by the rendering mode of HSURF

HISTORY
	S.P. Rogers  07/20/89  Creation Date
	S.P. Rogers  03/13/90  Changed to support TRUE COLOR
*/

	{
#if defined( WL_CONVERTED )
	IGRshort        short_colors;
	IGRshort        *red, *green, *blue;
	IGRint          i;
	IGRint          vlt_index;
	IGRint          num_shades;
	IGRint          shades_to_skip;
	IGRint          calc_mode;
	IGRint          vs_no;
	IGRint          term_type;
	struct IGEvlt   vlt[512];
	struct IGEvlt   background;
	IGRuint render_flags;
#ifndef X11
	struct scr_info screen_info[MAX_SCREENS];

	Inq_screen_info( screen_info );
#endif
	WLget_window_screen( dest_wno, (WLuint16 *)&vs_no );

	HSgetMachineInfo( NULL, &term_type, NULL );
	rendering_globals.true_color = ( term_type == EDGEII_TRC );

	rendering_globals.active_traps = NULL;
	rendering_globals.texture_list = NULL;

	rendering_globals.source_x_dits = source_x_dits;
	rendering_globals.source_y_dits = source_y_dits;

	rendering_globals.display_wno = dest_wno;

	rendering_globals.display_x_dits = dest_x_dits;
	rendering_globals.display_y_dits = dest_y_dits;

	hs$get_shading_flags( rendering_flags = &render_flags );
	rendering_globals.use_rgb = render_flags & HS_RENDER_RGB;

	if ( write_to_file )
	   strcpy( rendering_globals.output_file, filename );
	else
	   rendering_globals.output_file[0] = '\0';

	/* initialize surface buckets */
	rendering_globals.surface_buckets.num_buckets = source_x_dits;
	rendering_globals.surface_buckets.min_key1 = 0;
	rendering_globals.surface_buckets.units_per_bucket = 1.0;
	rendering_globals.surface_buckets.double_sort = FALSE;
	rendering_globals.surface_buckets.buckets = (struct HRgeneric_sort_record **) 
	   malloc( sizeof(struct HRgeneric_sort_record *) * rendering_globals.surface_buckets.num_buckets );

	for ( i = 0; i < rendering_globals.surface_buckets.num_buckets; i++ )
	   rendering_globals.surface_buckets.buckets[i] = NULL;

	/* initialize trapezoid buckets */
	rendering_globals.trap_buckets.num_buckets = source_x_dits;
	rendering_globals.trap_buckets.min_key1 = 0;
	rendering_globals.trap_buckets.units_per_bucket = 1.0;
	rendering_globals.trap_buckets.double_sort = TRUE;
	rendering_globals.trap_buckets.buckets = (struct HRgeneric_sort_record **) 
	   malloc( sizeof(struct HRgeneric_sort_record *) * rendering_globals.trap_buckets.num_buckets );
	
	for ( i = 0; i < rendering_globals.trap_buckets.num_buckets; i++ )
	   rendering_globals.trap_buckets.buckets[i] = NULL;

	rendering_globals.env_list = NULL;

	/* set up base color array => NOTE: The colors */
	/* in the base color array range from 0 - 255  */
	hs$get_config( num_colors = &rendering_globals.num_colors,
	               num_shades = &num_shades );
	
	/* Allocate space for base color arrays. Remember to allocate  */
	/* one more than the number of colors because we need to store */
	/* the background color in the base color array too.           */
	rendering_globals.red = red = (IGRshort *) malloc(
	       (rendering_globals.num_colors + 1) * sizeof( IGRshort ) );
	rendering_globals.green = green = (IGRshort *) malloc(
	       (rendering_globals.num_colors + 1) * sizeof( IGRshort ) );
	rendering_globals.blue = blue = (IGRshort *) malloc(
	       (rendering_globals.num_colors + 1) * sizeof( IGRshort ) );

	/* copy the background color into the base color arrays */
	ige$read_reserved_colors( bgcolor = (char *)&background, mod_osnum = (GRspacenum)(2) );
	red[0]  = background.red >> 8;
	green[0]= background.green >> 8;
	blue[0] = background.blue >> 8;

	/* get the colors in the current vlt */
	short_colors = 512;
	ige$read_color_table( num_colors = &short_colors, colors = (char *)vlt );

	/* copy base colors into the global array (skipping shades if necessary) */
 	hs$get_color_table_info( calc_mode = &calc_mode );

	shades_to_skip = (calc_mode == HS_SHADE_CALC_SYSTEM) ? 1 : num_shades;
	for ( vlt_index = 0,i = 1;
	      i <= rendering_globals.num_colors;
	      i++, vlt_index += shades_to_skip )
	   {	
	   red[i]   = vlt[vlt_index].red >> 8;
	   green[i] = vlt[vlt_index].green >> 8;
	   blue[i]  = vlt[vlt_index].blue >> 8;
	   }

#endif
	}  /* HRinit_rendering_globals */


/*--- HRactivate_surfaces -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HRactivate_surfaces( struct HRsurface_record **surf_list,
							  IGRint pipe_no,
						       IGRdouble win_cht )
#else
	static void HRactivate_surfaces( surf_list, pipe_no, win_cht )

	struct HRsurface_record **surf_list;
	IGRint                  pipe_no;
	IGRdouble               win_cht;
#endif

/*
DESCRIPTION
	Activate the surfaces for a given scan line by having them
	tiled and having the resulting trapezoids stored in the
	trapezoid bucket structure.  Before making trapezoids for a surface,
	have the tiler calculate a better range box for the surface to see
	if its activation can be delayed by re-sorting it to another scan line.

HISTORY
	S.P. Rogers  07/20/89  Creation Date
*/

	{
	IGRboolean                        delete_surf, move_surf;
	IGRint                            tiler_min_x;
	IGRdouble	                  world_range[6];
	struct HRsurface_record           *temp_surf;
	struct HRsurface_record           *this_surf;
	struct HRsurface_record           *prev_surf;
	struct HRsurface_record           *next_surf;
	struct IGRbsp_surface             *geom;
	struct HS_element_rendering_parms hs_parms;
	struct HRspecial_rendering_parms  *hr_parms;

	prev_surf = NULL;
	this_surf = *surf_list;

	while ( this_surf )
	   {
	   next_surf = this_surf->next;
	   delete_surf = move_surf = FALSE;
	   rendering_globals.cur_traps_reclaimed = FALSE;
	   rendering_globals.cur_surf = this_surf;

	   /* get the geometry of the surface */
	   HRget_surface_geometry( this_surf, &geom, world_range, win_cht );

	   if ( geom )
	      {
	      /* convert special rendering parms structure to the structure the tiler wants */
	      hr_parms = &this_surf->rend_parms;
	      hs_parms.color = hr_parms->color;
	      hs_parms.finish = hr_parms->finish;
	      hs_parms.spec_refl = hr_parms->spec_refl / (IGRdouble) 0x8000;
	      hs_parms.diff_refl = hr_parms->diff_refl / (IGRdouble) 0x8000;
	      hs_parms.transparency = hr_parms->transparency / (IGRdouble) 0x8000;
	      hs_parms.surface_texture = hr_parms->surface_texture;
	      hs_parms.texture_orientation = hr_parms->texture_orientation;
	 
	      if ( this_surf->resorted_by_tiler )
	         {
	         /* surface has already been re-sorted by tiler => have */
	         /* tiler create trapezoids for it.                     */
	         HSrender_object( geom,
	                          this_surf->objid, this_surf->env->osnum,
	                          world_range,
	                          this_surf->env->clip_range,
	                          &hs_parms,
	                          pipe_no,
	                          FALSE,
	                          NULL,
	                          this_surf->dont_cull );
	         }
	      else
	         {
	         /* try to re-sort surface based on a better range calculated by the tiler */
	         this_surf->resorted_by_tiler = TRUE;

	         HSrender_object( geom,
	                          this_surf->objid, this_surf->env->osnum,
	                          world_range,
	                          this_surf->env->clip_range,
	                          &hs_parms,
	                          pipe_no,
	                          TRUE,
	                          &tiler_min_x,
	                          this_surf->dont_cull );

	         if ( (tiler_min_x == HR_TOSS_SURFACE) || (tiler_min_x >= rendering_globals.source_x_dits) )
	            delete_surf = TRUE;
	         else if ( tiler_min_x > rendering_globals.scan_line )
	            move_surf = TRUE;
	         else
	            {
	            /* create trapezoids for surface because re-sort won't gain anything */
	            HSrender_object( geom,
	                             this_surf->objid, this_surf->env->osnum,
	                             world_range,
	                             this_surf->env->clip_range,
	                             &hs_parms,
	                             pipe_no,
	                             FALSE,
	                             NULL,
	                             this_surf->dont_cull );
	            }  /* end: else */

	         }  /* end: else */

	      /* free the surface geometry */
	      HRfree_surface_geometry( geom );

	      }
	   else
	      delete_surf = TRUE;  /* error getting geometry */

	   if ( delete_surf || move_surf )
	      {
	      /* Remove the surface from the list it is in and adjust this_surf pointer. */
	      /* It is still in the current list because trapezoids were not created for */
	      /* it and, therefore, it couldn't have been moved to another bucket by the */
	      /* trapezoid reclamation functions                                         */
	      temp_surf = this_surf;
	      if ( prev_surf )
	         prev_surf->next = this_surf->next;
	      else
	         *surf_list = this_surf->next;

	      this_surf = this_surf->next;

	      if ( delete_surf )
	         HRfree_surface_record( temp_surf );
	      else
	         {
	         /* move surface to appropriate scan line bucket */
	         temp_surf->next = (struct HRsurface_record *)
	                                 rendering_globals.surface_buckets.buckets[tiler_min_x];
	         rendering_globals.surface_buckets.buckets[tiler_min_x] =
	                                 (struct HRgeneric_sort_record *) temp_surf;
	         }

	      }  /* end: if ( delete_surf || move_surf ) */
	   else
	      {
	      /* move to next surface */
	      if ( ! rendering_globals.cur_traps_reclaimed )
	         {
	         /* this_surf wasn't removed from the list for this bucket because its */
	         /* trapezoids weren't reclaimed => make prev_surf point to it         */
	         prev_surf = this_surf;
	         }
	      this_surf = next_surf; 
	      }

	   }  /* end: while */

	}  /* HRactivate_surfaces */


/*--- HRrender_image -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRrender_image( IGRlong *msg,
			 struct GRid *co_grid,
		     OM_S_CHANSELECT *gschansel,
			     IGRchar *filename,
			      IGRint source_x_dits,
			      IGRint source_y_dits,
			      IGRint dest_wno,
			      IGRint dest_x_dits,
			      IGRint dest_y_dits,
			  IGRboolean write_to_file,
			 struct GRid *source_gragad )
#else
	void HRrender_image( msg, co_grid, gschansel, filename,
		             source_x_dits, source_y_dits,
		             dest_wno, dest_x_dits, dest_y_dits,
			     write_to_file, source_gragad )

	IGRlong         *msg;
	struct GRid     *co_grid;
	OM_S_CHANSELECT *gschansel;
	IGRchar         *filename;
	IGRint          source_x_dits;
	IGRint          source_y_dits;
	IGRint          dest_wno;
	IGRint          dest_x_dits;
	IGRint          dest_y_dits;
	IGRboolean      write_to_file;
	struct GRid     *source_gragad;
#endif

/*
DESCRIPTION
	This function drives the rendering process.

	Parameters:

	   co_grid - the object id and osnum of the object that is connected
	             to the save set (usually a command object)

	   gschansel - channel of the object identified by 'co_grid' that is
	               used to connect to the save set

	   filename  - RLE output file name

	   source_x_dits,
	   source_y_dits  - the size of the image being rendered

	   dest_wno - window number of window that is to display the image

	   dest_x_dits,
	   dest_y_dits  - X and Y dits of the window that is to display the image

	   write_to_file - TRUE, if the image should be written to a file

	   source_gragad - the object id and object space number of the window that
	                   is the source for the rendering, (i.e., the window that
	                   provides the orientation)
HISTORY
	S.P. Rogers 07/07/89  Creation Date
	S.P. Rogers 07/12/91  Changed from a method on HSgragad to a function and
	                      added code to re-calculate gragad instance data based
	                      on image size
*/


	{
	IGRint             vs_no;
	IGRint             org_x, org_y, ext_x, ext_y;
	IGRint             which_error;
	IGRint             screen_scale;
	IGRlong            bytes_returned;
	IGRchar            rendering_string[60];
	IGRdouble          post_rotation[4][4];
	IGRdouble          win_tol, win_cht;
	struct var_list    var_list[2], var_list2[2];
	IGRuchar   far_depth_cue;
	struct gragad_inst gragad_inst, saved_gragad_inst;
#ifdef X11
        XWindowAttributes  win_attr;
#endif
#if TIMING
	struct tms         start_time;
	struct tms         end_time;
	IGRdouble          total_time;

	times( &start_time );
#endif

	*msg = MSSUCC;

	ex$message( msgnumb = HS_I_Rendering, buff = rendering_string );

	HSinit_heartbeat( rendering_string );

	HRinit_rendering_globals( source_x_dits, source_y_dits,
	                          dest_wno,
	                          dest_x_dits, dest_y_dits,
	                          write_to_file, filename );

	/* get all of the instance data of the source gragad */
	var_list[0].var            = GRAGAD_INST_STRUCT;
	var_list[0].var_ptr        = (IGRchar *) &gragad_inst;
	var_list[0].num_bytes      = sizeof( struct gragad_inst );
	var_list[0].bytes_returned = &bytes_returned;
	var_list[1].var            = END_PARAM;

	dp$inq_set_gragad( msg          = msg, 
	                   which_error  = &which_error,
	                   var_list     = var_list,
	                   gragad_objid = source_gragad->objid,
	                   osnum        = source_gragad->osnum );

	   MSG_ERRCHK( *msg, "HSrender_image: dp$inq_set_gragad (inq) failed" );

	/* Save the gragad_inst structure so it can be restored later.  */
	/* I am saving the whole structure instead of just the extents, */
	/* because the image size that is being to be rendered may not  */
	/* be proportional to the original size.  This will result in   */
	/* the view volume changing and restoring the old extents and   */
	/* re-calculating the other data will not restore the instance  */
	/* data back to its original state.                             */
	memcpy( &saved_gragad_inst, &gragad_inst, sizeof( struct gragad_inst ) );

	/* adjust the extents of the source gragad to make it think  */
	/* it is as big as the image that is supposed to be rendered */
	gragad_inst.min_x_dep = 0;
	gragad_inst.min_y_dep = 0;
	gragad_inst.max_x_dep = source_x_dits;
	gragad_inst.max_y_dep = source_y_dits;

	dp$inq_set_gragad( msg          = msg, 
	                   which_error  = &which_error,
	                   inq0_set1    = 1,
	                   calc_info    = TRUE,
	                   var_list     = var_list,
	                   gragad_objid = source_gragad->objid,
	                   osnum        = source_gragad->osnum );

	   MSG_ERRCHK( *msg, "HSrender_image: dp$inq_set_gragad (set) failed" );

	/* re-read newly calculated instance data */
	dp$inq_set_gragad( msg          = msg, 
	                   which_error  = &which_error,
	                   var_list     = var_list,
	                   gragad_objid = source_gragad->objid,
	                   osnum        = source_gragad->osnum );

	   MSG_ERRCHK( *msg, "HSrender_image: dp$inq_set_gragad (inq2) failed" );

	if ( gragad_inst.gragad.flags & IS_PERSP )
	   {
	   /* can only get post rotation matrix from perspective views */
	   var_list2[0].var            = POST_ROTATION;
	   var_list2[0].var_ptr        = (IGRchar *) post_rotation;
	   var_list2[0].num_bytes      = sizeof( IGRdouble ) * 16;
	   var_list2[0].bytes_returned = &bytes_returned;
	   var_list2[1].var            = END_PARAM;

	   dp$inq_set_gragad( msg          = msg, 
	                      which_error  = &which_error,
	                      var_list     = var_list2,
	                      gragad_objid = source_gragad->objid,
	                      osnum        = source_gragad->osnum );
	   }

	/* Use a fake gpipe id so HSURF will allocate a entirely new */
	/* active_window structure instead of possible messing with  */
	/* one that already exists for this window.                  */
	gragad_inst.gragad.gpipe_id = FAKE_GPIPE_ID;

	HRinit_pool_memory_management();
	MMinit_texture_memory();

	/* get the virtual screen and window info */
	WLget_window_screen( gragad_inst.win_no, (WLuint16 *)&vs_no );
#ifdef X11
        /*
        KLUDGE: comment out to resolve compile error on the SGI
        XGetWindowAttributes(EXdisplay, EX_win[gragad_inst.win_no], &win_attr);
        */
        org_x = win_attr.x;
        org_y = win_attr.y;
        ext_x = win_attr.x + win_attr.width;
        ext_y = win_attr.y + win_attr.height;
#else
	Inq_win_region ( gragad_inst.win_no, &org_x, &org_y, &ext_x, &ext_y );
	
#endif
	/* initialize the tiler structures for the window */
	HSset_rendering_mode( TRUE );
	if ( HSinit_shading_window( vs_no,
                                    gragad_inst.win_no,
                                    gragad_inst.gragad.gpipe_id,
                                    0,
                                    0,
                                    HS_STYLE_SMOOTH,
                                    NULL_OBJID,
                                    0) )
	   {
	   HRinit_display_parms( vs_no, &screen_scale );
	   ex$message( msgnumb = HS_I_RenderDispScale, field = KEYIN_FIELD,
	               var = `screen_scale`, type = "%d", justification = CENTER_JUS );
					
	   hs$get_depth_cues( far_depth_cue = &far_depth_cue );

	   HSinit_display( gragad_inst.win_no,
	                   gragad_inst.min_x_dep + org_x,
	                   gragad_inst.min_y_dep + org_y,
	                   (gragad_inst.max_x_dep - gragad_inst.min_x_dep) + 1,
	                   (gragad_inst.max_y_dep - gragad_inst.min_y_dep) + 1,
	                   &(gragad_inst.gragad),
	                   255, far_depth_cue,
	                   post_rotation );

	   /* Initialize Run-Length Encoding File and display parameters */
	   /* must be done before element collection because of textures */
	   if ( write_to_file )
	      {
	      if ( HRinit_rle( rendering_globals.source_x_dits, rendering_globals.source_y_dits,
	                        rendering_globals.output_file ) )
	         write_to_file = FALSE;  /* file create failed */
	      }

	   /* get the surfaces to process from the command object's */
	   /* channel and sort them into the surface buckets        */
	   HRcollect_elements( co_grid, gschansel,
	                       &rendering_globals.surface_buckets,
	                       gragad_inst.gragad.levels );

	   /* Get the window based CHT for this window and */
	   /* the current shading tolerance                */
	   hs$get_shading_tolerance( tolerance = &win_tol );
	   HSget_window_based_cht( &win_cht,
	                           gragad_inst.gragad.gpipe_id,
	                           win_tol,
	                           gragad_inst.gragad.dit_clip_range );

	   /* render image a scan line at a time */
	   for ( rendering_globals.scan_line = 0;
	         rendering_globals.scan_line < rendering_globals.source_x_dits;
	         rendering_globals.scan_line++ )
	      {
	      HSupdate_heartbeat();

	      /* activate the surfaces for this scan line */
	      HRactivate_surfaces( (struct HRsurface_record **) &rendering_globals.surface_buckets.buckets[rendering_globals.scan_line],
	                           gragad_inst.gragad.gpipe_id,
	                           win_cht );

	      /* activate the trapezoids for this scan line */
	      HRactivate_trapezoids( 
	      	(struct HRspan_trapezoid *)rendering_globals.
	      		trap_buckets.buckets[rendering_globals.scan_line] );

	      /* render this scan line */
	      HRprocess_scanline( rendering_globals.scan_line, write_to_file );

	      if ( IGEstop() )
	         break;

	      }  /* end: for */

	   }
	
	HRfree_display_parms();

	if ( write_to_file )
	   HRfini_rle( rendering_globals.scan_line,
	               rendering_globals.source_x_dits, rendering_globals.source_y_dits );
	
	HSdelete( gragad_inst.gragad.gpipe_id );
	HSset_rendering_mode( FALSE );

	/* restore the source gragad's instance data */
	var_list[0].var_ptr = (IGRchar *) &saved_gragad_inst;

	dp$inq_set_gragad( msg          = msg, 
	                   which_error  = &which_error,
	                   inq0_set1    = 1,
	                   calc_info    = TRUE,
	                   var_list     = var_list,
	                   gragad_objid = source_gragad->objid,
	                   osnum        = source_gragad->osnum );

	   MSG_ERRCHK( *msg, "HSrender_image: dp$inq_set_gragad (set) failed" );

	/* free the surface and trapezoid buckets */
	if ( rendering_globals.surface_buckets.buckets )
	   free( (IGRchar *) rendering_globals.surface_buckets.buckets );
	if ( rendering_globals.trap_buckets.buckets )
	   free( (IGRchar *) rendering_globals.trap_buckets.buckets );

	/* free the base color arrays */
	if ( rendering_globals.red )
	   free( (IGRchar *) rendering_globals.red );
	if ( rendering_globals.green )
	   free( (IGRchar *) rendering_globals.green );
	if ( rendering_globals.blue )
	   free( (IGRchar *) rendering_globals.blue );

	HRfree_pool_memory();
	MMfree_texture_memory();

	ex$message( msgnumb = HS_I_RenderingComplete );

#if TIMING
	times( &end_time );
	total_time = ((end_time.tms_stime + end_time.tms_utime) -
                      (start_time.tms_stime + start_time.tms_utime)) / 60.0;

	fprintf( stderr, "\nTotal rendering time = %lf seconds\n", total_time );
#endif

	}  /* HRrender_image */
