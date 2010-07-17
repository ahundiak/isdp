/*
	I/STRUCT
*/
class implementation VSsomeObjcVw ;

#include <stdio.h>
#include "OMmacros.h"
#include "madef.h"
#include "igetypedef.h"
#include "ex.h"
#include "execmsg.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grmessage.h"
#include "dpcodef.h"
#include "dpcomacros.h"

extern IGRboolean	MAptsxform(),
			MAidmx() ;
extern double		MAdabs() ;

#define BORDER_PERC .03

from	GRgraphics	import	GRgetrang ;
/*----------------------------------------------------------------------------*/
method DPfit( long *msg ; int fit_flag ) {


	long		sts ;
	GRrange		rng,			/* Window range		*/
			new_range ;
	IGRmatrix	idMx ;
	short		idMxType	= MAIDMX ;
	IGRboolean	world		= TRUE ;
	double		x_rng_delta,
			y_rng_delta,
			z_rng_delta,
			rng_delta;
	IGRmatrix	wld_to_view ;
	struct GRid	theObjToDisplay ;

	sts = OM_S_SUCCESS ; 

	if( ME.IGEgragad->gragad.flags & IS_PERSP ) {
		IGRmatrix	ex_mtx ;
	    	DPalignper(	msg,
	    			DPLEFT_VIEW,
	    			ME.IGEgragad->gragad.vpn,
	    			ME.IGEgragad->gragad.vup,
				ME.IGEgragad->gragad.eye_pt,
				ex_mtx,
				wld_to_view ) ;
	} else {
		OM_BLOCK_MOVE(	ME.IGEgragad->gragad.wld_to_view,
				wld_to_view,
				sizeof( IGRmatrix ) ) ;
	}

	om$send(msg	= message VSsomeObjcVw.getObjectToDisplay(
							&theObjToDisplay ),
		targetid= my_id ) ;

	if( IF_NULL_OBJID( theObjToDisplay.objid ) ) {
		*msg = MSSUCC ; return OM_S_SUCCESS ;
	}
	ex$message ( msgnumb = GR_I_FitProg);

	MAidmx( msg, idMx ) ;

	sts = om$send(	msg	= message GRgraphics.GRgetrang(	msg,
								&idMxType,
								idMx,
								&world,
								rng ),
			targetid= theObjToDisplay.objid,
			targetos= theObjToDisplay.osnum ) ;

	if( rng[0] != IGE_DESIGN_LIMITS_MAX ) {
    		ex$message ( msgnumb = EX_S_Clear ) ;
	}

	/* adjust view volume to correspond to calculated range  */
	if( !DPgetrng(	msg,
			wld_to_view,
			&ME.IGEgragad->gragad.vv_range_chk,
			rng,
			new_range ) ) {
		goto wrapup;
	}
	x_rng_delta = new_range[3] - new_range[0] ;
	y_rng_delta = new_range[4] - new_range[1] ;
	z_rng_delta = new_range[5] - new_range[2] ;

	x_rng_delta = MAdabs( msg, &x_rng_delta ) ;
	y_rng_delta = MAdabs( msg, &y_rng_delta ) ;
	z_rng_delta = MAdabs( msg, &z_rng_delta ) ;

	if( ME.IGEgragad->gragad.flags & AXIS_WLD_ALIGN ) {
		if( x_rng_delta > y_rng_delta ) {
			rng_delta = x_rng_delta;
		} else {
			rng_delta = y_rng_delta;
		}
    	} else {
		if( x_rng_delta > y_rng_delta ) {
			if( x_rng_delta > z_rng_delta ) {
				rng_delta = x_rng_delta ;
	    		} else {
				rng_delta = z_rng_delta ;
			}
		} else { /* y is greater */
			if( y_rng_delta > z_rng_delta ) {
				rng_delta = y_rng_delta ;
			} else {
				rng_delta = z_rng_delta ;
			}
		}	
	}

	rng_delta = rng_delta * BORDER_PERC ;

	new_range[0] -= rng_delta;
	new_range[3] += rng_delta;

	ME.IGEgragad->gragad.vw_volume[0] = new_range[0];
	ME.IGEgragad->gragad.vw_volume[3] = new_range[3];

	new_range[1] -= rng_delta;
	new_range[4] += rng_delta;
	
	ME.IGEgragad->gragad.vw_volume[1] = new_range[1];
	ME.IGEgragad->gragad.vw_volume[4] = new_range[4];

    	new_range[2] -= rng_delta;
    	new_range[5] += rng_delta;
	
	ME.IGEgragad->gragad.vw_volume[2] = new_range[2];
	ME.IGEgragad->gragad.vw_volume[5] = new_range[5];


     	if( ME.IGEgragad->gragad.flags & IS_PERSP ) {
     		double		far,
     				near,
     				new_z ;
		IGRushort	pflag ;
     	
		dp$codpb_get_persp_flags( persp_flags = &pflag ) ;

		if( pflag & PERSP_CHANGE_ANGLE )  
			ME.IGEgragad->gragad.vw_angle = DEF_VWANGLE ;

			DPfitpersp(	msg,
					0,
					ME.IGEgragad->gragad.vw_volume,
					&ME.IGEgragad->gragad.act_z,	
					wld_to_view,ME.IGEgragad->gragad.coi,
					ME.IGEgragad->gragad.vrp,
					ME.IGEgragad->gragad.vw_angle, 
					ME.IGEgragad->gragad.vrp,
					ME.IGEgragad->gragad.eye_pt,
					ME.IGEgragad->gragad.coi,
					&near,
					&far,
					&new_z ) ;
			ME.IGEgragad->gragad.vw_volume[2] = near ;
			ME.IGEgragad->gragad.vw_volume[5] = far ;
	}

	sts = om$send(	msg	= message IGEgragad.DPcal( msg ),
			targetid = my_id);

     	if( !( ME.IGEgragad->gragad.flags & IS_PERSP ) ) {
		long	one = 1 ;
   
		ME.IGEgragad->gragad.coi[0] =
			(  ME.IGEgragad->gragad.dit_clip_range[0]
			 + ME.IGEgragad->gragad.dit_clip_range[3] ) / 2.0 ;
		ME.IGEgragad->gragad.coi[1] =
			(   ME.IGEgragad->gragad.dit_clip_range[1]
			 + ME.IGEgragad->gragad.dit_clip_range[4] ) / 2.0 ;
		ME.IGEgragad->gragad.coi[2] = ME.IGEgragad->gragad.act_z_screen;

		if( !MAptsxform(	msg,
					&one,
					ME.IGEgragad->gragad.viewport_to_wld,
					ME.IGEgragad->gragad.coi,
					ME.IGEgragad->gragad.coi ) ) {
			goto wrapup ;
		}
	}

       if( !( sts & 1 ) ) goto wrapup ;

    	ex$message ( msgnumb = EX_S_Clear);

	if( !( ME.IGEgragad->gragad.flags & DP_DELAY ) ) {

		IGRboolean	upd_flag = FALSE ;

		sts = om$send(	msg	= message IGEdisplay.DPupdate(
							msg, NULL, &upd_flag ),
				targetid= my_id ) ;
	} else {
		ex$message( msgnumb = GR_I_DlyOn ) ;	
	}

	*msg = MSSUCC ;

	wrapup :

		return sts ;

} /* method DPfit */
/*----------------------------------------------------------------------------*/

end implementation VSsomeObjcVw ;
