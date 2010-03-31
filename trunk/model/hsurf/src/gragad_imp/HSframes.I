
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation HSgragad;

#include <stdio.h>
#include "FI.h"

#if defined( ENV5 )
#include <gpipe.h>
#endif

#include "wl.h"

#include "OMminimum.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "igecolor.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "igecolmacros.h"
#include "exmacros.h"
#include "exdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "dp.h"
#include "godef.h"

#include "igrdef.h"
#include "igrdp.h"
#include "msdef.h"
#include "hsmsg.h"
#include "griodef.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"

#include "hsmultframes.h"
#include "msmacros.h"
#include "hsemulation.h"
#include "HStl_global.h"
#include "HStl_window.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_element.h"

/*-------------------------
 *  for functions
 *     HSactivate_window
 *     HSset_processing_mode
 *     HSset_status
 *     HSsetup_GPIPE_window
 *     HSsetup_window_lights
 */

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"
#include "HSpr_driver.h"

/*---------------------------*/

%safe
static IGRint                  gpipe_id,transp;
static IGRint                  use_GPIPE = FALSE;
static IGRint                  use_EG = FALSE;
static IGRint                  use_OPENGL = FALSE;
static IGRint                  use_XGL = FALSE;
static IGRboolean              perspective = FALSE;

static struct HS_light_source  global_lights[MAX_LIGHTS];
static struct HS_light_source  ambient_light;
%endsafe


/*--- HScheck_for_RHL --------------------------------------------------------*/

static IGRboolean HScheck_for_RHL( IGRuchar  win_style )

{
   IGRchar  HSmessage[256];
   IGRchar  title_msg[100];

   if ( (win_style == HS_STYLE_RASTER) ||
        (win_style == HS_STYLE_FILLED_RASTER) )
   {
      ex$message( msgnumb = HS_E_NoRHLDynamics,
                  buff    = HSmessage );
      ex$message( msgnumb = HS_W_NoteTitle,
                  buff    = title_msg );
      FI_message_box( FI_CURRENT_SCREEN, -1, -1,
                       title_msg, FI_BLUE, "swiss742", 36.0,
                       HSmessage, FI_BLACK, "swiss742", 18.0,
                       FI_LEFT_JUSTIFIED, 40 );

      return( TRUE );
   }
   return( FALSE );
}  /* HScheck_for_RHL */


/*--- HScheck_for_FEM --------------------------------------------------------*/

static IGRboolean HScheck_for_FEM( void )

{
   IGRchar  HSmessage[256];
   IGRchar  title_msg[100];
   IGRuint  mode;

   hs$get_shading_flags( shading_flags = &mode );

   if (( mode & HS_SHADING_FEM_MESH ) || ( mode & HS_SHADING_FEM_STYLE ))
   {
#if FALSE
      ex$message( msgnumb = HS_E_NoFEMDynamics,
                  buff    = HSmessage );
      ex$message( msgnumb = HS_W_NoteTitle,
                  buff    = title_msg );
      FI_message_box( FI_CURRENT_SCREEN, -1, -1,
                       title_msg, FI_BLUE, "swiss742", 36.0,
                       HSmessage, FI_BLACK, "swiss742", 18.0,
                       FI_LEFT_JUSTIFIED, 40 );
#endif
      return( TRUE );
   }
   return( FALSE );
}  /* HScheck_for_FEM */

/*----method dynamics--------------------------------------------------------*/

method dynamics(IGRlong    *msg;
                IGRdouble  zoom_factor;
                IGRdouble  pan_factor;
                IGRdouble  max_rotate_factor;
                IGRdouble  stroke_scale_factor)

{
   if ( (!HScheck_for_RHL( me->shading_style )) && (!HScheck_for_FEM()) )
   {
      om$send( msg      = message IGEgragad.dynamics( msg,
                                                      zoom_factor,
                                                      pan_factor,
                                                      max_rotate_factor,
                                                      stroke_scale_factor ),
               targetid = my_id,
               mode     = OM_e_wrt_message );
   }

   return( OM_S_SUCCESS );
}


/*----method start_frame-----------------------------------------------------*/

method  start_frame(IGRlong     *msg;
                    IGRint      load_frame;
                    IGRdouble   **buffer;
                    IGRint      *buf_size;
                    IGRint      *gpipe_fb;
                    IGRdouble   **gpipe_fb_buf;
                    IGRint      *gpipe_fb_size;
                    GRobjid     *frame_id;
                    GRspacenum  *frame_osnum)

{
   IGRint   status = TRUE;
   IGRint   fb_buffer_size;

   *msg = MSSUCC;

   if ( HScheck_for_RHL( me->shading_style ) )
   {
      *msg = MSFAIL;
      goto wrapup;
   }

   if ( load_frame )
   {
      HSactivate_window( me->gragad.gpipe_id );
      if (tiling_parms.status != HSSTAT_OK)
      {
         HScheck_status();
         goto wrapup;
      }

      if (!(active_window->type & HShardware_ZB_MASK) )
      {
         /* fb_buffer_size = active_window->fb_buffer_size + 160; */
         fb_buffer_size = HSMAX_FRAME_SIZE;
      }
      else
      {
         fb_buffer_size = HSMAX_FRAME_SIZE;
      }

      /* Pass a NULL ptr instead of mallocing the display buffer here since   */
      /* Tony's code will then do the memory allocation and management for us.*/
      /* However, we must pass the size required for the buffer.              */
      *buffer = NULL;
      *buf_size = fb_buffer_size;
   }

   *gpipe_fb = FALSE;

   *frame_osnum = OM_Gw_TransOSnum_0;

   status = om$construct_and_copy( object  = me,
                                   osnum   = *frame_osnum,
                                   p_objid = frame_id);

   if (!(1 & status))
   {
      om$report_error(sts=status);
      *msg = MSFAIL;
      goto wrapup;
   }

   status = om$change_class( osnum     = OM_Gw_TransOSnum_0,
                             objid     = *frame_id,
                             classname = "HSviewdyn");

   if (!(1 & status))
   {
#ifdef DEBUG
      fprintf(stderr,"HSframes.I:Error in change class\n");
#endif
      *msg = MSFAIL;
      goto wrapup;
   }

wrapup:

   if (!(*msg & 1))
   {
      status = FALSE;
   }

   return(status);
}  /* start_frame */

/*----method display_frames--------------------------------------------------*/

method display_frames( IGRlong    *msg;
                       IGRint     start_frame;
                       IGRint     relative_frame;
                       IGRint     number_of_frames;
                       IGRint     number_of_cycles;
                       IGRint     direction;
                       IGRint     erase;
                       IGRint     rotation_allowed;
                       IGRint     db_allowed;
                       IGRdouble  zoom_factor;
                       IGRdouble  pan_factor;
                       IGRdouble  max_rotate_factor;
                       IGRint     (*func_ptr)();
                       IGRchar    *func_parm )

{
   IGRlong          status;
   IGRint           org_x;
   IGRint           org_y;
   IGRint           ext_x;
   IGRint           ext_y;
   IGRdouble        post_rotation[4][4];
   struct var_list  var_list[2];
   IGRlong          error;
   IGRlong          bytes_returned;
   int              vs_no;
   IGRuchar         far_depth_cue;
   struct WLbounds  bounds;
   WLuint32         context_no;


   *msg = MSSUCC;

   HSset_status( HSSTAT_OK );

   if ( HScheck_for_RHL( me->shading_style ) )
   {
      *msg = MSFAIL;
      goto wrapup;
   }

   WLget_window_bounds( me->win_no, NULL, &bounds );
   org_x = bounds.x;
   org_y = bounds.y;
   ext_x = bounds.x + bounds.width;
   ext_y = bounds.y + bounds.height;

   WLget_window_base_context( me->win_no, &context_no );

   if ( me->gragad.flags & IS_PERSP )
   {
      /* can only get post rotation matrix from perspective views */
      var_list[0].var            = POST_ROTATION;
      var_list[0].var_ptr        = (IGRchar *) post_rotation;
      var_list[0].num_bytes      = sizeof(IGRdouble)*16;
      var_list[0].bytes_returned = &bytes_returned;
      var_list[1].var            = END_PARAM;

      dp$inq_set_gragad( msg          = msg,
                         which_error  = &error,
                         var_list     = var_list,
                         gragad_objid = my_id,
                         osnum        = OM_Gw_current_OS );
   }

   HSset_processing_mode( HS_PMODE_SHADING );

   hs$get_depth_cues( far_depth_cue = &far_depth_cue );

   /* initialize the tiler/display data for this window */
   HSinit_display( me->win_no,
                   me->min_x_dep + org_x,
                   me->min_y_dep + org_y,
                   (me->max_x_dep - me->min_x_dep) + 1,
                   (me->max_y_dep - me->min_y_dep) + 1,
                   &me->gragad,
                   255,
                   far_depth_cue,
                   post_rotation );


#if defined( ENV5 )
   DLget_GPIPE_data( me->gragad.gpipe_id, &gpipe_id );
#endif

   HSactivate_window( me->gragad.gpipe_id );

   if (tiling_parms.status != HSSTAT_OK)
   {
      HScheck_status();
      goto wrapup;
   }

   use_GPIPE = active_window->type & HShardware_LB_GPIPE;
   use_EG = active_window->type & HShardware_LB_EG;
   use_OPENGL = active_window->type & HShardware_LB_OPENGL;
   use_XGL    = active_window->type & HShardware_LB_XGL;

#if 0
   printf("use_XGL = %d, use_OPENGL = %d, use_EG = %d, use_GPIPE = %d\n",
		use_XGL, use_OPENGL, use_EG, use_GPIPE );
#endif

   hs$get_global_lights( lights        = global_lights,
                         ambient_light = &ambient_light );

   db_allowed = TRUE;

#if defined( ENV5 )
   if ( use_GPIPE )
   {
      GPSetZclip( gpipe_id, TRUE, TRUE );
   }
#endif

   status = om$send( mode     = OM_e_wrt_message,
                     msg      = message IGEgragad.display_frames(
                                                             msg,
                                                             start_frame,
                                                             relative_frame,
                                                             number_of_frames,
                                                             number_of_cycles,
                                                             direction,
                                                             erase,
                                                             rotation_allowed,
                                                             db_allowed,
                                                             zoom_factor,
                                                             pan_factor,
                                                             max_rotate_factor,
                                                             func_ptr,
                                                             func_parm ),
                     targetid = my_id );

wrapup:

   status = (*msg & 1);

   return(status);

}  /* display_frames */


/*----method display_frame---------------------------------------------------*/

method display_frame(IGRdouble *frame ; IGRint erase )

{
   register IGRint  *frame_ptr;
   IGRint           transparency_grid;
   IGRdouble        fit_range[6];
   IGRdouble        xs;
   IGRdouble        ys;
   IGRdouble        zs;
   IGRlong          frame_size;
   IGRlong          frame_type;
   IGRlong          db_flag;
   IGRdouble        post_rotation[4][4];
   struct var_list  var_list[2];
   IGRlong          error;
   IGRlong          msg;
   IGRlong          bytes_returned;

   frame_ptr = (IGRint *)frame;

   if ( frame_ptr == NULL )
   {
      fprintf(stderr,"display_frame method: Null frame_ptr encountered\n");
      goto wrapup;
   }

   frame_size = (*frame_ptr) >> 2;
   frame_type = (*frame_ptr)&HLINE_MASK;
   db_flag    = (*frame_ptr)&DB_FLAG_MASK;

   frame_ptr += 1;

   if ( ( ( (*frame_ptr) & EDGEII_BUFFER_MASK ) && 
	!( (use_EG || use_OPENGL|| use_XGL) )) ||
        ( !((*frame_ptr)&EDGEII_BUFFER_MASK) && ( 
	(use_EG || use_OPENGL || use_XGL) )) )
   {
      fprintf( stderr,"HSframes.I: Incompatible buffers, cannot");
      fprintf( stderr," display frame\n" );
      goto wrapup;
   }

   if ( frame_type != HSHLINE_FRAME )
   {
      fprintf(stderr,"The frame type indicates a non-shaded frame.\n");
      goto wrapup;
   }

   /* skip past frame header to start of data */
   frame_ptr += 3;

   WLset_drawing_mode( me->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );

   /* Set the transparency for the window from global flags  */
   HSget_trans_grid( &transparency_grid );

   transp = (transparency_grid == HS_GRID_NARROW ) ? 1 : 2;

   /* Get the fit_range of all objects in the window needed for hsurf display */
   /* code                                                                    */
   HSget_top_range( fit_range );

   /* Set the perspective flag */
   perspective = ( me->gragad.flags & IS_PERSP );

   /* Check for presence of FPE and enable z buffering */
   if ( use_GPIPE )
   {
#if defined( ENV5 )
      GPEnableZbuffer( gpipe_id, 1 );
      GPInitZbuffer( gpipe_id, 0x7FFFFFFF );

      if ( ! perspective )
      {
         HSsetup_GPIPE_window( me->gragad.dit_clip_range,
                               me->gragad.wld_to_viewport,
                               me->gragad.eye_pt );
      }
      else
      {
         HSsetup_GPIPE_window( me->gragad.dit_clip_range,
                               me->gragad.wld_to_view,
                               me->gragad.eye_pt );
      }

      HSsetup_window_lights( global_lights, &ambient_light );

      HSdisplay_fb_FPE( frame_ptr,
                        me->gragad.gpipe_id,
                        0,transp,
                        me->win_no,
                        me->min_x_dep,
                        me->min_y_dep,
                        me->max_x_dep,
                        me->max_y_dep,
                        me->gragad.wld_to_viewport,
                        me->gragad.dit_clip_range,
                        fit_range,
                        erase );
#endif
   } /* end of use_GPIPE */
   else if ( use_EG )
   {
#if defined( ENV5 )
      HSdisplay_fb_EDGEII( frame_ptr,
                           me->gragad.gpipe_id,
                           me->gragad.wld_to_view,
                           me->gragad.vw_volume,
                           me->gragad.rotation,
                           me->gragad.wld_to_viewport,
                           global_lights,
                           &ambient_light,
                           me->gragad.eye_pt,
                           me->gragad.vrp,
                           me->gragad.vpn,
                           me->gragad.vup );
#endif
   }
   else if ( use_OPENGL )
   {
#if defined( OPENGL )
      HSdisplay_fb_OPENGL( frame_ptr,
                           me->gragad.gpipe_id,
                           me->gragad.wld_to_view,
                           me->gragad.vw_volume,
                           me->gragad.rotation,
                           me->gragad.wld_to_viewport,
                           global_lights,
                           &ambient_light,
                           me->gragad.eye_pt,
                           me->gragad.vrp,
                           me->gragad.vpn,
                           me->gragad.vup );
#endif
   }
   else if ( use_XGL )
   {
#if defined( XGL )
      HSdisplay_fb_XGL(    frame_ptr,
                           me->gragad.gpipe_id,
                           me->gragad.wld_to_view,
                           me->gragad.vw_volume,
                           me->gragad.rotation,
                           me->gragad.wld_to_viewport,
                           global_lights,
                           &ambient_light,
                           me->gragad.eye_pt,
                           me->gragad.vrp,
                           me->gragad.vpn,
                           me->gragad.vup );
#endif
   }
   else
   {
      if (perspective)
      {
         /* can only get post rotation matrix from perspective views */
         var_list[0].var            = POST_ROTATION;
         var_list[0].var_ptr        = (IGRchar *) post_rotation;
         var_list[0].num_bytes      = sizeof(IGRdouble)*16;
         var_list[0].bytes_returned = &bytes_returned;
         var_list[1].var            = END_PARAM;

         dp$inq_set_gragad( msg          = &msg,
                            which_error  = &error,
                            var_list     = var_list,
                            gragad_objid = my_id,
                            osnum        = OM_Gw_current_OS );

         xs=post_rotation[0][0];
         ys=post_rotation[1][1];
         zs=post_rotation[3][2];

         HSdisplay_fb_NOFPE( frame_ptr,
                             me->gragad.gpipe_id,
                             me->gragad.wld_to_view,
                             me->gragad.rotation,
                             me->gragad.dit_clip_range,
                             me->min_x_dep,
                             me->min_y_dep,
                             me->max_x_dep,
                             me->max_y_dep,
                             global_lights,
                             &ambient_light,
                             me->gragad.eye_pt,
                             fit_range,
                             xs,
                             ys,
                             zs,
                             &perspective,
                             erase );
      }
      else
      {
         xs=ys=zs=1.0;
         HSdisplay_fb_NOFPE( frame_ptr,
                             me->gragad.gpipe_id,
                             me->gragad.wld_to_viewport,
                             me->gragad.rotation,
                             me->gragad.dit_clip_range,
                             me->min_x_dep,
                             me->min_y_dep,
                             me->max_x_dep,
                             me->max_y_dep,
                             global_lights,
                             &ambient_light,
                             me->gragad.eye_pt,
                             fit_range,
                             xs,
                             ys,
                             zs,
                             &perspective,
                             erase );
      }
   }
wrapup:

#if defined( ENV5 )
   if ( use_GPIPE )
   {
      GPEnableZbuffer(gpipe_id,0);
   }
#endif

   return(1);

}  /* display_frame */


/*----method HSdraw_grid-----------------------------------------------------*/

method HSdraw_grid( IGRlong *msg )

{
   struct DPdit_range  range;
   struct DPdit_range  *ditrng;
   IGRlong             status;

   range.xlo = me->min_x_dep;
   range.ylo = me->min_y_dep;

   range.xhi = me->max_x_dep;
   range.yhi = me->max_y_dep;

   ditrng = &range;

   status = om$send( mode     = OM_e_wrt_object,
                     msg      = message IGEgragad.DPgriddraw( msg, ditrng ),
                     senderid = my_id,
                     targetid = my_id);

   if ( !(1&status) )
   {
      printf("GRwn send to DPgriddraw error\n");
      om$report_error(sts = status);
   }

   return( OM_S_SUCCESS );
}  /* HSdraw_grid */

end implementation HSgragad;
