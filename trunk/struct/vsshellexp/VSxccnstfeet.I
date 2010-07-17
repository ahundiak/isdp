/*
	I/STRUCT
*/
class implementation VSexpandedCv ;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "msmacros.h"
#include "vsglobalmsg.h"
#include "vsshexpdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>
/*
 * Includes of function prototypes.
 */
#include "EMSwrmacros.h"
#include "vsvirtualinf.h"
#include "vsdrwproto.h"
#include "vsvecmxproto.h"

extern long	VSsxExpandCurve() ;

from VSshellExp import VSget_baseline_point,
		       VSget_limiting_points,
		       VSget_y_translation ;

/*----------------------------------------------------------------------------*/
method ACconstruct_feet( long			*msg ;
			 int			purpose,
						count ;
			 struct GRid		list[] ;
			 struct GRmd_env	*MyEnv ;
			 int			*feetCount ;
			 struct GRid		*feetList )\
{
	long			sts ;		/* OM return code.	      */
	int			i ;		/* Loop index.		      */
	struct GRvg_construct	cst ;		/* My construction list.      */
	struct GRsymbology	symb ;		/* My symbology.	      */
	struct GRobj_env	inputCv,	/* Input parent curve.	      */
				shExp ; 	/* Shell expansion parent.    */
	struct GRid		hlId,		/* Id of hull surface.	      */
				shExpPlane,	/* Plane of shell expansion.  */
				shExpCt ;	/* Id of contour of shell     */
						/* expansion.		      */
	struct GRmd_env 	hlEnv ; 	/* Env. of hull surface.      */
	struct IGRpolyline	polyline ;	/* Polyline of expanded curve.*/
	double			baseLine[3],	/* Baseline point.	      */
				beginPoint[3],	/* Begin point. 	      */
				endPoint[3] ;	/* End point.		      */
	short			world = TRUE ;	/* Get range in world coord.  */
	GRrange 		shExpRng ;	/* Range of contour of shell  */
						/* expansion.		      */
	double			yTrans ;	/* Y translation of shell     */
						/* expansion.		      */

	SetProc( VSexpandedCv_ACconstruct_feet ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "ACconstruct_feet" //, argfmt = "", args = ``
        );

	*feetCount	= 0 ;
	feetList->objid = NULL_OBJID ;

	shExpCt.objid	= NULL_OBJID ;

	polyline.num_points = 0 ;
	polyline.points     = NULL ;

	if( count != 2 ) vs$inv_arg() ;

	/*
	 * Fill construction list.
	 */
	sts = om$send( msg	= message GRvg.GRgetsymb( msg,
							  &symb ),
		       mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list( Env_info	= MyEnv,
			   Display	= &symb.display_attr,
			   Level	= symb.level,
			   Cnst_list	= cst ) ;

	/*
	 * Get input parent curve.
	 */
	sts = om$send( msg	= message VScpx.VSget_graphic_input( msg,
								     1,
								     list +1,
								     &inputCv ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	__DBGpr_obj( "Curve to expand", inputCv._grid ) ;

	/*
	 * Get shell expansion parent.
	 */
	sts = VSgetVirtualInfo( msg,
				list,
				&shExp.mod_env,
				&shExp._grid ) ;

	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	__DBGpr_obj( "Shell expansion parent", shExp._grid ) ;

	/*
	 * Get hull surface.
	 */
	sts = om$send( msg	= message VSexpandedCv.VSget_hull_surface(
								       msg,
								       &hlId,
								       &hlEnv ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VSexpandedCv.VSget_hull_surface", wrapup ) ;

	__DBGpr_obj( "Hull surface", hlId ) ;

	/*
	 * Get baseline point.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_baseline_point(
								 msg,
								 &shExp.mod_env,
								 baseLine ),
		       targetid = shExp._objid,
		       targetos = shExp._osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_baseline_point", wrapup ) ;

	__DBGpr_vec( "Baseline point", baseLine ) ;

	/*
	 * Get limiting points.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_limiting_points(
								 msg,
								 &shExp.mod_env,
								 beginPoint,
								 endPoint ),
		       targetid = shExp._objid,
		       targetos = shExp._osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_limiting_points", wrapup ) ;

	/*
	 * If we don't have limiting points, get limiting points with the
	 * limits of the shell expansion. We don't use message 'GRgetrang'
	 * on the shell expansion because, the shell expansion is a plane
	 * with boundaries and this message returns the range without
	 * including the boundaries which is more big.
	 *
	 *	      ..................
	 *	      . -------------- .
	 *	      . |	     | .
	 *	      . |	     | .
	 *	      . |	     | .
	 *	      . |	     | .
	 *	      . |	     | .
	 *	      . |	     | . <-- Plane without boundaries.
	 *	      . |	     | .
	 *    Y       . -------------- <-- Shell expansion.
	 *    ^       ..................
	 *    |
	 *    --> X
	 *
	 * So, retrieve the contour of the shell expansion and get its range
	 * to calculate the limiting points.
	 */
	if( beginPoint[0] == IGE_DESIGN_LIMITS_MIN &&
	    endPoint[0]   == IGE_DESIGN_LIMITS_MAX ) {

		__DBGpr_com( "Get limiting points with contour of shell exp" ) ;

		sts = om$send( msg	= message NDmacro.ACreturn_foot(
							  msg,
							  VS_K_sxShellExpansion,
							  &shExpPlane,
							  NULL,
							  NULL ),
			       targetid = shExp._objid,
			       targetos = shExp._osnum ) ;

		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		__DBGpr_obj( "Plane of shell expansion", shExpPlane ) ;

		sts = VSdrwMakeSfContourCompCurve( msg,
						   &shExpPlane,
						   &shExp.mod_env,
						   MyEnv,
						   &shExpCt ) ;

		__CheckRC( sts, *msg, "VSdrwMakeSfContourCompCurve", wrapup ) ;

		__DBGpr_obj( "Contour of shell expansion", shExpCt ) ;

		sts = om$send( msg	= message GRgraphics.GRgetrang(
							   msg,
							   &MyEnv->_MATRIX_TYPE,
							   MyEnv->_MATRIX,
							   &world,
							   shExpRng ),
			       targetid = shExpCt.objid,
			       targetos = shExpCt.osnum ) ;

		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

		VSvccpy( beginPoint, shExpRng	  ) ;
		VSvccpy( endPoint,   shExpRng + 3 ) ;
	}

	__DBGpr_vec( "Begin point", beginPoint ) ;
	__DBGpr_vec( "End   point", endPoint   ) ;

	/*
	 * Expand curve.
	 */
	sts = VSsxExpandCurve( msg,
			       &hlId,
			       &hlEnv,
			       &inputCv._grid,
			       &inputCv.mod_env,
			       beginPoint[0],
			       endPoint[0],
			       baseLine[2],
			       &polyline ) ;

	__CheckRC( sts, *msg, "VSsxExpandCurve", wrapup ) ;

	if( !polyline.num_points ) vs$failure() ;

	/*
	 * Translate polyline with translation value of shell expansion.
	 */
	ex$message( msgnumb = VS_gI_Processing, justification = CENTER_JUS ) ;

	sts = om$send( msg	= message VSshellExp.VSget_y_translation(
								 msg,
								 &shExp.mod_env,
								 &yTrans ),
		       targetid = shExp._objid,
		       targetos = shExp._osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_y_translation", wrapup ) ;

	for( i=0; i<polyline.num_points; i++ )
		polyline.points[3*i+1] += yTrans ;

	sts = EFplace_line_string( NULL_OBJID,
				   &cst,
				   polyline.num_points,
				   polyline.points,
				   &feetList->objid,
				   msg ) ;

	__CheckRC( sts, *msg, "EFplace_line_string", wrapup ) ;

	feetList->osnum = cst.env_info->_MD_OS ;
	*feetCount	= 1 ;

	om$change_tag_version() ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		ex$message( msgnumb = VS_gI_EmptyMessage ) ;

		if( !( sts & 1 & *msg ) ) {
			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
				sts = OM_S_SUCCESS ;
			}
		}

		vs$bulk_delete( grids  = &shExpCt,
				theEnv = MyEnv ) ;

		_FREE( polyline.points ) ;

        __exitMethod ( name = "ACconstruct_feet", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End

		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSexpandedCv ;
