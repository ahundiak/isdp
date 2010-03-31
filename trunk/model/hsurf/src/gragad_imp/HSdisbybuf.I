
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation HSgragad;

/*

DESCRIPTION

	  This method is used to display element(s) (graphic object)
	which has been formatted for display.  The method
	will push the clip information and matrix information
	on the stack so the strokers can access the information.  Then
	DPdiselem is called.



HISTORY

	Sudha	07/27/93	Modified for BSprototypes ansification

*/


#include <stdio.h>
#include <FI.h>
#include "wl.h"

#include "exdef.h"
#include "exmacros.h"

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "igewinmacros.h"

#include "dpdef.h"
#include "dpmacros.h"
#include "growner.h"
#include "dpstruct.h"
#include "msdef.h"
#include "msmacros.h"
#include "bs.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "dp.h"
#include "godef.h"

#include "hsmacdef.h"
#include "hsmacros.h"
#include "HStl_global.h"

#include "bsparameters.h"
#include "bsxtractpar.h"
#include "bschangepar.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HSlvhl.h"
#include "HSpvhl.h"
#include "hslight.h"
#include "hsurferrpriv.h"
#include "hsurf.h"
#include "hswinmacros.h"
#include "hsmessage.h"
#include "HSe2_mesher.h"
#include "HSplot.h"

/*----------------------------
 *  for functions
 *     HSasap1_present
 *     HSset_active_max_z
 *     HSset_processing_mode
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*--------------------------------
 *  for functions
 *     HSrepaint
 *     display_colortable
 */
 
#include "HSpr_display.h"

/*--------------------------------
 *  for functions
 *     HSinit_activated_completed
 */
 
#include "HSpr_lvhl.h"

/*---------------------------------*/


static IGRdouble	  system_cht;

method DPdisbybuf(
		IGRlong			*msg;
		enum GRdpmode		*mode;
		struct DPele_header	*buffer; 
		IGRlong			*no_elem;
		IGRint			view_ind;
		IGRint			view_ind_type;
		IGRdouble		*view_ind_point )

	{
	extern void	HStile_object();
	IGRdouble	win_cht, win_tol;
	IGRlong		rc;
	static WLuint8 e_p[8] = 
			{ 0xff, 0xff, 0xff, 0xff,
			  0xff, 0xff, 0xff, 0xff };
	IGRint 			sts,i;
	IGRint			quiet_flag;
	struct DP_information	sp_info;
	enum GRdpmode		oldmode;
#if defined( ENV5 )
        WLuint32 base_context;
        struct WLnative_info native_info;
	IGRint num_shades;
        IGRint GPIPE_id;
#endif
 	IGRboolean		display_hline;
	struct DPele_header	*buf; 

	*msg = MSSUCC;
	sts = OM_S_SUCCESS;

	if( !HSwindow_initialized( ME.IGEgragad->gragad.gpipe_id ) )
		goto wrapup0;
		
	ex$disp_flag( flag = &quiet_flag );

	if ( ex$is_batch() || ige$SR_active() || quiet_flag )
		{
		goto wrapup0;
		}

	if ( ( ! (me->gragad.flags & IS_ACTIVE) ) || (me->gragad.flags & DP_DELAY) )
		{
		goto wrapup0;
		}

	if( *mode == GRbdhd || *mode == GRbdhe || *mode == GRbdheo ||
	    *mode == GRbeheo ||  *mode == GRbehd || *mode == GRbehe )
		{
		oldmode = *mode;

 		switch ( oldmode )
			{
			case GRbehd: case GRbehe: case GRbeheo:	*mode = GRbe;	break;

			case GRbdhe:				*mode = GRhe;	break;

			case GRbdheo:				*mode = GRheo;	break;

			case GRbdhd:				*mode = GRbd;	break;
			};

		sts = om$send(	msg = message HSgragad.DPdisbybuf( msg, mode, buffer, no_elem,
								   view_ind, view_ind_type,
								   view_ind_point ),
			 	senderid = my_id,
				targetid = my_id );

		switch ( oldmode )
			{
			case GRbdhd: case GRbehd:	*mode = GRhd;	break;

			case GRbehe:			*mode = GRhe;	break;

			case GRbeheo:			*mode = GRheo;	break;

			case GRbdhe: case GRbdheo:	*mode = GRbd;	break;
			};

		sts = om$send(	msg = message HSgragad.DPdisbybuf( msg, mode, buffer, no_elem,
								   view_ind, view_ind_type,
								   view_ind_point ),
			 	senderid = my_id,
				targetid = my_id );

		*mode = oldmode;
		}
	else
		{
		if( *mode == GRhd || *mode == GRhdo ||
                    *mode == GRhe || *mode == GRheo ||
	            *mode == GRhhd || *mode == GRhhdo )
			display_hline = FALSE;
		else
			{
			display_hline = TRUE;
			}

                if ( display_hline )
                {
                   /* only modes in shading are: GRbd or GRbe */
                   if ( *mode == GRbd )
                   {
                      WLset_drawing_mode( ME.IGEgadget->win_no, WL_BASE_DRAW | WL_HILITE_NOOP );
                   }
                   else
                   {
                      WLset_drawing_mode( ME.IGEgadget->win_no, WL_BASE_ERASE | WL_HILITE_NOOP );
                   }

                }

		/*  NOTE: On 2/10/93, there was not a mask for changing the blend */
		WLset_active_symbology( ME.IGEgadget->win_no, 0, 0, 0xffff, 0, 0 );
		WLset_blendarea( ME.IGEgadget->win_no, e_p, 1 );

		sp_info.gragad = &ME.IGEgragad->gragad;
		sp_info.win_no = ME.IGEgadget->win_no;
		sp_info.is_update = FALSE;
		sp_info.is_fit = FALSE;	
		sp_info.is_hidden_line = display_hline;
		sp_info.hline_info = NULL;
		sp_info.hl_tiler = HStile_object;
		sp_info.view_objid = my_id;
		sp_info.view_osnum = OM_Gw_current_OS;
	
		WLhide_cursor(ME.IGEgadget->win_no,0);

#if defined( ENV5 )
		if( HSusing_GPIPE( ME.IGEgragad->gragad.gpipe_id ) && display_hline )
			{
                        DLget_GPIPE_data( ME.IGEgragad->gragad.gpipe_id, GPIPE_id );
			GPEnableZbuffer( GPIPE_id, 1 ); 
			
                        fprintf( stderr, "HSdisbybuf.I:  Need num_shades\n" );
                        num_shades = 10;

                        WLget_window_base_context( ME.IGEgadget->win_no, &base_context );
                        WLget_native_info( ME.IGEgadget->win_no, base_context, &native_info );
			sh_set_bright_edge_tol( native_info.base_win, 0x80000000, num_shades );
			}
#endif

			
		BSxtractpar( &rc, BSTOLCHRDHT, &system_cht );

		hs$get_shading_tolerance( tolerance = &win_tol );
		HSget_window_based_cht(	&win_cht,
					me->gragad.gpipe_id,
					win_tol,
					me->gragad.dit_clip_range );
					
		if ( win_cht > system_cht )
			BSchangepar( &rc, BSTOLCHRDHT, win_cht );

		HSset_active_max_z( me->gragad.gpipe_id, me->shading_style, FALSE, 5 );
		
		if( (me->shading_style == HS_STYLE_RASTER ||
		    me->shading_style == HS_STYLE_FILLED_RASTER) &&
		    display_hline )
			{
			HSset_processing_mode( HS_PMODE_RHL_SURFACE );
			HSinit_activated_completed();

			buf = buffer;

			for( i=0; i<(*no_elem); i++, buf++ )
				{
				if ( !DPdiselem( msg, buf, mode, &sp_info ) )
					{
					printf("Error in Window's DPdiselem, Error: ");
					*msg = MSFAIL;
					goto wrapup;
					}
				else
					{
					if (*msg != MSSUCC)
						{
						goto wrapup;
						}
					}
				}

			HSset_processing_mode( HS_PMODE_RHL_EDGES );
			HSinit_activated_completed();

			for( i=0; i<(*no_elem); i++, buffer++ )
				{
				if ( !DPdiselem( msg, buffer, mode, &sp_info ) )
					{
					printf("Error in Window's DPdiselem, Error: ");
					*msg = MSFAIL;
					goto wrapup;
					}
				else
					{
					if (*msg != MSSUCC)
						{
						goto wrapup;
						}
					}
				}
			}
		else
			{
			HSset_processing_mode( HS_PMODE_SHADING );

			for( i=0; i<(*no_elem); i++, buffer++ )
				{
				if ( !DPdiselem( msg, buffer, mode, &sp_info ) )
					{
					printf("Error in Window's DPdiselem, Error: ");
					*msg = MSFAIL;
					goto wrapup;
					}
				else
					{
					if (*msg != MSSUCC)
						{
						goto wrapup;
						}
					}
				}
			}

		BSchangepar( &rc, BSTOLCHRDHT, system_cht );


#if defined( ENV5 )
		if( HSusing_GPIPE( ME.IGEgragad->gragad.gpipe_id ) && display_hline )
                        {
			GPEnableZbuffer( GPIPE_id, 0 ); 
                        }
#endif

		if( display_hline )
			{
			HSpaint( 1 );
	                HSredraw_coordinate_system( my_id, *mode, NULL, NULL );
			}
		}
wrapup:
	WLshow_cursor(ME.IGEgadget->win_no);
	WLflush(ME.IGEgadget->win_no);

wrapup0:

	return(sts);
	}

end implementation HSgragad;
