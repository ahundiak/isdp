
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
	which has not been formatted for display.  The method
	will push the clip information and matrix information
	on the stack so the strokers can access the information.  Then
	the message is sent to the graphic object to display itself.


HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification
	BBKR	11/20/96	BBKR modified this code for some reference
				file problems.  The following is his
				explanation of what was done and why..
--------------------------------
        Here find the details for the two questions
 
     1. In normal case where all the graphic objects are in the master file
     i.e., osnum=2, we request each graphic object to display itself through 
     the method GRdisyourself. But in the case of assembly, where the graphic
     objects are in the reference files( osnum is different from master),
     it is required to send the requst to each graphic object to display 
     itself thru reference,i.e., by calling the function GRdisthruref().  
 
        In the case of wire framme display for reference files the display
     is thru GRdisthruref(), so I copied the same code for shaded display. 
 
     2. In the case of HSdisbybuf.I it is not required to modified the code, 
     as we are not requesting each object to display itself throuh the 
     method GRdisyourself. 
--------------------------------

*/

#include <stdio.h>
#include <FI.h>

#include "wl.h"

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
#include "hslight.h"
#include "hsurferrpriv.h"
#include "hsurf.h"
#include "hswinmacros.h"
#include "hsmessage.h"
#include "HSe2_mesher.h"
#include "HSlvhl.h"
#include "HSpvhl.h"
#include "HSplot.h"
#include "igecolordef.h"
#include "igecolor.h"

#include "referr.h"
#include "OMindex.h"
struct DPdismsg
{
        IGRlong *msg;
        IGRshort *mx_type;
        IGRdouble *matrix;
        enum GRdpmode *mode;
        struct IGRaltdisplay *alt_symb;
        struct DP_information *dp_info;
        OM_p_KEY_DESC range_key;
};
/* prototype files */
%safe
#include "GRdisthruref.h"
#include "GRcheckref.h"
%endsafe
/*-----------------------------
 *  for functions
 *     HSasap1_present
 *     HSset_active_max_x
 *     HSset_processing_mode
 */
 
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*-------------------------------
 *  for functions
 *     HSrepaint
 *     display_colortable
 */
 
#include "HSpr_display.h"

/*------------------------------
 *  for function
 *     HSinit_activated_completed
 */
 
#include "HSpr_lvhl.h"

/*--------------------------------*/


from GRgraphics import GRdisyourself; 
from IGEwinsup  import pre_single_display, post_single_display;

%safe
static IGRboolean      HSwinsup_chandef_defined = FALSE;
static OM_S_CHANSELECT HSwinsup_chandef;
static IGRdouble       system_cht;
%endsafe

/*---DPdisbyoid------------------------------------------------------------*/

method DPdisbyoid(
		IGRlong 	*msg;
		enum GRdpmode	*mode;
		struct GRid	*buffer; 
		IGRlong		*no_oids;
		IGRshort	*type; 
		IGRmatrix	*matrix[];
		struct IGRaltdisplay	*alt_symb )

	{
	extern void	HStile_object();
	IGRdouble	win_cht, win_tol;
	IGRlong		rc;
        static int	split_mode=FALSE;
        struct GRid	*buffer_top;

	static WLuint8 e_p[8] = 
			{ 0xff, 0xff, 0xff, 0xff,
			  0xff, 0xff, 0xff, 0xff };
	      
	IGRint			sts,i;
	IGRint                  quiet_flag;
	struct GRid		gragad_id, graphic_id;
	struct DP_information 	sp_info;
	OMuint			count;
	enum GRdpmode		oldmode;
        struct DPdismsg         dismsg;
        OM_S_MESSAGE            display_msg; 
	IGRboolean		display_hline=TRUE;


#if defined( ENV5 )
        WLuint32 base_context;
        struct WLnative_info native_info;
        struct IGEcontext_info IGEcontext_info;
	IGRint num_shades;
        IGRint GPIPE_id;
#endif


        *msg = MSSUCC;
        sts = OM_S_SUCCESS;
        buffer_top = buffer;
        system_cht = 0.0;

        /* Bala's  Addition starts */
        BSxtractpar( &rc, BSTOLCHRDHT, &system_cht );
        /* Bala's  Addition ends */


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

	if (( *mode == GRbdhd || *mode == GRbdhe || *mode == GRbdheo ||
	    *mode == GRbeheo ||  *mode == GRbehd || *mode == GRbehe )&&!split_mode)
		{
		oldmode = *mode;
		split_mode = TRUE;
 		switch ( oldmode )
			{/*case GRbeheo: keep the same to override element off */
			case GRbehd: case GRbehe:		*mode = GRbe;	break;

			case GRbdhe:				*mode = GRhe;	break;

			case GRbdheo:				*mode = GRheo;	break;

			case GRbdhd:				*mode = GRbd;	break;
			};

		sts = om$send(	msg = message HSgragad.DPdisbyoid( msg,	mode, buffer, no_oids,
								   type, matrix, alt_symb ),
			 	senderid = my_id,
				targetid = my_id );

		switch ( oldmode )
			{
			case GRbdhd: case GRbehd:	*mode = GRhd;	break;

			case GRbehe:			*mode = GRhe;	break;

			case GRbeheo:			*mode = GRheo;	break;

			case GRbdhe: case GRbdheo:	*mode = GRbd;	break;
			};

		sts = om$send(	msg = message HSgragad.DPdisbyoid( msg,	mode, buffer, no_oids,
								   type, matrix, alt_symb ),
			 	senderid = my_id,
				targetid = my_id );

		split_mode = FALSE;
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

		if ( ! HSwinsup_chandef_defined )
			{
			 om$make_chanselect(
				channame     = "IGEgragad.winsup", 
				p_chanselect = &HSwinsup_chandef);

			HSwinsup_chandef_defined = TRUE;
			}
			
		sts = om$get_channel_count(
				objid        = my_id, 
				p_chanselect = &HSwinsup_chandef, 
				count        = &count);

		if (!(sts & 1))
			{
			om$report_error(sts = sts);
			goto wrapup;
			}

		gragad_id.objid = my_id;
		gragad_id.osnum = OM_Gw_current_OS;

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
                        DLget_GPIPE_data( ME.IGEgragad->gragad.gpipe_id, &GPIPE_id );
			GPEnableZbuffer( GPIPE_id, 1 ); 
			
                        WLget_window_base_context( ME.IGEgadget->win_no, &base_context );
                        IGEload_context( base_context, &IGEcontext_info);
                        num_shades = IGEcontext_info.num_ramp_shades;
                        WLget_native_info( ME.IGEgadget->win_no, base_context, &native_info );
			sh_set_bright_edge_tol( native_info.base_win, 0x80000000, num_shades );
			}
#endif
			

/*
	    Commented out by Bala
		BSxtractpar( &rc, BSTOLCHRDHT, &system_cht );
*/

		hs$get_shading_tolerance( tolerance = &win_tol );
		HSget_window_based_cht(	&win_cht,
					me->gragad.gpipe_id,
					win_tol,
					me->gragad.dit_clip_range );
					
		if ( win_cht > system_cht )
			BSchangepar( &rc, BSTOLCHRDHT, win_cht );

		for( i=0; i<(*no_oids); i++, buffer++, type++, matrix++ )
			{
			if (count)
				{	
				graphic_id = *buffer;
	
				sts = om$send(
					msg          = message IGEwinsup.pre_single_display(
									msg, 
									&gragad_id, 
									&graphic_id ), 
					senderid     = my_id, 
					p_chanselect = &HSwinsup_chandef );
	
				/* protect against unknown objects */
				if (sts == OM_E_NOSUCHCLASS ) sts = OM_S_SUCCESS;

				if (!(sts & 1))
					{
					printf("Error in Window's DPdisbyoid, Error: ");
					om$report_error(sts = sts);
					*msg = MSFAIL;
					goto wrapup;
					}	
			 	}

			HSset_active_max_z( me->gragad.gpipe_id, me->shading_style, FALSE, 5 );
			
			if( (me->shading_style == HS_STYLE_RASTER ||
			    me->shading_style == HS_STYLE_FILLED_RASTER) &&
			    display_hline )
				{
				HSset_processing_mode( HS_PMODE_RHL_SURFACE );
				HSinit_activated_completed();
          
          /* bbkr's addition starts here */

            sts = GRcheckref(msg, type, *matrix[0], &OM_Gw_current_OS,
                        &buffer->osnum);

           if ((*msg != GRNOTREFFILE) && ( 1 & *msg & sts))
           {

                dismsg.msg = msg;
                dismsg.mx_type = type;
                dismsg.matrix = (IGRdouble *) *matrix;
                dismsg.mode = mode;
                dismsg.alt_symb = NULL;
                dismsg.dp_info = &sp_info;
                dismsg.range_key = NULL;

                om$make_message( classname = "GRgraphics",
                                 methodname = "GRdisyourself",
                                 size = sizeof (struct DPdismsg),
                                 p_arglist = &dismsg,
                                 p_msg = &display_msg);

                sts = GRdisthruref(msg,&display_msg,buffer);
           } 
           else
           { 
          /* bbkr's addition ends here */
   				sts =om$send(
					mode     = OM_e_wrt_object,
					msg      = message GRgraphics.GRdisyourself(
							msg,
							type,
							(IGRdouble *)*matrix,
							mode,
							0,
							&sp_info,
							NULL ),
					senderid = my_id,
					targetid = buffer->objid,
					targetos = buffer->osnum );
           } 

				if (!(sts & 1))
					{
					printf("Error in Window's DPdisbyoid, Error: ");
					om$report_error(sts = sts);
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

				HSset_processing_mode( HS_PMODE_RHL_EDGES );
				HSinit_activated_completed();

            /* bbkr's addition starts here */
    
            sts = GRcheckref(msg, type, *matrix[0], &OM_Gw_current_OS,
                        &buffer->osnum);

           if ((*msg != GRNOTREFFILE) && ( 1 & *msg & sts))
           {

                dismsg.msg = msg;
                dismsg.mx_type = type;
                dismsg.matrix = (IGRdouble *) *matrix;
                dismsg.mode = mode;
                dismsg.alt_symb = NULL;
                dismsg.dp_info = &sp_info;
                dismsg.range_key = NULL;

                om$make_message( classname = "GRgraphics",
                                 methodname = "GRdisyourself",
                                 size = sizeof (struct DPdismsg),
                                 p_arglist = &dismsg,
                                 p_msg = &display_msg);

                sts = GRdisthruref(msg,&display_msg,buffer);
           }
           else
           {    
             /* bbkr's addition ends here */
				sts =om$send(
					mode     = OM_e_wrt_object,
					msg      = message GRgraphics.GRdisyourself(
							msg,
							type,
							(IGRdouble *)*matrix,
							mode,
							0,
							&sp_info,
							NULL ),
					senderid = my_id,
					targetid = buffer->objid,
					targetos = buffer->osnum );
            }
 
				if (!(sts & 1))
					{
					printf("Error in Window's DPdisbyoid, Error: ");
					om$report_error(sts = sts);
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
			else
				{
				HSset_processing_mode( HS_PMODE_SHADING );

            /* bbkr's addition starts here */
            sts = GRcheckref(msg, type, *matrix[0], &OM_Gw_current_OS,
                        &buffer->osnum);

           if ((*msg != GRNOTREFFILE) && ( 1 & *msg & sts))
           {

                dismsg.msg = msg;
                dismsg.mx_type = type;
                dismsg.matrix = (IGRdouble *) *matrix;
                dismsg.mode = mode;
                dismsg.alt_symb = NULL;
                dismsg.dp_info = &sp_info;
                dismsg.range_key = NULL;

                om$make_message( classname = "GRgraphics",
                                 methodname = "GRdisyourself",
                                 size = sizeof (struct DPdismsg),
                                 p_arglist = &dismsg,
                                 p_msg = &display_msg);

                sts = GRdisthruref(msg,&display_msg,buffer);
           }
           else
           { 
           /* bbkr's addition ensd's here */
                		sts =om$send(
					mode     = OM_e_wrt_object,
					msg      = message GRgraphics.GRdisyourself(
							msg,
							type,
							(IGRdouble *)*matrix,
							mode,
							0,
							&sp_info,
							NULL ),
					senderid = my_id,
					targetid = buffer->objid,
					targetos = buffer->osnum );
           }

				if (!(sts & 1))
					{
					printf("Error in Window's DPdisbyoid, Error: ");
					om$report_error(sts = sts);
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

			if (count)
				{
				sts = om$send(
					msg          = message IGEwinsup.post_single_display(
									msg, 
									&gragad_id, 
									&graphic_id), 
					senderid     = my_id, 
					p_chanselect = &HSwinsup_chandef);
		
				/* protect against unknown objects */
				if (sts == OM_E_NOSUCHCLASS ) sts = OM_S_SUCCESS;

				if (!(sts & 1))
					{
					printf("Error in Window's DPdisbyoid, Error: ");
					om$report_error(sts = sts);
					*msg = MSFAIL;
					goto wrapup;
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
		}

	if( display_hline )
		{
		HSpaint( 1 );
	        HSredraw_coordinate_system( my_id, *mode, buffer_top, no_oids );
		}

wrapup:
   /*  Balas Addition Starts */
	BSchangepar( &rc, BSTOLCHRDHT, system_cht );
   /*  Balas Addition Ends */
	WLshow_cursor(ME.IGEgadget->win_no);
	WLflush(ME.IGEgadget->win_no);

wrapup0:

	return(sts);
	}

end implementation HSgragad;
