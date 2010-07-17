/* $Id: VSmccnstfeet.I,v 1.2 2001/08/17 21:58:27 hans Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsshellexp/VSmccnstfeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmccnstfeet.I,v $
 *      Revision 1.2  2001/08/17 21:58:27  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/01  14:59:50  pinnacle
# TR179701791
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTIO
 * 09/26/97  ah      added header
 * 09/30/97  ah      TR179701791 Don't allocate 0 bytes
 * 03/01/98  ah      TR179701791 Final Checkin
 *
 ***************************************************************************/

class implementation VSmergeExpCv ;

#include <stdio.h>
#include "OMmacros.h"
#include "bstypes.h"
#include "EMSmsgdef.h"
#include "EMSwrmacros.h"
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
#include "vsvirtualinf.h"
#include "vsvecmxproto.h"
#include "bsdistptpt.h"

from GRlinear	import GRgetpolyline ;
from VSshellExp import VSget_y_translation ;

/*----------------------------------------------------------------------------*/
long VSget_polyline_of_curve( msg, cvId, cvEnv, polyline )

long			*msg ;
struct GRid		*cvId ;
struct GRmd_env 	*cvEnv ;
struct IGRpolyline	*polyline ;
{
	/*
	 * This function returns the polyline '*polyline' of the given curve
	 * ( cvId, cvEnv ).
	 *
	 * note :
	 * ======
	 *
	 * '*polyline.points' is malloced and it is up to the caller to free it
	 * with :
	 *	free( *polyline.points ) ;
	 */

	long			sts ;		/* OM return code.	      */
	int			action ;	/* Action flag. 	      */

        __enterFunction ( name = "VSget_polyline_of_curve" //, argfmt = "", args = ``
        );

	/*
	 * Get number of points.
	 */
	action = 0 ;

	sts = om$send( msg	= message GRlinear.GRgetpolyline(
							   msg,
							   &cvEnv->_MATRIX_TYPE,
							   cvEnv->_MATRIX,
							   &action,
							   polyline ),
		       senderid = NULL_OBJID,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;

	__CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup ) ;

	/*
	 * Get polyline of curve.
	 */
	if( !( polyline->points = _MALLOC( 3*(polyline->num_points + 1), double ) ) )
		vs$mem_fail() ;

	action = 1 ;

	sts = om$send( msg	= message GRlinear.GRgetpolyline(
							   msg,
							   &cvEnv->_MATRIX_TYPE,
							   cvEnv->_MATRIX,
							   &action,
							   polyline ),
		       senderid = NULL_OBJID,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;

	__CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( polyline->points ) ;
			polyline->points     = NULL ;
			polyline->num_points = 0 ;
		}

        __exitFunction ( name = "VSget_polyline_of_curve", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		return sts ;

} /* VSget_polyline_of_curve */
/*----------------------------------------------------------------------------*/
method ACconstruct_feet( long			*msg ;
			 int			purpose,
						count ;
			 struct GRid		list[] ;
			 struct GRmd_env	*MyEnv ;
			 int			*feetCount ;
			 struct GRid		*feetList )
{
	long			sts ;		/* BS return code.	      */
	int			i ;		/* Loop index.		      */
	struct GRvg_construct	cst ;		/* My construction list.      */
	struct GRsymbology	symb ;		/* My symbology.	      */
	struct GRid		expCv[2] ;	/* My expanded curve parents. */
	struct GRobj_env	mergedSh,	/* My merged shell expansion  */
						/* parent.		      */
				curves[2] ;	/* Curve of expanded curves.  */
	struct IGRpolyline	cvPol[2],	/* Polyline of above curves.  */
				mergedPol ;	/* My polyline. 	      */
	int			whichOnFr ;	/* Which expanded curve is    */
						/* placed onto a "from" shell */
						/* expansion.		      */
	enum VSshell_type	type ;		/* Shell expansion type.      */
	double			yTrans ;	/* Y translation of merged    */
						/* shell expansion.	      */

	SetProc( VSmergeExpCv_ACconstruct_feet ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "ACconstruct_feet" //, argfmt = "", args = ``
        );

	*feetCount	= 0 ;
	feetList->objid = NULL_OBJID ;

	curves[0]._objid = curves[1]._objid = NULL_OBJID ;

	cvPol[0].points  = cvPol[1].points  = NULL ;
	mergedPol.points = NULL ;

	if( count < 2 ) vs$inv_arg() ;

	__DBGpr_int( "Count of parents", count ) ;

	/*
	 * Fill construction list.
	 */
	ex$message( msgnumb = VS_gI_Processing, justification = CENTER_JUS ) ;

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
	 * Get my merged shell expansion parent.
	 */
	sts = VSgetVirtualInfo( msg,
				list,
				&mergedSh.mod_env,
				&mergedSh._grid ) ;

	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	__DBGpr_obj( "Merged shell expansion parent", mergedSh._grid ) ;

	/*
	 * Get my expanded curve parents, consume it to get a copy of the
	 * curve feet and also get the polyline representing the curve feet.
	 */
	for( i=0; i<count-1; i++ ) {
		sts = VSgetVirtualInfo( msg,
					list +i +1,
					&curves[i].mod_env,
					expCv +i ) ;

		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		sts = vs$consume( msg		= msg,
				  objId 	= expCv +i,
				  ftEnv 	= MyEnv,
				  nbfeet	= 1,
				  feet		= &curves[i]._grid ) ;

		__CheckRC( sts, *msg, "vs$consume", wrapup ) ;

		__DBGpr_int( "Expanded curve #", i		 ) ;
		__DBGpr_obj( "\t",		 expCv[i]	 ) ;
		__DBGpr_obj( "\tfeet curve",	 curves[i]._grid ) ;

		sts = VSget_polyline_of_curve( msg,
					       &curves[i]._grid,
					       &curves[i].mod_env,
					       cvPol +i ) ;

		__CheckRC( sts, *msg, "VSget_polyline_of_curve", wrapup ) ;

		__DBGpr_vec( "\tbegin point", cvPol[i].points		) ;
		__DBGpr_vec( "\tend   point", cvPol[i].points +
					      3*(cvPol[i].num_points-1) ) ;
	}

	/*
	 * See which expanded curve is placed onto a "from" shell expansion.
	 */
	whichOnFr = -1 ;

	for( i=0; i<count-1; i++ ) {
		sts = om$send( msg	=
				message VSexpandedCv.VSget_shell_expansion_type(
									msg,
									&type ),
			       targetid = expCv[i].objid,
			       targetos = expCv[i].osnum ) ;

		__CheckRC( sts, *msg, "VSexpandedCv.VSget_shell_expansion_type",
			   wrapup ) ;

		/*
		 * If we have two expanded curves placed onto a "from" shell
		 * expansion, then error.
		 */
		if( whichOnFr != -1 && type == VSfrom ) vs$inv_arg() ;

		if( type == VSfrom ) whichOnFr = i ;
	}

	/*
	 * If we have two expanded curves placed onto a "to" shell expansion,
	 * then error.
	 */
	if( count == 3 && whichOnFr == -1 ) vs$inv_arg() ;

	__DBGpr_int( "Expanded curve placed onto the FROM", whichOnFr ) ;

	/*
	 * Get y translation of merged shell expansion and translate the
	 * polyline of the expanded curve which is placed onto a "from" shell
	 * expansion.
	 */
	if( whichOnFr != -1 ) {
		sts = om$send( msg	=
					 message VSshellExp.VSget_y_translation(
							      msg,
							      &mergedSh.mod_env,
							      &yTrans ),
			       targetid = mergedSh._objid,
			       targetos = mergedSh._osnum ) ;

		__CheckRC( sts, *msg, "VSshellExp.VSget_y_translation",
			   wrapup ) ;

		__DBGpr_dbl( "Y translation", yTrans ) ;

		for( i=0; i<cvPol[whichOnFr].num_points; i++ )
			cvPol[whichOnFr].points[3*i+1] += yTrans ;

		__DBGpr_vec( "New begin point", cvPol[whichOnFr].points      ) ;
		__DBGpr_vec( "New end	point", cvPol[whichOnFr].points +
						3 *
					     (cvPol[whichOnFr].num_points-1) ) ;

	}

	/*
	 * Construct polyline of merged expanded curve.
	 */
	if( count == 2 ) {
		/*
		 * Only one expanded curve as parent, so the polyline of
		 * the merged expanded curve is the polyline of the expanded
		 * curve parent translated or not ( depending on which type
		 * of shell expansion is placed the expanded curve parent ).
		 */
		mergedPol.num_points = cvPol[0].num_points ;
		mergedPol.points     = cvPol[0].points ;
	} else {
		/*
		 * Two expanded curves as parent, so the polyline of the merged
		 * expanded curve is the merge of the polyline of the expanded
		 * curves parent.
		 */
		long	bsRC ; /* BS return code.			      */
		int	j ;    /* Loop index.				      */
		double	*a1,   /* Begin point of first expanded curve parent. */
			*b1,   /* End	point of first expanded curve parent. */
			*a2,   /* Begin point of second expanded curve parent.*/
			*b2 ;  /* End	point of second expanded curve parent.*/
		int	r1,    /* Reverse first polyline ? ( TRUE/FALSE )     */
			r2 ;   /* Reverse seconf polyline ? ( TRUE/FALSE )    */
		double	dmin,  /* Minimum distance between two end points.    */
			dist ; /* Distance between two end points.	      */

		a1 = cvPol[0].points ;
		b1 = cvPol[0].points + 3*(cvPol[0].num_points-1) ;

		a2 = cvPol[1].points ;
		b2 = cvPol[1].points + 3*(cvPol[1].num_points-1) ;

		r1 = r2 = FALSE ;

		dmin = IGE_DESIGN_LIMITS_MAX ;

		/*
		 * See how we merge the two polylines.
		 */
			/*
			 * b1 -----<------ a1 a2 ----->------ b2
			 *
			 * b2 -----<------ a2 a1 ----->------ b1
			 */
		dist = BSdistptpt( &bsRC, a1, a2 ) ;
		if( dist < dmin ) {
			dmin = dist ;
			r1   = TRUE ;
			r2   = FALSE ;
		}

			/*
			 * b1 -----<------ a1 b2 -----<------ a2
			 *
			 * a2 ----->------ b2 a1 ----->------ b1
			 */
		dist = BSdistptpt( &bsRC, a1, b2 ) ;
		if( dist < dmin ) {
			dmin = dist ;
			r1   = TRUE ;
			r2   = TRUE ;
		}

			/*
			 * a1 ----->------ b1 a2 ----->------ b2
			 *
			 * b2 -----<------ a2 b1 -----<------ a1
			 */
		dist = BSdistptpt( &bsRC, b1, a2 ) ;
		if( dist < dmin ) {
			dmin = dist ;
			r1   = FALSE ;
			r2   = FALSE ;
		}

			/*
			 * a1 ----->------ b1 b2 -----<------ a2
			 *
			 * a2 ----->------ b2 b1 -----<------ a1
			 */
		dist = BSdistptpt( &bsRC, b1, b2 ) ;
		if( dist < dmin ) {
			dmin = dist ;
			r1   = FALSE ;
			r2   = TRUE ;
		}

		__DBGpr_dbl( "Minimum distance",      dmin ) ;
		__DBGpr_int( "Reverse polyline #1 ?", r1   ) ;
		__DBGpr_int( "Reverse polyline #2 ?", r2   ) ;

		/*
		 * Merge the two polylines.
		 */
		mergedPol.num_points = cvPol[0].num_points +
				       cvPol[1].num_points ;

		if( !( mergedPol.points = _MALLOC( 3*(mergedPol.num_points+1),
						   double ) ) )
			vs$mem_fail() ;

		j = 0 ;

		for( i = r1 ? cvPol[0].num_points-1 : 0 		      ;
			 r1 ? i >= 0		    : i < cvPol[0].num_points ;
			 r1 ? i--		    : i++		      )

			VSvccpy( mergedPol.points + 3*(j++),
				 cvPol[0].points  + 3*i     ) ;

		for( i = r2 ? cvPol[1].num_points-1 : 0 		      ;
			 r2 ? i >= 0		    : i < cvPol[1].num_points ;
			 r2 ? i--		    : i++		      )

			VSvccpy( mergedPol.points + 3*(j++),
				 cvPol[1].points  + 3*i     ) ;
	}

	/*
	 * Construct the merged expanded curve feet.
	 */
	feetList[0].osnum = cst.env_info->_MD_OS ;

	sts = ems$place_line_string( msg	       = msg,
				     number_of_points  = mergedPol.num_points,
				     points	       = mergedPol.points,
				     construction_args = &cst,
				     objid	       = &feetList[0].objid ) ;

	__CheckRC( sts, *msg, "ems$place_line_string", wrapup ) ;

	__DBGpr_obj( "Merged expanded curve feet", feetList[0] ) ;

	*feetCount = 1 ;

	om$change_tag_version() ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		ex$message( msgnumb = VS_gI_EmptyMessage ) ;

		if( !( sts & 1 & *msg ) ) {
			if( purpose & VS_K_InitialPlacement ) {
				long rc ;

				for( i=0; i<count-1; i++ )
					if( !IF_NULL_OBJID( curves[i]._objid ) )
					     vs$unconsume( msg	   = &rc,
							   object  = expCv +i,
							   mod_env = MyEnv ) ;

				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
				sts = OM_S_SUCCESS ;
			}
		}

		vs$bulk_delete( count	= count -1,
				objenvs = curves ) ;

		if( count == 3 ) _FREE( mergedPol.points ) ;

		_FREE( cvPol[0].points ) ;
		_FREE( cvPol[1].points ) ;

        __exitMethod ( name = "ACconstruct_feet", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End

		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSmergeExpCv ;
