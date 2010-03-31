/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $

HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification


*/

class implementation HSgragad;

#include <stdio.h>
#include <FI.h>
#include "wl.h"

#if defined( ENV5 )
  #include <EG.h>
#endif

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "exdef.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "msmacros.h"

#include "bstypes.h"
#include "bsparameters.h"
#include "bsxtractpar.h"
#include "bschangepar.h"

#include "growner.h"
#include "dpstruct.h"
#include "bs.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "dp.h"
#include "godef.h"

#include "csdef.h"
#include "csmacros.h"

#include "grdpbdef.h"
#include "GRdpbfunc.h"
#include "GRsetinq.h"
#include "grdpbmacros.h"

#include "hsmsg.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hsdef.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_element.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "hslight.h"
#include "hsurferrpriv.h"
#include "hsurf.h"
#include "hswinmacros.h"
#include "hsmessage.h"
#include "HSe2_mesher.h"
#include "HSlvhl.h"
#include "HSpvhl.h"
#include "HSplot.h"

/*----------------------------
 *  for functions
 *     HSactivate_window
 *     HSasap1_present
 *     HScheck_hardware_support
 *     HSget_region_hardware_type
 *     HSget_region_original_style
 *     HSget_region_style
 *     HSget_region_update
 *     HSget_region_xy_minmax
 *     HSinit_shading_window
 *     HSinitialize_buffer
 *     HSset_active_max_z
 *     HSset_ele_clip_range
 *     HSset_paint_offset
 *     HSset_processing_mode
 *     HSset_resion_hardware_type
 *     HSset_region_window_dits
 *     HSset_status
 *     HSset_window_object_info
 */
 
#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

/*----------------------------
 *  for functions
 *     HSpaint
 *     display_colortable
 */
 
#include "HSpr_display.h"

/*----------------------------
 *  for function
 *     HSinit_activated_completed
 */
 
#include "HSpr_lvhl.h"

/*----------------------------
 *  for functions
 *     HSdisplay_update_message
 *     HSpix_count
 */

#include "HSpr_co_func.h"
#include "HSpr_gragad.h"

/*----------------------------*/

extern IGRboolean DPdynamic_update_in_progress;

static IGRboolean	  static_erase;
static IGRdouble	  system_cht;
static struct DPdit_range dit_range;

#define	DEBUG_RANGE_TEST	0
#define DEBUG_DISPLAY_REGION    0


from GRgraphics import GRdisyourself;

/*---HSredraw_coordinate_system--------------------------------------------------*/

/*
NAME
	HSredraw_coordinate_system (static)
DESCTIPION
	Sends a display yourself message to the active coordinate system
	
ARGUMENTS
	my_id: object id of the caller
	orig_mode: the original display mode
	buffer: array of objid's that were part of single element display.  If
	        The coordinate system was part of this, and the mode is delete
	        then don't do anything
	num_oids: number of objid's in buffer
	
HISTORY
	7/23/93		M. Lanier
		Created
*/

void	HSredraw_coordinate_system( GRobjid my_id, enum GRdpmode orig_mode, struct GRid *buffer, IGRlong *no_oids )

{

   IGRlong		msg;
   GRobjid		cs_objid;
   IGRint		num_byte, byte_rcvd;
   struct GRmd_env	mod;
   IGRint		sts, i;
   enum GRdpmode	mode;
   struct DP_information	dp_info;
   struct var_list gad_list[2];
   struct gragad_inst gadget;
   IGRlong error;
   IGRlong return_bytes;
   extern void		HStile_object();

   gad_list[0].var = GRAGAD_INST_STRUCT;
   gad_list[0].var_ptr = (IGRchar *)&gadget;
   gad_list[0].num_bytes = sizeof(struct gragad_inst);
   gad_list[0].bytes_returned = &return_bytes;
   gad_list[1].var = END_PARAM;

   sts = dp$inq_set_gragad(msg = &msg, which_error = &error, 
      var_list = gad_list, gragad_objid = my_id,
      osnum = OM_Gw_current_OS);

   mode = GRbd;
   cs$get_active_info( msg = &msg, objid = &cs_objid );
   
   if ( buffer != NULL && orig_mode == GRbe )
   {
      for ( i=0; i < (*no_oids); i++, buffer++ )
      {
         if ( buffer->objid == cs_objid ) 
         { 
            return;
         }
      }
   }
   
   gr$get_module_env( msg = (IGRint *)&msg,
   	              sizbuf = &num_byte,
   	              buffer = (IGRchar *)&mod,
   	              nret = &byte_rcvd );
   
   dp_info.gragad = &gadget.gragad;
   dp_info.win_no = gadget.win_no;
   dp_info.is_update = TRUE;
   dp_info.is_fit = FALSE;
   dp_info.is_hidden_line = TRUE;
   dp_info.hline_info = NULL;
   dp_info.hl_tiler = HStile_object;
   dp_info.view_objid = my_id;
   dp_info.view_osnum = OM_Gw_current_OS;
   
   sts = om$send( mode = OM_e_wrt_object,
   	          msg = message GRgraphics.GRdisyourself( 
   	             &msg, 
   	             &mod.md_env.matrix_type,
   		     mod.md_env.matrix,
          	     &mode,
          	     NULL,
           	     &dp_info,
   	             0 ),
   	          senderid = my_id,
   	          targetid = cs_objid,
   	          targetos = OM_Gw_current_OS );

}

#define XGL_LOG 0
#if XGL_LOG
FILE    *xgl_log;
#endif

/*---DPgen_update------------------------------------------------------------------*/

method DPgen_update(	IGRlong			*msg; 
			struct DPdit_range	*range; 
			IGRboolean		*update_all; 
			enum GRdpmode		mode; 
			IGRboolean		erase)

/*
NAME
	HSgragad.DPgen_update

DESCRIPTION
	Update method for window

PARAMETERS
	msg (OUT) - status return
	range (IN) - the range, in dits, to be updated; can be NULL
	update_all (IN) - TRUE, if it is an update all request
	mode (IN) - display mode
	erase (IN) - if TRUE, the window should be erased

GLOBALS USED
	active_window
	tiling_parms
	static_erase (static)
	system_cht (static)
	dit_range (static)

HISTORY
	xx/xx/xx   Unknown Programmer
	   Creation Date
	02/24/92   S.P. Rogers
	   Added prologue comment and setting of "image_buffer_valid" field
	   of the active window structure
        01/03/95   Tim Fox
           Turned off the Z buffer in the case of a shaded window with a wireframe
           display region.
*/

{
	IGRint			sts;
	IGRint			quiet_flag;
	IGRlong			rc;
	IGRshort		prev_state;
	IGRint			x_dits, y_dits;
	WLuint16		lscreen_no;
	IGRboolean		wire_window=TRUE,rhl_window=FALSE,shd_window=FALSE;
	IGRboolean		wire_region=TRUE,rhl_display,shd_display,hwzbuf=FALSE;
	IGRboolean		rhl_region,shd_region;
	IGRboolean		region_update=FALSE;
	IGRint			orig_style,style;
	IGRint			xlo,ylo,xhi,yhi;
	IGRint			type;
	IGRboolean		ignore_locked_zbuffer=TRUE;
	IGRlong                 vol_msg = MSSUCC;
	IGRint			raster_offset=0;
        IGRdouble               viewport_to_world[16];
        IGRboolean              z_buffer_deactivated;
	IGRint                  return_value;

#if defined( X11 )
#if defined( XGL )
        Xgl_object xgl_context_3D, hl_xgl_context_3D;
#endif
#endif

	/*
	 *  Initialize a few things
	 */
	
#if XGL_LOG
xgl_log = fopen( "xgl.log", "w" );
#endif
 
	sts = OM_S_SUCCESS; 
	static_erase = erase;

	/* set tiler status to OK */
	HSset_status( HSSTAT_OK );

	ex$disp_flag( flag = &quiet_flag );

	if ( ex$is_batch() || ige$SR_active() || quiet_flag )
	{
		goto wrapup0;
	}

	if ( ! (me->gragad.flags & (IS_ACTIVE | DP_DELAY) ) )
	{
		goto wrapup0;
	}

	HSget_region_update( &region_update );

	HSactivate_window( me->gragad.gpipe_id );

	rhl_display = (me->shading_style == HS_STYLE_RASTER || me->shading_style == HS_STYLE_FILLED_RASTER);
	shd_display = (me->shading_style == HS_STYLE_SMOOTH || me->shading_style == HS_STYLE_CONSTANT);

	if (region_update)
	{
		HSget_region_style( &style );
		HSget_region_original_style( &orig_style );
		x_dits = (me->max_x_dep - me->min_x_dep) + 1;
		y_dits = (me->max_y_dep - me->min_y_dep) + 1;
		HSset_region_window_dits( x_dits, y_dits );
		wire_region = (style == HS_STYLE_WIREFRAME);
		shd_region = (style==HS_STYLE_SMOOTH) || (style==HS_STYLE_CONSTANT);
		rhl_region = !(shd_region || wire_region);
		wire_window = (orig_style == HS_STYLE_WIREFRAME);
		shd_window = (orig_style==HS_STYLE_SMOOTH)||
			(orig_style==HS_STYLE_CONSTANT);
		rhl_window =!(shd_window||wire_window);

		HSget_region_hardware_type( &type );
		hwzbuf=(type&HShardware_ZB_MASK)?1:0;
		HSget_region_xy_minmax(&xlo,&ylo,&xhi,&yhi);
#if DEBUG_DISPLAY_REGION
                printf("HSgragad_IGEgragad_DPgen_update_method\n");
                if (wire_window) printf("Wire window    (%d)",orig_style);
                if (shd_window)  printf("Shading window (%d)",orig_style);
                if (rhl_window)  printf("Raster window  (%d)",orig_style);
                if (wire_region) printf("Wire region    (%d)",style);
                if (shd_region)  printf("Shading region (%d)",style);
                if (rhl_region)  printf("Raster region  (%d)",style);
                printf("hwzbuf = %d ",hwzbuf);
                printf("Window dits: x = %d y = %d\n",x_dits,y_dits);
                printf("Region: xlo = %d\tylo = %d\txhi = %d\tyhi = %d\n",xlo,ylo,xhi,yhi);
                printf("me->gragad.dit_clip_range:\nxlo = %4f\tylo = %4f\txhi = %4f\tyhi = %4f\n",
                   me->gragad.dit_clip_range[0],me->gragad.dit_clip_range[1],
                   me->gragad.dit_clip_range[3],me->gragad.dit_clip_range[4]);
#endif


            /* need to temporarily turn off the Z-buffer for wireframe display region.
               Once region has been updated need to turn it back on again.*/

               z_buffer_deactivated = FALSE;

#if defined( ENV5 )

               if ( region_update && shd_window && wire_region)
                  {
                    if (active_window->type & HShardware_LB_EG)
                      {
                         return_value = EGSetZBufferMode(active_window->EG_vc_no, EG_OFF);
                         z_buffer_deactivated = TRUE;
                      }
                  }
#endif

#if defined ( OPENGL )

                if ( region_update && shd_window && wire_region)
                  {
                    if (active_window->type & HShardware_LB_OPENGL)
                       {
                         glDisable(GL_DEPTH_TEST);
                         z_buffer_deactivated = TRUE;
                       }
                  }
#endif

#if defined( X11 )
#if defined( XGL )

                if ( region_update && shd_window && wire_region)
                  {
                     WLxgl_get_window_contexts( active_window->win_no, 
                              &xgl_context_3D, 
                              &hl_xgl_context_3D );

                     active_window->xgl_context_3D = xgl_context_3D;

                     xgl_object_set( xgl_context_3D, 
                         XGL_3D_CTX_HLHSR_MODE, XGL_HLHSR_NONE, 0 );

                     z_buffer_deactivated = TRUE;
                  }
#endif
#endif


		if(wire_region&&HSusing_GPIPE( me->gragad.gpipe_id ))
		{
			sts = om$send(mode = OM_e_wrt_message,
                             msg = message IGEgragad.DPcal(&vol_msg),
                             senderid = my_id,
                             targetid = my_id);
		}

		if (wire_region)
		{
		   om$send( mode = OM_e_wrt_message,
				  msg = message IGEgragad.DPgen_update( 
				  msg,
				  range, 
				  update_all, 
				  mode,
				  erase ),
				  targetid = my_id );

                   /*now turn the Z buffer back on*/

#if defined( ENV5 )
                   if ((active_window->type & HShardware_LB_EG) && z_buffer_deactivated == TRUE)
                       return_value = EGSetZBufferMode(active_window->EG_vc_no, EG_ON);
#endif

#if defined ( OPENGL )
                    if ((active_window->type & HShardware_LB_OPENGL) 
                          && z_buffer_deactivated == TRUE)
                       glEnable(GL_DEPTH_TEST);
#endif

#if defined( X11 )
#if defined( XGL )
                  if (z_buffer_deactivated == TRUE)
                    xgl_object_set(xgl_context_3D, XGL_3D_CTX_HLHSR_MODE, XGL_HLHSR_Z_BUFFER, 0);
#endif
#endif

#if XGL_LOG
fprintf( xgl_log, "0\n" );
fclose( xgl_log );
#endif

	           return(1);
		}

		if ((hwzbuf&&rhl_region&&shd_window)||
		            (rhl_region&&wire_window))
		{
			/* when you are allocating a region size zbuffer and
			   are drawing a raster region, there will be 1 row
			   of pixels added all the way around the zb and cb.
			   (so comparisons of neighbors around the edge do 
			   not cause a memory fault).  To compensate for this
			   You have to make the region bigger by 4 bytes
			   and paint in 4 bytes (put line has to be 32 bit
			   alligned */
			raster_offset=3;
		} else  raster_offset=0;
#if DEBUG_DISPLAY_REGION
                printf("raster_offset = %d\n",raster_offset);
#endif
		
		if ((hwzbuf&&!rhl_window&&rhl_region)||(!hwzbuf&&wire_window))
		{
			/* set paint offsets if not using HSset_ele_clip_range
			   or you are reusing a virtual zbuffer */
#if DEBUG_DISPLAY_REGION
                        printf("about to HSset_paint_offset(%d,%d)\n",xlo,ylo);
#endif
			HSset_paint_offset(xlo,ylo);
		}

		ignore_locked_zbuffer=active_window->ignore_locked_zbuffer;
	}

	if ( range == NULL )
	{
	   dit_range.xlo = ME.IGEgadget->min_x_dep;
	   dit_range.ylo = ME.IGEgadget->min_y_dep;
	   dit_range.xhi = ME.IGEgadget->max_x_dep;
	   dit_range.yhi = ME.IGEgadget->max_y_dep;
	}
	else
	{
	   memcpy( &dit_range, range, sizeof( struct DPdit_range ) );
	}
#if DEBUG_DISPLAY_REGION
        printf("dit_range: xlo = %d\tylo = %d\txhi = %d\tyhi = %d\n",
           dit_range.xlo,dit_range.ylo,dit_range.xhi,dit_range.yhi);
#endif

	/*
	 *  Display the updating message, then turn off messages so that
	 *  the message IGEgragad.DPgen_update will not overwrite it.
	 */

	WLget_window_screen( me->win_no, &lscreen_no );

	HSdisplay_update_message( me->shading_style );

	HSset_active_max_z( me->gragad.gpipe_id, me->shading_style, FALSE, 5 );

	/*
	 *  Check to see if the window has memory allocated for the z and
	 *  image buffers.  Cant shade if it doesnt.
	 */
	if ((region_update)&&((!wire_region&&wire_window)||
		(hwzbuf&&rhl_region&&shd_window)))
	{
		/* mallocing a zbuffer */
		x_dits = (xhi - xlo) + 1 +raster_offset;
		y_dits = (yhi - ylo) + 1;
	}
	else 
	{
		/* reusing buffer will partially initialize in 
		   HSinitialize_buffers */
		x_dits = (me->max_x_dep - me->min_x_dep) + 1;
		y_dits = (me->max_y_dep - me->min_y_dep) + 1;
	}
#if DEBUG_DISPLAY_REGION
        printf("resized Window dits: x = %d y = %d for zbuffer size\n",x_dits,y_dits);
#endif

#	if DEBUG_RANGE_TEST
	HSdebug_range_test_init();
#	endif
	if( HSinit_shading_window(      lscreen_no,
					me->win_no,
					me->gragad.gpipe_id,
					x_dits,
                                        y_dits,
                                        me->shading_style,
                                        my_id,
                                        OM_Gw_current_OS ) )
	{

                HSdlist_start_window_update( me->win_no, me->gragad.gpipe_id );

                /* This sets up the background color and the simulated ramp from the */
                /* object subclassed off of APPuserramp by FEM.  This was moved here to  */
                /* setup once per update instead of once per tile.  Returns if no fem object. */
                HSsetup_fem_simulated_ramp();

		/*  Turn messages off so the wireframe display in progress
		 *  message will not appear.
		 */
                if ( ! DPdynamic_update_in_progress )
                {
		   ms$onoff( msg = msg, prevstate = &prev_state, type = MS_OFF );
                }

		/* extract cht for use by DPupd_app_init */
		BSxtractpar( &rc, BSTOLCHRDHT, &system_cht );

		/*
		 *  Send a message to IGEgragad to update the window.  HS has
		 *  overriden the message DPupd_app_init.  This will set the
		 *  dp_info for shading and initialize the window.
		 */
		 
		WLhide_cursor( me->win_no, 0 );

		/*
		 *  If we are doing rhl display, make two calls to DPget_update,
		 *  else make only one.
		 */
		 
		if( rhl_display )
		{
			/*
			 *  The first pass is to process the surfaces
			 */
			HSset_processing_mode( HS_PMODE_RHL_SURFACE );
			HSinit_activated_completed();

			if (region_update)
			{
				/* will turn back at HSgragad.DPupd_app_init 
				   doesn't hurt to move range */
#if DEBUG_DISPLAY_REGION
                                printf("b range: xlo = %d\tylo = %d\txhi = %d\tyhi = %d\n",
                                   range->xlo,range->ylo,range->xhi,range->yhi);
#endif
				range->xhi =xhi; 
				range->yhi =yhi; 
				range->xlo =xlo-raster_offset;
		 		range->ylo =ylo;
#if DEBUG_DISPLAY_REGION
                                printf("a range: xlo = %d\tylo = %d\txhi = %d\tyhi = %d\n",
                                   range->xlo,range->ylo,range->xhi,range->yhi);
#endif
                                if ((!hwzbuf && wire_window && rhl_region) ||
                                    ( hwzbuf && rhl_region && (wire_window || shd_window)))
                                {
                                /* for reference files, we use the viewport to wld when combining matrices for ranges. */
                                /* since we change the wld_to_viewport in this case we also should change the viewport */
                                /* to world.  We do use the viewport_to_wld earlier in the gen_update.  Save away for */
                                /* Raster hidden line cases we set back between updates.         */
	                           memcpy( viewport_to_world, ME.IGEgragad->gragad.viewport_to_wld, 
                                      sizeof( IGRdouble ) * 16 );
			        }
			}

			om$send( mode = OM_e_wrt_message,
				 msg = message IGEgragad.DPgen_update( 
					msg, 
				 	range, 
				 	update_all, 
				 	mode,
					FALSE ),
			         targetid = my_id );
			     
			    
			/*
			 *  This time process the surface edges.  Set the
			 *  static_erase flag to false so the window will not
			 *  re-initialize
			 */
			 
			static_erase = FALSE;
			HSset_processing_mode( HS_PMODE_RHL_EDGES );
			HSinit_activated_completed();
			
			if (region_update)
			{
                        /* for reference files, we use the viewport to wld when combining matrices for ranges. */
                        /* since we change the wld_to_viewport in this case we also should change the viewport */
                        /* to world.  For Raster hidden line cases we set back between updates.         */

                                if ((!hwzbuf && wire_window && rhl_region) ||
                                    ( hwzbuf && rhl_region && (wire_window || shd_window)))
                                {
	                           memcpy( ME.IGEgragad->gragad.viewport_to_wld, viewport_to_world,
                                      sizeof( IGRdouble ) * 16 );
			        }
			}

			om$send( mode = OM_e_wrt_message,
				 msg = message IGEgragad.DPgen_update( 
					msg, 
				 	range, 
				 	update_all, 
				 	mode,
					FALSE ),
			         targetid = my_id );
		}
		else
		{
			HSset_processing_mode( HS_PMODE_SHADING );

			if (region_update)
			{
			/* will turn back at HSgragad.DPupd_app_init 
			   doesn't hurt to move range */
#if DEBUG_DISPLAY_REGION
                           printf("b range: xlo = %d\tylo = %d\txhi = %d\tyhi = %d\n",
                              range->xlo,range->ylo,range->xhi,range->yhi);
#endif
				 range->xhi =xhi; 
				 range->yhi =yhi; 
				 range->xlo =xlo;
				 range->ylo =ylo;
#if DEBUG_DISPLAY_REGION
                          printf("a range: xlo = %d\tylo = %d\txhi = %d\tyhi = %d\n",
                             range->xlo,range->ylo,range->xhi,range->yhi);
#endif
			}
			    

			om$send( mode = OM_e_wrt_message,
				 msg = message IGEgragad.DPgen_update( 
					msg, 
				 	range, 
				 	update_all, 
				 	mode,
					FALSE ),
			         targetid = my_id );
		}
		
		/* flush the image buffer */

		WLhide_cursor( me->win_no, 0 );
		HSpaint( 1 );
	
                HSredraw_coordinate_system( my_id, mode, NULL, NULL );
		
		/* Reset the cht, because DPupd_app_int might have changed it. */
		BSchangepar( &rc, BSTOLCHRDHT, system_cht );

		WLshow_cursor( me->win_no );
		WLflush( me->win_no );

		/*
		 *  If we are on an FPE workstation, reset the gpipe to not
		 *  zbuffer output.  This will prevent any hiliting or 
		 *  rubberbanding from being zbuffered.
		 */
		 
#if defined( ENV5 )
		if ( HSusing_GPIPE( me->gragad.gpipe_id ))
                {
			GPEnableZbuffer( active_window->gpipe_id, 0 );
                }
#endif

		/*
		 *  Turn messages back on here, too.  This is just in case
		 *  the STOP button was hit during update and the DPupd_app_init
		 *  message (where we usually turn the messages back on) wasn't sent.
		 */
                if ( ! DPdynamic_update_in_progress )
                {
		   ms$onoff( msg = msg, prevstate = &prev_state, type = MS_ON );
                }
	}
	else
	{
		
		/*
		 *  There was not enough memory to shade the window, display
		 *  a message telling so.
		 */
		HSpix_count();
	}

#	if DEBUG_RANGE_TEST
	HSdebug_range_test_info();
#	endif

        if ( ! DPdynamic_update_in_progress )
        {
   	   ex$message( msgnumb = HS_I_DispComplete );
	   ex$message( field=KEYIN_FIELD, in_buff="" );
        }

	/* return the original values of wld_to_viewport back */
	if (region_update)
	{
		if ((hwzbuf&&!rhl_window&&rhl_region)||(!hwzbuf&&wire_window))
		{
			/* set paint offsets back to 0 */
			HSset_paint_offset(0,0);
		}
		if (hwzbuf&&shd_window&&rhl_region)
		{
			/* region code does not change flag so must have already
			   had the virtual buffer */
				(*tiling_parms.zfree)(0,active_window->zbuf);
				active_window->unsupported_zbuffer_allocated = FALSE;
				active_window->zbuf = NULL;
				active_window->cbuf = NULL;
				active_window->zbuf_size = 0;
				active_window->cbuf_size = 0;
				active_window->num_bytes = 0;
		}	
		if (hwzbuf&&(rhl_window||shd_window))
		{
			/* when init shading window changes the functions needed when
			   shading style is transferred back to do things such as
			   repaint after uncollapsed */
			active_window->ignore_locked_zbuffer=ignore_locked_zbuffer;
			if (rhl_window)
			{
				/* init shading rop routines even the dits so zbuff
				   is larger by 1 if even */
				if( active_window->x_dits & 1 ) active_window->x_dits++;
				if( active_window->y_dits & 1 ) active_window->y_dits++;
			}
			x_dits = (me->max_x_dep - me->min_x_dep) + 1;
			y_dits = (me->max_y_dep - me->min_y_dep) + 1;
			HSinit_shading_window(	lscreen_no,
						me->win_no,
						me->gragad.gpipe_id,
						x_dits,
                                                y_dits,
                                                orig_style,
                                                my_id,
                                                OM_Gw_current_OS );
		}
/*		if (HSasap1_present(vs_no)&&shd_region)*/
/*		The fix for Display region view independent text needs this DPcal*/
/*		always to recalculate matrices and clip range*/
		{
			sts = om$send(mode = OM_e_wrt_message,
                        	 msg = message IGEgragad.DPcal(&vol_msg),
 	                        senderid = my_id,
        	                 targetid = my_id);
		}
	
	}

	/* set the image buffer valid field of the active window structure to */
	/* indicate if we can repaint the window if uncovered or uncollapsed  */
	if ( (active_window->type & HShardware_ZB_MASK) || IGEstop() )
	{
		/* image buffer not valid because we have a hardware Z buffer */
		/* or because the stop sign was hit during update             */
		active_window->image_buffer_valid = FALSE;
	}
	else
	{
		active_window->image_buffer_valid = TRUE;
	}

wrapup0:
#if defined( IRIX )
        if ( ! DPdynamic_update_in_progress )
        {
           WLsync_buffers( me->win_no );
        }
#endif

        HSdlist_finish_window_update( me->win_no, me->gragad.gpipe_id );

#if XGL_LOG
fprintf( xgl_log, "0\n" );
fclose( xgl_log );
#endif

	return(sts);

}  /* DPgen_update */


/*---DPupd_app_init------------------------------------------------------------------*/

method DPupd_app_init(	IGRlong			*msg; 
			struct DP_information	*dp_info )

/*
NAME
	HSgragad.DPupd_app_init

DESCRIPTION
	Application specific update intialization method.  This message
	is sent by the IGEgragad.DPgen_update method right before
	it starts the query through the Rtree for display.

PARAMETERS
	msg (OUT) - status return
	dp_info (OUT) - display information structure

GLOBALS USED
	active_window
	static_erase (static)
	system_cht (static)
	dit_range (static)

HISTORY
	xx/xx/xx   Unknown Programmer
	   Creation Date
	02/24/92   S.P. Rogers
	   Added prologue comment
*/

{
	IGRint			sts, status;
	extern void		HStile_object();
	IGRint			org_x, org_y, ext_x, ext_y;
	IGRint			xlo,ylo,xhi,yhi;
	IGRdouble		post_rotation[4][4];
	struct var_list		var_list[2];
	IGRlong			msg1, error;
	IGRlong			bytes_returned;
	IGRshort		prev_state;
	IGRlong			rc;
	IGRdouble		win_cht, win_tol;
	IGRuchar		far_depth_cue;
	IGRboolean		region_update=FALSE;
	IGRint			orig_style,style;
	IGRint			type;
        IGRshort	        dim=4;
        struct WLbounds         win_attr;

	IGRint			raster_offset=0;
	IGRboolean		rhl_display, shd_display;
	IGRboolean		wire_region, rhl_region, shd_region;
        IGRboolean              rhl_window, wire_window=FALSE;
        IGRboolean		shd_window=FALSE, hwzbuf=FALSE;

	rhl_display = (me->shading_style == HS_STYLE_RASTER || me->shading_style == HS_STYLE_FILLED_RASTER);
	shd_display = (me->shading_style == HS_STYLE_SMOOTH || me->shading_style == HS_STYLE_CONSTANT);

	sts = OM_S_SUCCESS; 

	HSget_region_update( &region_update );
	if (region_update)
	{
		HSget_region_style( &style );
		HSget_region_original_style( &orig_style );

		wire_region = (style == HS_STYLE_WIREFRAME);
		shd_region = (style==HS_STYLE_SMOOTH) || (style==HS_STYLE_CONSTANT);
		rhl_region = !(shd_region || wire_region);
		HSget_region_hardware_type( &type );
		wire_window = (orig_style == HS_STYLE_WIREFRAME);
		shd_window = (orig_style == HS_STYLE_SMOOTH)||
			(orig_style == HS_STYLE_CONSTANT);
		rhl_window = !(shd_window||wire_window);
		hwzbuf=(type&HShardware_ZB_MASK)?1:0;
		HSget_region_xy_minmax(&xlo,&ylo,&xhi,&yhi);
#if DEBUG_DISPLAY_REGION
                printf("HSgragad_IGEgragad_DPupd_app_init_method\n");
                if (wire_window) printf("Wire window    (%d)",orig_style);
                if (shd_window)  printf("Shading window (%d)",orig_style);
                if (rhl_window)  printf("Raster window  (%d)",orig_style);
                if (wire_region) printf("Wire region    (%d)",style);
                if (shd_region)  printf("Shading region (%d)",style);
                if (rhl_region)  printf("Raster region  (%d)",style);
                printf("hwzbuf = %d \n",hwzbuf);
#endif
		if (wire_region)
		{
			om$send( mode = OM_e_wrt_message,
				 msg = message IGEgragad.DPupd_app_init( 
					  msg,
					  dp_info ),
				 targetid = my_id );
			return(OM_S_SUCCESS);
		}
		/*
		 *  Set the dp_info structure for hsurf shading
		 */
	 
		if ((rhl_region&&wire_window)||
		    (hwzbuf&&rhl_region&&shd_window))
		{
			/* when you are allocating a region size zbuffer and
			   are drawing a raster region, there will be 1 row
			   of pixels added all the way around the zb and cb.
			   (so comparisons of neighbors around the edge do 
			   not cause a memory fault).  To compensate for this
			   You have to make the region bigger by 4 bytes
			   and paint in 4 bytes (put line has to be 32 bit
			   alligned */
			raster_offset=3;
		} else  raster_offset=0;
#if DEBUG_DISPLAY_REGION
                printf("raster_offset = %d\n",raster_offset);
#endif

		if ((wire_window&&!(hwzbuf&&shd_region))||
			(hwzbuf&&rhl_region&&!rhl_window))
		{
			/* reset the clip range to upper left from the
			   +-3 values of range when not using HSset_ele_clip
			   to clip for you because of paint offset */ 
#if DEBUG_DISPLAY_REGION
                   printf("1b me->gragad.dit_clip_range: xlo = %lf\tylo = %lf\txhi = %lf\tyhi = %lf\n",
                      me->gragad.dit_clip_range[0],me->gragad.dit_clip_range[1],
                      me->gragad.dit_clip_range[3],me->gragad.dit_clip_range[4]);
#endif
  			me->gragad.dit_clip_range[0]=0.0;
			me->gragad.dit_clip_range[1]=0.0;
			me->gragad.dit_clip_range[3]=
				(double) (xhi-xlo+raster_offset);
			me->gragad.dit_clip_range[4]=(double) (yhi-ylo);
#if DEBUG_DISPLAY_REGION
                   printf("1a me->gragad.dit_clip_range: xlo = %lf\tylo = %lf\txhi = %lf\tyhi = %lf\n",
                      me->gragad.dit_clip_range[0],me->gragad.dit_clip_range[1],
                      me->gragad.dit_clip_range[3],me->gragad.dit_clip_range[4]);
#endif
		}
		else	if (hwzbuf&&(!rhl_region||(rhl_region&&rhl_window)))
			{
#if DEBUG_DISPLAY_REGION
                   printf("2b me->gragad.dit_clip_range: xlo = %lf\tylo = %lf\txhi = %lf\tyhi = %lf\n",
                      me->gragad.dit_clip_range[0],me->gragad.dit_clip_range[1],
                      me->gragad.dit_clip_range[3],me->gragad.dit_clip_range[4]);
#endif
				/* HSset_ele_clip range will clip for us
				   so set to entire window even though
				   just updating the window area will be
				   clipped later like reference files */
  				me->gragad.dit_clip_range[0]=me->min_x_dep;
				me->gragad.dit_clip_range[1]=me->min_y_dep;
				me->gragad.dit_clip_range[3]=me->max_x_dep;
				me->gragad.dit_clip_range[4]=me->max_y_dep;
  				me->gragad.dit_clip_range[0]=xlo;
				me->gragad.dit_clip_range[1]=ylo;
				me->gragad.dit_clip_range[3]=xhi;
				me->gragad.dit_clip_range[4]=yhi;
#if DEBUG_DISPLAY_REGION
                   printf("2a me->gragad.dit_clip_range: xlo = %lf\tylo = %lf\txhi = %lf\tyhi = %lf\n",
                      me->gragad.dit_clip_range[0],me->gragad.dit_clip_range[1],
                      me->gragad.dit_clip_range[3],me->gragad.dit_clip_range[4]);
#endif
			}
		
                if ((!hwzbuf && wire_window && (rhl_region || shd_region)) ||
                    ( hwzbuf && rhl_region && (wire_window || shd_window)))
                {
                   /* for reference files, we use the viewport to wld when combining matrices for ranges. */
                   /* since we change the wld_to_viewport in this case we also should change the viewport */
                   /* to world.  We do use the viewport_to_wld earlier in the gen_update though so need to*/
                   /* make change now.  For Raster hidden line cases we set back between updates.         */
                   MAinvmx(msg,&dim,ME.IGEgragad->gragad.wld_to_viewport,ME.IGEgragad->gragad.viewport_to_wld);
                }

	}/*region_update*/
			    
	dp_info->gragad = &me->gragad;
	dp_info->win_no = me->win_no;
	dp_info->is_update = TRUE;
	dp_info->is_fit = FALSE;
	dp_info->is_hidden_line = TRUE;
	dp_info->hline_info = NULL;
	dp_info->hl_tiler = HStile_object;
	dp_info->view_objid = my_id;
	dp_info->view_osnum = OM_Gw_current_OS;
	
 	{
 	struct GRid	twin;
 	
 	twin.objid = my_id;
 	twin.osnum = OM_Gw_current_OS;
 	
	HSset_window_object_info( &twin );
 	}


	/*
	 *  If the static_erase flag is set, then initialize the window.
	 */

	if( static_erase )
	{
		WLget_window_bounds( me->win_no, NULL, &win_attr );
                org_x = win_attr.x;
                org_y = win_attr.y;
                ext_x = win_attr.x + win_attr.width;
                ext_y = win_attr.y + win_attr.height;

		if ( me->gragad.flags & IS_PERSP )
		{

			/* can only get post rotation matrix from perspective views */
			var_list[0].var		   = POST_ROTATION;
			var_list[0].var_ptr	   = (IGRchar *) post_rotation;
			var_list[0].num_bytes	   = sizeof(IGRdouble)*16;
			var_list[0].bytes_returned = &bytes_returned;
			var_list[1].var		   = END_PARAM;

			dp$inq_set_gragad(
				msg		= &msg1, 
				which_error	= &error,
				var_list	= var_list,
				gragad_objid	= my_id,
				osnum		= OM_Gw_current_OS );
		}

		hs$get_depth_cues( far_depth_cue = &far_depth_cue );

		/* erase window if in display_region, will erase region only */
#if DEBUG_DISPLAY_REGION
                printf("about to HSclear_window\n");
#endif
		HSclear_window( me->win_no );

		if ( ME.IGEgragad->gragad.flags & GRID_ON )
		{
			om$send( msg = message 
				IGEgragad.DPgriddraw( msg, &dit_range ),
				 senderid = my_id,
				 targetid = my_id );
		}

		if (region_update&&((wire_window&&!(hwzbuf&&shd_region))||
			(hwzbuf&&shd_window&&rhl_region)))
		{
#if DEBUG_DISPLAY_REGION
                printf("about to HSinit_display xlo = %d ylo = %d xsize = %d ysize = %d\n", 
                   me->min_x_dep + org_x,me->min_y_dep + org_y,xhi - xlo + 1 +raster_offset,yhi - ylo + 1);
#endif
			status = HSinit_display( me->win_no,
				 me->min_x_dep + org_x,
				 me->min_y_dep + org_y,
				 xhi - xlo + 1 +raster_offset,
				 yhi - ylo + 1,
				 &me->gragad, 
				 255, far_depth_cue,
				 post_rotation );
		}
		else
		{
#if DEBUG_DISPLAY_REGION
                printf("about to HSinit_display xlo = %d ylo = %d xsize = %d ysize = %d\n", 
                   me->min_x_dep + org_x,me->min_y_dep + org_y,(me->max_x_dep - me->min_x_dep) + 1,(me->max_y_dep - me->min_y_dep) + 1);
#endif
			status = HSinit_display( me->win_no,
				 me->min_x_dep + org_x,
				 me->min_y_dep + org_y,
				 (me->max_x_dep - me->min_x_dep) + 1,
				 (me->max_y_dep - me->min_y_dep) + 1,
				 &me->gragad, 
				 255, far_depth_cue,
				 post_rotation );
		}
		/* see if ground plane needs to be drawn */
	 	if ( ME.IGEgragad->gragad.flags & DP_GROUND_PLANE )
		{
			DPdraw_ground_plane( my_id, OM_Gw_current_OS, &ME.IGEgragad->gragad );
		}
	}
#if defined( ENV5 )
	else
	{
		if ( HSusing_GPIPE( me->gragad.gpipe_id ))
                {
			GPEnableZbuffer( active_window->gpipe_id, 1 );
                }
	}
#endif


	/*
	 * If possible, increase the cht to a window-based value.
	 * This must be done after HSinit_display().
	 */

	hs$get_shading_tolerance( tolerance = &win_tol );
	HSget_window_based_cht(	&win_cht,
				me->gragad.gpipe_id,
				win_tol,
				me->gragad.dit_clip_range );
					
	if ( win_cht > system_cht )
		BSchangepar( &rc, BSTOLCHRDHT, win_cht );

	/*
	 *  Turn messages back on so any message from the tiler will be
	 *  displayed.
	 */
	 
        if ( ! DPdynamic_update_in_progress )
        {
	   ms$onoff( msg = msg, prevstate = &prev_state, type = MS_ON );
        }
	 
	return( sts );
} /* DPupd_app_init */


end implementation HSgragad;

