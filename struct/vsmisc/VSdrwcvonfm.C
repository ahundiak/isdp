/*
	I/STRUCT
*/
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <FI.h>
#include "wl.h"
#include "bstypes.h"
#include "dl.h"
#include "OMminimum.h"
#include "cm.h"
#include "msdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "exmacros.h"
#include "dpdef.h"
#include "gr.h"
#include "vsdpb.h"
#include "vsgraphicenv.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsbx2.h"
#include "maidmx.h"
#include "matypemx.h"
#include "vsgrenvproto.h"
#include "vsvecmxproto.h"

/*----------------------------------------------------------------------------*/
long VSmapCurveToRectangle( msg, worldPnt, rectPnt, rectMinLength, symmetry,
			    curve, scale )

/*
 * Maps curve from its position to a rectangular area such that :
 *	- curve is contained within rectangle (ie. curve is possibly resized to
 *	fit into the rectangle.
 *	- the world point `worldPoint' coincides with the rectangle point
 *	`rectPoint' (a point within the rectangle).
 *	- the curve undergoes a symmetry around the x- and y-axis.
 *
 *	It is supposed that the input curve is in a plane z = constant
 *	as well as the rectangle.
 */
long			*msg ;
IGRpoint		worldPnt,
			rectPnt ;
double			rectMinLength ;
enum VSsymmetry		symmetry ;
struct IGRbsp_curve	*curve,
			*scale ; {

	IGRmatrix		idMx,
				symmMx,
				translMx,
				scaleMx ;
	IGRpoint		minPnt,
				maxPnt ;
	IGRdouble		maxCvWidth,
				d ;
	short			xformType ;
	struct IGRbsp_curve	*cv ;

	/*
	 * Compute max width of curve. Remember curve is in a plane z = const.
	 * Use scaling curve curve if requested instead of curve to draw.
	 */
	cv = scale ? scale : curve ;

	BSbx2(	msg,
		&cv->num_poles,
		(IGRpoint *) cv->poles,
		cv->rational ? cv->weights : NULL,
		minPnt,
		maxPnt ) ;

	maxCvWidth = fabs( minPnt[0] - maxPnt[0] ) ;
	if( maxCvWidth < ( d = fabs( minPnt[1] - maxPnt[1] ) ) ) maxCvWidth = d;

	/*
	 * Translation vector from world point to rectangle point.
	 */
	MAidmx		( msg, idMx ) ;
	/*
	 * Add translate of curve to world point.
	 */
	VStranslatemx	( worldPnt, idMx, translMx ) ;
	/*
	 * Add scaling of curve so as to fit into rectangle.
	 */
	VSscalemx	( rectMinLength / maxCvWidth, translMx, scaleMx ) ;
	/*
	 * Add symmetry on curve if any requested.
	 */
	VSmirrormx	( symmetry, scaleMx, symmMx ) ;
	/*
	 * Add moving curve to given point inside rectangle.
	 */
	VStranslatemx	( rectPnt, symmMx, translMx ) ;

	/*
	 * Apply transformation to curve.
	 */
	MAtypemx( msg, translMx, &xformType ) ;

	vs$xform_curve(	msg		= msg,
			mxType		= xformType,
			transMx 	= translMx,
			curveGeom	= curve ) ;

	return *msg & 1 ;

} /* VSmapCurveToRectangle */
/*----------------------------------------------------------------------------*/
long VSstrokeOnForm( msg, form, lineWeight, curve )

long			*msg ;
char			*form ;
int			lineWeight ;
struct IGRbsp_curve	*curve ; {

	WLhwin_no		hwin_no ;
	int			gpipe_id ;

	*msg = MSFAIL ;

	/* 
	 * Get hardware window from form.
	 */
	if( FIf_get_window( form, &hwin_no ) == FI_SUCCESS ) {

		WLuint16 lscreen_no ;
		WLuint32 context_no ;
		WLuint32 lwin_no ;
		long	 attr ;
		OMuword	 actModOs ;

		ex$get_cur_mod( osnum = &actModOs ) ;
		/*
		 * Add harware window to Window Layer, get logical window number
		 */
		FIf_get_attr( form, &attr ) ;
		if( CMadd_form_to_wl(	hwin_no,
					TRUE,
					NULL_OBJID,  /* Use IGEcolor2 */
					actModOs,
					(attr & FI_SAVE_RESTORE) != 0,
					&lscreen_no,
					&context_no,
					&lwin_no ) == CM_SUCCESS ) {
		   /*
		    * Create a pipeline.
		    */
		   if( DLcreate_drawing_pipeline(
		   			DL_ORTHO_PIPE,
					lwin_no,
					&gpipe_id ) == DL_SUCCESS ) {

			if( DLset_curve_max_points( gpipe_id, 100 )
							== DL_SUCCESS ) {
				WLcolorref colorRef ;

				WLset_active_symbology( lwin_no,
							0,
							DP_SOLID_LINE_STYLE,
							0xffff,
							0,
							WL_SYMB_CHANGE_STYLE ) ;

				WLset_blendarea( lwin_no, NULL, TRUE ) ;

				/*
				 * (R,G,B) = (0,0,0) means black ...
				 */
				WLpack_rgb_colorref( 0, 0, 0, &colorRef, TRUE );
 
				WLhide_cursor( lwin_no, TRUE ) ;
				if( DLdraw_3D_curve(	gpipe_id,
							curve,
							NULL,
							NULL,
							0,
							colorRef,
							DP_SOLID_LINE_STYLE,
					/* blend */     0xFFFF,
							lineWeight,
							DL_OPT_BASE_DRAW |
							DL_OPT_DONT_CLIP |
							DL_OPT_HILITE_NOOP )
						== DL_SUCCESS ) {
					WLflush( lwin_no ) ;
					*msg = MSSUCC ;
				}
				WLshow_cursor( lwin_no ) ;
			}
			DLdelete_drawing_pipeline( gpipe_id ) ;
		   }
		   CMremove_form_from_wl( lscreen_no, lwin_no, context_no ) ;
		}
	}

	return *msg & 1 ;

} /* VSstrokeOnForm */
/*----------------------------------------------------------------------------*/
long VSdrawCurveOnForm( msg, form, gadget, lineWeight,
			worldPoint, symmetry, curve, scale )

long			*msg ;
char			*form ;
int			gadget ;
int			lineWeight ;
IGRpoint		worldPoint ;
enum VSsymmetry		symmetry ;
struct IGRbsp_curve	*curve,
			*scale ; {

	int	gwidth,		/* Width of gadget	*/
		gheight,	/* Height of gadget	*/
		gx,		/* X of gadget		*/
		gy ;		/* Y of gadget		*/

	*msg = MSFAIL ;

	if( FIg_get_size( form, gadget,
			  &gwidth, &gheight ) == FI_SUCCESS ) {
		double	minWidth ;

		if( gwidth < gheight )	minWidth = gwidth ;
		else			minWidth = gheight ;

		if( FIg_get_location(	form, gadget,
					&gx, &gy ) == FI_SUCCESS ) {
			IGRpoint	gPnt ;

			/*
			 * Remove some pixel space so curve will not be
			 * drawn outside of gadget.
			 */
			gx += lineWeight + 1 ;
			gy += lineWeight + 1 ;
			gwidth	 -= 2 * ( lineWeight + 1 ) ;
			gheight	 -= 2 * ( lineWeight + 1 ) ;
			minWidth -= 2 * ( lineWeight + 1 ) ;
			gPnt[0] = gx + gwidth  * 0.5 ;
			gPnt[1] = gy + gheight * 0.5 ;
			gPnt[2] = 0 ;

			VSmapCurveToRectangle(	msg,
						worldPoint,
						gPnt,
						minWidth,
						symmetry,
						curve,
						scale ) ;
			if( *msg & 1 ) {
				VSstrokeOnForm( msg, form, lineWeight, curve ) ;
			}
		}
	}

	return *msg & 1 ;

} /* VSdrawCurveOnForm */
/*----------------------------------------------------------------------------*/
long VSdrawCvOnForm( msg, form, gadget, lineWeight,
			worldPoint, curveEnv, curveId, scaleCvId )

/*
 * This function is interfaced by macro vs$draw_curve_on_form.
 */
long		*msg ;
char		*form ;
int		gadget ;
int		lineWeight ;
IGRpoint	worldPoint ;
struct GRmd_env	*curveEnv ;
struct GRid	*curveId,
		*scaleCvId ; {

	struct IGRbsp_curve	*curveGeom,
				*scaleGeom ;

	curveGeom = scaleGeom = NULL ;

	vs$get_geometry(	msg	= msg,
				grobjId	= curveId,
				grobjEnv= curveEnv,
				geometry= &curveGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	if( scaleCvId ) {
		vs$get_geometry(	msg	= msg,
					grobjId	= scaleCvId,
					grobjEnv= curveEnv,
					geometry= &scaleGeom ) ;
		__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
	}
	/*
	 * We are obliged to impose a symmetry about the X-axis because
	 * the y-axis on the TOP view goes up, but down on a form's window.
	 */
	VSdrawCurveOnForm(	msg,
				form,
				gadget,
				lineWeight,
				worldPoint,
				VS_e_X_Symm,
				curveGeom,
				scaleGeom ) ;
	wrapup :
		_FREE( curveGeom ) ;
		_FREE( scaleGeom ) ;
		return *msg & 1 ;

} /* VSdrawCvOnForm */
/*----------------------------------------------------------------------------*/

