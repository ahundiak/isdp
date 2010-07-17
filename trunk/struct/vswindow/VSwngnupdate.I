/*
	I/STRUCT
*/
class implementation VSsomeObjcVw ;

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "ex.h"
#include "lcdef.h"
#include "lc.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "grmessage.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "dpgraphics.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define GRID_BUF_SIZE		100*1024
#define NON_GRID_BUF_SIZE	2*1024

extern IGRboolean DPusing_ASAPII();
extern IGRboolean MAtypemx();
extern IGRboolean MAidmx();
extern IGRboolean MAoptsxform();

from IGEwinsup	import	pre_update,
			post_update ;
from GRgraphics	import	GRdisyourself ;
/*----------------------------------------------------------------------------*/
method DPgen_update(	long			*msg ;
			struct DPdit_range	*range ; 
			IGRboolean		*update_all ;
			enum GRdpmode		mode ;
			IGRboolean		erase ) {


	short			matrix_type ;
	int			sts ;		/* OM return status	*/
	double			pt[24] ;	/* temporary variable	*/
	short			k,x,y,z,i,j ;	/* loop index		*/
	double			min,
				max ;
	GRrange			rng ;		/* window range		*/
	double			tmp_range[4] ;
	long			num_pts = 8 ;	/* number of points	*/
	short			rect	= 0 ;
	short			front	= 0 ;
	short			back	= 0 ;
	struct GRmd_env		mdenv ;
	struct DP_information	dp_info ;
	struct DPdit_range	range1 ;
	struct DPdit_range	*ditrng ;
	long			num_byte ;
	long			byte_rcvd ;   
	struct GRid		gragad_id ;
	int			screen_no ;
	OMuint			count ;
	int			quiet_flag ;
	int			bckgnd_planes ;
	int			hilite_plane ;
	OM_S_CHANSELECT		toWinSup ;
	struct GRid		theObjToDisplay ;

#ifdef X11
	int screen;
#endif
	
	sts = OM_S_SUCCESS; 

	/*
	 * For the following reasons : batch, window not active, STOP hit, etc.
	 * do not update.
	 */
	if(	   ex$is_batch()
		|| ige$SR_active()
		|| !( ME.IGEgragad->gragad.flags & IS_ACTIVE )
		|| ( ex$disp_flag( flag = &quiet_flag ), quiet_flag )
		|| !range && IGEstop() ) {

		goto end1 ;
	}

	screen_no = ME.IGEgragad->gragad.flags & DPLEFT_SCREEN
				? IGE_LEFT_SCREEN
				: IGE_RIGHT_SCREEN ;

	ige$inq_term_info(	screen_no		= screen_no,
				background_planes	= &bckgnd_planes,
				hilite_plane		= &hilite_plane ) ;

	ex$message( msgnumb = GR_I_DpProg ) ;

	/*
	 *    erase window
	 */

	DPhidecursor( ME.IGEgadget->win_no ) ;

#ifndef X11
	blendline( ME.IGEgadget->win_no, 0xffff ) ;
	linestyle( ME.IGEgadget->win_no, 0xffff ) ;
#else

	DPget_win_vs( ME.IGEgadget->win_no, &screen ) ;
	XSetLineAttributes(	EXdisplay,
				EXgc[screen],
				1,
				LineSolid,
				CapButt,
				JoinMiter ) ;
#endif

	DPset_texture  ( ME.IGEgadget->win_no, DPSOLID_PATTERN ) ;
	DPset_blendarea( ME.IGEgadget->win_no, DPSOLID_PATTERN ) ;
	

	if( range == NULL ) {

		range1.xlo = ME.IGEgadget->min_x_dep;
		range1.ylo = ME.IGEgadget->min_y_dep;

		range1.xhi = ME.IGEgadget->max_x_dep;
		range1.yhi = ME.IGEgadget->max_y_dep;

		ditrng = &range1 ;
	} else {
		ditrng = range ;

		if( !( ME.IGEgragad->gragad.flags & IS_PERSP ) ) {

/*  Only update needed part of window.  The 3 is added and subtracted to  */
/*  in order to take into account the grid cross 			  */
/*  TOOK OUT CHANGE AND MOVED TO DPGRIDDRAW TO PICK UP GRID CENTER */
		tmp_range[0] = ME.IGEgragad->gragad.dit_clip_range[0] ;
		tmp_range[1] = ME.IGEgragad->gragad.dit_clip_range[1] ;
		tmp_range[2] = ME.IGEgragad->gragad.dit_clip_range[3] ;
		tmp_range[3] = ME.IGEgragad->gragad.dit_clip_range[4] ;

		if( range->xlo < tmp_range[0] ) {
			ME.IGEgragad->gragad.dit_clip_range[0] = tmp_range[0];
		} else {
			ME.IGEgragad->gragad.dit_clip_range[0] = range->xlo;
		}

		if( range->ylo < tmp_range[1] ) {
			ME.IGEgragad->gragad.dit_clip_range[1] = tmp_range[1];
		} else {
			ME.IGEgragad->gragad.dit_clip_range[1] = range->ylo;
		}

		if( range->xhi > tmp_range[2] ) {
			ME.IGEgragad->gragad.dit_clip_range[3] = tmp_range[2];
		} else {
			ME.IGEgragad->gragad.dit_clip_range[3] = range->xhi;
		}
	  
		if( range->yhi > tmp_range[3] ) {
			 ME.IGEgragad->gragad.dit_clip_range[4] = tmp_range[3];
		} else {
			ME.IGEgragad->gragad.dit_clip_range[4] = range->yhi;
		}
	  

		rect	= ME.IGEgragad->gragad.flags & CLIP ;
		front	= ME.IGEgragad->gragad.flags & FRONT_CLIP ;
		back	= ME.IGEgragad->gragad.flags & BACK_CLIP ;

		DPpush_clip(	msg,
				rect,
				front,
				back,
				ME.IGEgragad->gragad.dit_clip_range,
				ME.IGEgragad->gragad.gpipe_id ) ;
		}
	}

#ifndef X11
	Set_win_buffer_size( ME.IGEgadget->win_no, NON_GRID_BUF_SIZE ) ;
#endif
	if( erase ) {

#ifdef XGL_IN_USE
		XGLSetPlaneMask(	ME.IGEgadget->win_no,
					hilite_plane | bckgnd_planes ) ;
#else
		DPset_plane_mask(	ME.IGEgadget->win_no,
					hilite_plane | bckgnd_planes ) ;   
#endif

		if( ! DPerase( msg, &ME.IGEgadget->win_no, ditrng ) ) {
			*msg = MSFAIL ; goto wrapup ;
		}

#ifdef XGL_IN_USE
		XGLSetPlaneMask( ME.IGEgadget->win_no, bckgnd_planes ) ;
#else
		DPset_plane_mask( ME.IGEgadget->win_no, bckgnd_planes ) ; 
#endif

		/* check to see if needs grid */
		if( ME.IGEgragad->gragad.flags & GRID_ON ) {

			sts = om$send(	msg	= message IGEgragad.DPgriddraw(
	       							msg, ditrng ),
					targetid = my_id ) ;
			__CheckRC( sts, *msg, "IGEgragad.DPgriddraw", wrapup ) ;
		}

		/* see if ground plane needs to be drawn */
		if( ME.IGEgragad->gragad.flags & DP_GROUND_PLANE ) {
			DPdraw_ground_plane( my_id, OM_Gw_current_OS,
	      					&ME.IGEgragad->gragad ) ;
		}
	} /* end of if (erase) */

	/*
	**   get 8 corner points of dit clip range
	*/
	k = 0;
	for( z = 0 ; z < 2 ; z++ ) {
		for( y = 0 ; y < 2 ; y++) {
			for( x = 0; x < 2; x++ ) {
				pt[k++] = (x) ? ditrng->xhi : ditrng->xlo;
				pt[k++] = (y) ? ditrng->yhi : ditrng->ylo;
				pt[k++] = (z) ? ME.IGEgragad->gragad.dit_clip_range[5] :
	                                        ME.IGEgragad->gragad.dit_clip_range[2];
			}
		}
	}


	/*
	**   transform 8 points to world coordinate system (wcs)
	*/                                                                    
	MAtypemx( msg, ME.IGEgragad->gragad.viewport_to_wld, &matrix_type ) ;
	MAoptsxform( msg, &num_pts, &matrix_type,
	                    ME.IGEgragad->gragad.viewport_to_wld, pt, pt ) ;



	/*
	**   get view range   (accumulate hi's and low's)
	*/
	for( j = 0 ; j < 3 ; j++ ) {   /* for x,y,z coordinate */

		min = max = pt[j];
		for( i = 0, k = j ; i < 8 ; i++, k += 3 ) {
			min = ( pt[k] < min ) ? pt[k] : min ;
			max = ( pt[k] > max ) ? pt[k] : max ;
		}
		rng[j + 0] = min ;
		rng[j + 3] = max ;
	}
 
	num_byte = sizeof( struct GRmd_env ) ;
	gr$get_module_env(	msg	= msg, 
				sizbuf	= &num_byte, 
				buffer	= &mdenv, 
				nret	= &byte_rcvd);

	ex$get_modid(	mod_osnum	= OM_Gw_current_OS,
			mod_id		= &mdenv.md_id.objid ) ;
	mdenv.md_id.osnum = OM_Gw_current_OS ;

	sts = om$send(	msg	= message IGEgragad.DPupd_app_init(
								msg, &dp_info ),
			targetid= my_id ) ;

	if( ! ( sts & 1 & *msg ) ) {
		*msg = MSFAIL ;
	}
	__CheckRC( sts, *msg, "IGEgragad.DPupd_app_init", wrapup ) ;

	DPhidecursor( ME.IGEgadget->win_no ) ;

	toWinSup.type		= OM_e_addr ;
	toWinSup.u_sel.addr	= &me->winsup ;
			
	sts = om$get_channel_count(	objid		= my_id, 
					p_chanselect	= &toWinSup, 
					count		= &count ) ;

	if( !( sts & 1 ) ) goto wrapup ;

	gragad_id.objid = my_id;
	gragad_id.osnum = OM_Gw_current_OS ;

	if( count ) {

		sts = om$send(	msg	= message IGEwinsup.pre_update(
								msg, 
								&gragad_id,
								&dp_info,
								&mdenv ), 
				senderid = my_id, 
				p_chanselect = &toWinSup ) ;
	    
		/* protect against unknown objects */
		if( sts == OM_E_NOSUCHCLASS ) sts = OM_S_SUCCESS ;

		if( !( sts & 1 ) ) {
			*msg = MSFAIL ;
		}		
		__CheckRC( sts, *msg, "IGEwinsup.pre_update", wrapup ) ;
	}

	if( AA_allocate( (char *) AA_config_path(), NULL )
	     && !( ME.IGEgragad->gragad.flags & DPVIEW_DYNAMICS )
	     && ! dp_info.is_hidden_line ) {

		/*
		 * Make sure the matrix for this window has been loaded in the
		 * ASAPII
		 */
		DPset_ASAPII_use( TRUE );
		DPsave_ASAPII_window_number( ME.IGEgadget->win_no ) ;

		if( ME.IGEgragad->gragad.flags & IS_PERSP ) {
			DPpush_vwmtx(	msg,
					ME.IGEgragad->gragad.wld_to_view,
					ME.IGEgragad->gragad.vvol_viewport_scale,
					ME.IGEgragad->gragad.gpipe_id ) ;
		} else {
			DPpush_vwmtx(	msg,
					ME.IGEgragad->gragad.wld_to_viewport,
					ME.IGEgragad->gragad.vvol_viewport_scale,
					ME.IGEgragad->gragad.gpipe_id ) ;
		}
		DPpush_clip(	msg,
				TRUE,
				TRUE,
				TRUE,
				ME.IGEgragad->gragad.dit_clip_range,
				ME.IGEgragad->gragad.gpipe_id ) ;
	} else DPset_ASAPII_use( FALSE ) ;

	om$send(msg	= message VSsomeObjcVw.getObjectToDisplay(
							&theObjToDisplay ),
		targetid= my_id ) ;

	if( !IF_NULL_OBJID( theObjToDisplay.objid ) ) {
		sts = om$send(	msg	= message GRgraphics.GRdisyourself(
							msg,
							&mdenv._MATRIX_TYPE,
							mdenv._MATRIX,
							&mode,
							NULL,
							&dp_info,
							NULL ),
				targetid= theObjToDisplay.objid,
				targetos= theObjToDisplay.osnum ) ;

	} /* else no object to display */

	if( DPusing_ASAPII() ) {
		/*
		 * Wait until the ASAPII is finished with this update
		 */
			DPget_final_linestrings_from_ASAPII() ;
			DPset_ASAPII_use( FALSE ) ;
	}

	if( count ) {
		sts = om$send(	msg	= message IGEwinsup.post_update(
							msg, &gragad_id ), 
				senderid= my_id, 
				p_chanselect = &toWinSup ) ;

		/* protect against unknown objects */
		if( sts == OM_E_NOSUCHCLASS ) sts = OM_S_SUCCESS;

		if( !( sts & 1 ) ) {
			*msg = MSFAIL ;
		}		
		__CheckRC( sts, *msg, "IGEwinsup.post_update", wrapup ) ;
	}

	if( ! dp_info.is_hidden_line )
		 ex$message( msgnumb = GR_I_DpCmpl ) ;

wrapup :
	if( range && !( ME.IGEgragad->gragad.flags & IS_PERSP ) ) {
	     ME.IGEgragad->gragad.dit_clip_range[0] = tmp_range[0] ;
	     ME.IGEgragad->gragad.dit_clip_range[1] = tmp_range[1] ;
	     ME.IGEgragad->gragad.dit_clip_range[3] = tmp_range[2] ;
	     ME.IGEgragad->gragad.dit_clip_range[4] = tmp_range[3] ;

	     DPpush_clip(	msg,
	     			rect,
	     			front,
	     			back,
	     			ME.IGEgragad->gragad.dit_clip_range,
				ME.IGEgragad->gragad.gpipe_id ) ;

	}

	DPshowcursor( ME.IGEgadget->win_no ) ;
	DPsync( ME.IGEgadget->win_no , 0 ) ;
	
end1 :
	return sts ;

} /* method DPgen_update */
/*----------------------------------------------------------------------------*/

end implementation VSsomeObjcVw ;
