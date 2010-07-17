/* $Id: VSmscnstfeet.I,v 1.2 2001/08/17 21:58:39 hans Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsshellexp/VSmscnstfeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmscnstfeet.I,v $
 *      Revision 1.2  2001/08/17 21:58:39  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:00  cvs
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
/*
	I/STRUCT
*/
class implementation VSmergeShExp ;

#include <stdio.h>
#include <math.h>
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "EMSwrmacros.h"
#include "vsshexpdef.h"
#include "vsiomacros.h"
#include "vsgeommacros.h"
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

extern OMuword	OPP_EMSplane_class_id ;

from EMSplane	import EMssgetbdry,
		       EMplane_of_curve ;

/*----------------------------------------------------------------------------*/
static long VSreorderBoundaryPoints( msg, first, num_points, points )

long		*msg ;
int		first ;
long		num_points ;
double		*points ;
{
	/*
	 * This function re-orders the list 'points' so that the first point
	 * of the list will be the point at the index 'first'.
	 */

	long			sts ;		/* OM return code.	      */
	int			i ;		/* Loop index.		      */
	double			*list = NULL ;	/* List of ordered points.    */

        __enterFunction ( name = "VSreorderBoundaryPoints" //, argfmt = "", args = ``
        );

	if( first == 0 ) {
		sts  = OM_S_SUCCESS ;
		*msg = MSSUCC ;
		goto wrapup ;
	}

	if( !( list = _MALLOC( 3*(num_points+1), double ) ) )
		vs$mem_fail() ;

	for( i=first; i<num_points; i++ )
		VSvccpy( list + 3*( i - first ), points + 3*i ) ;

	for( i=1; i<first; i++ )
		VSvccpy( list + 3*( num_points - first + i-1 ), points + 3*i ) ;

	for( i=0; i<num_points-1; i++ )
		VSvccpy( points + 3*i, list + 3*i ) ;

	VSvccpy( points + 3*( num_points - 1 ), list ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( list ) ;

        __exitFunction ( name = "VSreorderBoundaryPoints", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		return sts ;

} /* VSreorderBoundaryPoints */
/*----------------------------------------------------------------------------*/
method ACconstruct_feet( long			*msg ;
			 int			purpose,
						count ;
			 struct GRid		list[] ;
			 struct GRmd_env	*MyEnv ;
			 int			*feetCount ;
			 struct GRid		*feetList )
{
	long			sts ;		/* OM return code.	      */
	int			i,		/* Loop index.		      */
				j ;		/* Loop index.		      */
	struct GRvg_construct	cst ;		/* My construction list.      */
	struct GRsymbology	symb ;		/* My symbology.	      */
	struct GRid		inFrShExp,	/* "from" shell expansion     */
						/* parent.		      */
				inToShExp,	/* "to" shell expansion       */
						/* parent.		      */
				imageOfShell ;	/* Image of merged shell      */
						/* expansion.		      */
	struct GRobj_env	plFrShExp,	/* plane feet of "from" shell */
						/* expansion.		      */
				plToShExp,	/* plane feet of "to" shell   */
						/* expansion.		      */
				*objEnvs ;	/* List of obj env.	      */
	struct IGRpolyline	*frShExpBdry,	/* Boundaries of the "from"   */
						/* shell expansion.	      */
				*toShExpBdry ;	/* Boundaries of the "to"     */
						/* shell expansion.	      */
	int			nbFrShExpBdry,	/* Number of above boundaries.*/
				nbToShExpBdry,	/* Number of above boundaries.*/
				nbBound,	/* Number of inner boundaries.*/
				nbImp ; 	/* Number of inner boundaries */
						/* to impose onto merged shell*/
						/* expansion.		      */
	double			tollenvec,	/* Minimum length of vector.  */
				frBegPt[3],	/* Begin point of "from"      */
						/* shell expansion.	      */
				frEndPt[3],	/* End point of "from" shell  */
						/* expansion.		      */
				toBegPt[3],	/* Begin point of "to" shell  */
						/* expansion.		      */
				toEndPt[3],	/* End point of "to" shell    */
						/* expansion.		      */
				xRef,		/* Comon X coordinate value of*/
						/* the above limiting points. */
				yFrMin, 	/* Y coordinate value of      */
						/* the boundary point of the  */
						/* "from" shell expansion     */
						/* which is at minimum Y value*/
						/* and have X = xRef.	      */
				yToMin, 	/* Y coordinate value of      */
						/* the boundary point of the  */
						/* "to" shell expansion       */
						/* which is at minimum Y value*/
						/* and have X = xRef.	      */
				deltaX, 	/* Delta along X axis between */
						/* a boundary point and comon */
						/* X coordinate value.	      */
				*polyline ;	/* Polyline of merged shell   */
						/* expansion.		      */
	int			nbPtPol,	/* Number of points of above  */
						/* polyline.		      */
				frMinIndex,	/* Index of the boundary      */
						/* point of the "from" shell  */
						/* expansion at minimum Y     */
						/* coordinate value.	      */
				toMinIndex,	/* Index of the boundary      */
						/* point of the "to" shell    */
						/* expansion at minimum Y     */
						/* coordinate value.	      */
				Yn_2SupY1 ;	/* Is Y of boundary point     */
						/* #n-2 superior to #1 ?      */
	struct GRlc_info	cvInfo ;	/* Curve information.	      */

	SetProc( VSmergeShExp_ACconstruct_feet ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "ACconstruct_feet" //, argfmt = "", args = ``
        );

	*feetCount	= 0 ;
	feetList->objid = NULL_OBJID ;

	nbFrShExpBdry	= nbToShExpBdry = 0 ;
	frShExpBdry	= toShExpBdry	= NULL ;

	plFrShExp._objid= plToShExp._objid = NULL_OBJID ;

	frMinIndex	= toMinIndex	= -1 ;
	yFrMin		= yToMin	= 0. ;

	polyline	= NULL ;

	imageOfShell.objid	 = NULL_OBJID ;
	cvInfo.located_obj.objid = NULL_OBJID ;

	nbBound = nbImp = 0 ;
	objEnvs 	= NULL ;

	if( count != 2 ) vs$inv_arg() ;

	BSEXTRACTPAR( msg, BSTOLLENVEC, tollenvec ) ;

	vs$dotsInStsFld( dots = 0 ) ;

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
	 * Get my "from" shell expansion parent.
	 */
	sts = VSgetVirtualInfo( msg,
				list,
				&plFrShExp.mod_env,
				&inFrShExp ) ;

	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	__DBGpr_obj( "FROM shell expansion", inFrShExp ) ;

	/*
	 * Get my "to" shell expansion parent.
	 */
	sts = VSgetVirtualInfo( msg,
				list +1,
				&plToShExp.mod_env,
				&inToShExp ) ;

	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	__DBGpr_obj( "TO   shell expansion", inToShExp ) ;

	/*
	 * Consume "from" shell expansiom parent and get a copy of its plane
	 * feet.
	 */
	sts = vs$consume( msg		= msg,
			  objId 	= &inFrShExp,
			  ftEnv 	= MyEnv,
			  nbfeet	= 1,
			  feet		= &plFrShExp._grid ) ;

	__CheckRC( sts, *msg, "vs$consume", wrapup ) ;

	/*
	 * Consume "to" shell expansiom parent and get a copy of its plane
	 * feet.
	 */
	sts = vs$consume( msg		= msg,
			  objId 	= &inToShExp,
			  ftEnv 	= MyEnv,
			  nbfeet	= 1,
			  feet		= &plToShExp._grid ) ;

	__CheckRC( sts, *msg, "vs$consume", wrapup ) ;

	/*
	 * Get limiting points of "from" shell expansion.
	 */
	vs$dotsInStsFld() ;

	sts = om$send( msg	= message VSshellExp.VSget_limiting_points(
							     msg,
							     &plFrShExp.mod_env,
							     frBegPt,
							     frEndPt ),
		       targetid = inFrShExp.objid,
		       targetos = inFrShExp.osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_limiting_points", wrapup ) ;

	__DBGpr_vec( "Begin point of FROM shell expansion", frBegPt ) ;
	__DBGpr_vec( "End   point of FROM shell expansion", frEndPt ) ;

	/*
	 * Get limiting points of "to" shell expansion.
	 */
	vs$dotsInStsFld() ;

	sts = om$send( msg	= message VSshellExp.VSget_limiting_points(
							     msg,
							     &plToShExp.mod_env,
							     toBegPt,
							     toEndPt ),
		       targetid = inToShExp.objid,
		       targetos = inToShExp.osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_limiting_points", wrapup ) ;

	__DBGpr_vec( "Begin point of TO shell expansion", toBegPt ) ;
	__DBGpr_vec( "End   point of TO shell expansion", toEndPt ) ;

	/*
	 * Find comon X coordinate value.
	 */
	if( frBegPt[0] == toEndPt[0] ) xRef = frBegPt[0] ;
	else if( frEndPt[0] == toBegPt[0] ) xRef = frEndPt[0] ;
	     else vs$inv_arg() ;

	__DBGpr_dbl( "X reference", xRef ) ;

	/*
	 * Get boundaries of the "from" shell expansion plane.
	 */
	vs$dotsInStsFld() ;

	sts = om$send( msg	= message EMSplane.EMssgetbdry(
							msg,
							&plFrShExp._matrix_type,
							plFrShExp._matrix,
							0,
							&nbFrShExpBdry,
							&frShExpBdry,
							NULL,
							NULL,
							NULL,
							NULL ),
		       targetid = plFrShExp._objid,
		       targetos = plFrShExp._osnum ) ;

	__CheckRC( sts, *msg, "EMSplane.EMssgetbdry", wrapup ) ;

	/*
	 * Get boundaries of the "to" shell expansion plane.
	 */
	vs$dotsInStsFld() ;

	sts = om$send( msg	= message EMSplane.EMssgetbdry(
							msg,
							&plToShExp._matrix_type,
							plToShExp._matrix,
							0,
							&nbToShExpBdry,
							&toShExpBdry,
							NULL,
							NULL,
							NULL,
							NULL ),
		       targetid = plToShExp._objid,
		       targetos = plToShExp._osnum ) ;

	__CheckRC( sts, *msg, "EMSplane.EMssgetbdry", wrapup ) ;

	/*
	 * Find minimum Y value of boundary points of "from" shell expansion
	 * which is at the comon X coordinate value.
	 */
	vs$dotsInStsFld() ;

	deltaX = yFrMin = IGE_DESIGN_LIMITS_MAX ;

	for( i=0; i<frShExpBdry[0].num_points; i++ ) {
		__DBGpr_vec( "FROM point", frShExpBdry[0].points +3*i ) ;

		if( fabs( fabs( frShExpBdry[0].points[3*i] - xRef )
			  - deltaX ) <= tollenvec ) {
			if( yFrMin > frShExpBdry[0].points[3*i+1] ) {
				yFrMin	   = frShExpBdry[0].points[3*i+1] ;
				frMinIndex = i ;
				__DBGpr_dbl( "\tnew Y min", yFrMin ) ;
			}
			continue ;
		}

		if( fabs( frShExpBdry[0].points[3*i] - xRef ) < deltaX ) {
			deltaX	   = fabs( frShExpBdry[0].points[3*i] - xRef ) ;
			yFrMin	   = frShExpBdry[0].points[3*i+1] ;
			frMinIndex = i ;
			__DBGpr_dbl( "\tdelta X", deltaX ) ;
			__DBGpr_dbl( "\tY min",   yFrMin ) ;
		}
	}

	__DBGpr_dbl( "Y min of FROM shell expansion", yFrMin	 ) ;
	__DBGpr_int( "at point ( index )",	      frMinIndex ) ;

	/*
	 * Find minimum Y value of boundary points of "to" shell expansion
	 * which is at the comon X coordinate value.
	 */
	vs$dotsInStsFld() ;

	deltaX = yToMin = IGE_DESIGN_LIMITS_MAX ;

	for( i=0; i<toShExpBdry[0].num_points; i++ ) {
		__DBGpr_vec( "TO point", toShExpBdry[0].points +3*i ) ;

		if( fabs( fabs( toShExpBdry[0].points[3*i] - xRef )
			  - deltaX ) <= tollenvec ) {
			if( yToMin > toShExpBdry[0].points[3*i+1] ) {
				yToMin	   = toShExpBdry[0].points[3*i+1] ;
				toMinIndex = i ;
				__DBGpr_dbl( "\tnew Y min", yToMin ) ;
			}
			continue ;
		}

		if( fabs( toShExpBdry[0].points[3*i] - xRef ) < deltaX ) {
			deltaX	   = fabs( toShExpBdry[0].points[3*i] - xRef ) ;
			yToMin	   = toShExpBdry[0].points[3*i+1] ;
			toMinIndex = i ;
			__DBGpr_dbl( "\tdelta X", deltaX ) ;
			__DBGpr_dbl( "\tY min",   yToMin ) ;
		}
	}

	__DBGpr_dbl( "Y min of TO   shell expansion", yToMin	 ) ;
	__DBGpr_int( "at point ( index )",	      toMinIndex ) ;

	/*
	 * Translate "from" shell expansion boundaries.
	 */
	vs$dotsInStsFld() ;

	if( (yToMin - yFrMin) != 0. )
		for( i=0; i<nbFrShExpBdry; i++ )
			for( j=0; j<frShExpBdry[i].num_points; j++ )
			       frShExpBdry[i].points[3*j+1] += yToMin - yFrMin ;

	/*
	 * Re-order boundary points of "from" shell expansion to have as first
	 * point in list the point at minimum Y coordinate value.
	 */
	vs$dotsInStsFld() ;

	sts = VSreorderBoundaryPoints( msg,
				       frMinIndex,
				       frShExpBdry[0].num_points,
				       frShExpBdry[0].points ) ;

	__CheckRC( sts, *msg, "VSreorderBoundaryPoints", wrapup ) ;

	/*
	 * Re-order boundary points of "to" shell expansion to have as first
	 * point in list the point at minimum Y coordinate value.
	 */
	vs$dotsInStsFld() ;

	sts = VSreorderBoundaryPoints( msg,
				       toMinIndex,
				       toShExpBdry[0].num_points,
				       toShExpBdry[0].points ) ;

	__CheckRC( sts, *msg, "VSreorderBoundaryPoints", wrapup ) ;

	/*
	 * Construct the polyline of merged shell expansion.
	 */
	vs$dotsInStsFld() ;

	if( !( polyline = _MALLOC( 3*( frShExpBdry[0].num_points +
				       toShExpBdry[0].num_points + 1),
				   double ) ) )
		vs$mem_fail() ;

		/*
		 * Add "to" shell expansion.
		 */
	nbPtPol = 0 ;

	Yn_2SupY1 = toShExpBdry[0].points[3*(toShExpBdry[0].num_points-2) +1]
		    >
		    toShExpBdry[0].points[3*1+1] ;

	for( i = Yn_2SupY1 ? 0 : toShExpBdry[0].num_points - 1 ;
	     Yn_2SupY1 ? i<toShExpBdry[0].num_points - 1 : i>0 ;
	     Yn_2SupY1 ? i++ : i-- )
		VSvccpy( polyline +3*(nbPtPol++), toShExpBdry[0].points +3*i ) ;

		/*
		 * Add "from" shell expansion.
		 */

	Yn_2SupY1 = frShExpBdry[0].points[3*(frShExpBdry[0].num_points-2) +1]
		    >
		    frShExpBdry[0].points[3*1+1] ;

	for( i = !Yn_2SupY1 ? 1 : frShExpBdry[0].num_points - 2 ;
	     !Yn_2SupY1 ? i<frShExpBdry[0].num_points : i>=0 ;
	     !Yn_2SupY1 ? i++ : i-- )
		VSvccpy( polyline +3*(nbPtPol++), frShExpBdry[0].points +3*i ) ;

		/*
		 * Close polyline.
		 */
	VSvccpy( polyline +3*(nbPtPol++), polyline ) ;

	/*
	 * Construct a plane whose boundary is the above polyline.
	 */
	vs$dotsInStsFld() ;

	imageOfShell.osnum = cst.env_info->_MD_OS ;

	sts = om$construct( classid	= OPP_EMSplane_class_id,
			    osnum	= imageOfShell.osnum,
			    p_objid	= &imageOfShell.objid ) ;

	__CheckRC( sts, 1, "om$construct", wrapup ) ;

	cvInfo.located_obj.osnum = cst.env_info->_MD_OS ;
	cvInfo.module_info	 = *cst.env_info ;

	sts = ems$place_line_string(
			       msg		 = msg,
			       number_of_points  = nbPtPol,
			       points		 = polyline,
			       construction_args = &cst,
			       objid		 = &cvInfo.located_obj.objid ) ;

	__CheckRC( sts, *msg, "ems$place_line_string", wrapup ) ;

	sts = om$send( msg	= message EMSplane.EMplane_of_curve( msg,
								     &cst,
								     &cvInfo,
								     NULL,
								     NULL,
								     TRUE,
								     TRUE,
								     NULL,
								     NULL ),
		       targetid = imageOfShell.objid,
		       targetos = imageOfShell.osnum ) ;

	__CheckRC( sts, *msg, "EMSplane.EMplane_of_curve", wrapup ) ;

	__DBGpr_obj( "Image of shell", imageOfShell ) ;

	/*
	 * For each inner boundaries of the "from" and "to" shell expansion,
	 * impose it onto image of shell.
	 */
	vs$dotsInStsFld() ;

	nbBound = nbFrShExpBdry + nbToShExpBdry - 2 ;

	if( nbBound ) {
		if( !( objEnvs = _MALLOC( nbBound +1, struct GRobj_env ) ) )
			vs$mem_fail() ;

		objEnvs[0]._grid   = imageOfShell ;
		objEnvs[0].mod_env = *cst.env_info ;

		for( i=0; i<nbBound; i++ ) {
			objEnvs[i+1]._osnum  = cst.env_info->_MD_OS ;
			objEnvs[i+1]._objid  = NULL_OBJID ;
			objEnvs[i+1].mod_env = *cst.env_info ;
		}

		for( i=1; i<nbFrShExpBdry; i++ ) {

			sts = ems$place_line_string(
				msg		  = msg,
				number_of_points  = frShExpBdry[i].num_points,
				points		  = frShExpBdry[i].points,
				construction_args = &cst,
				objid		  = &objEnvs[nbImp+1]._objid ) ;

			__CheckRC( sts, *msg, "ems$place_line_string", wrapup );

			nbImp++ ;
		}

		for( i=1; i<nbToShExpBdry; i++ ) {

			sts = ems$place_line_string(
				msg		  = msg,
				number_of_points  = toShExpBdry[i].num_points,
				points		  = toShExpBdry[i].points,
				construction_args = &cst,
				objid		  = &objEnvs[nbImp+1]._objid ) ;

			__CheckRC( sts, *msg, "ems$place_line_string", wrapup );

			nbImp++ ;
		}

		if( nbImp ) {
			sts = vs$imposeBoundaries( msg		= msg,
						   surface	= objEnvs +0,
						   bndryCount	= nbImp,
						   bndryList	= objEnvs +1,
						   sfIsPlanar	= TRUE ) ;

			__CheckRC( sts, *msg, "vs$imposeBoundaries", wrapup ) ;
		}
	}

	feetList[0]	= imageOfShell ;
	*feetCount	= 1 ;

	om$change_tag_version() ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		vs$dotsInStsFld( dots = clear ) ;

		/*
		 * Store Y translation if successfull.
		 */
		if( sts & 1 & *msg )
			me->yTranslation = yToMin - yFrMin ;

		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids  = &imageOfShell,
					theEnv = cst.env_info ) ;

			if( purpose & VS_K_InitialPlacement ) {
				long rc ;

				if( !IF_NULL_OBJID( plFrShExp._objid ) )
					vs$unconsume( msg     = &rc,
						      object  = &inFrShExp,
						      mod_env = MyEnv ) ;

				if( !IF_NULL_OBJID( plToShExp._objid ) )
					vs$unconsume( msg     = &rc,
						      object  = &inToShExp,
						      mod_env = MyEnv ) ;

				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
				sts = OM_S_SUCCESS ;
			}
		}

		vs$bulk_delete( objenvs = &plFrShExp ) ;
		vs$bulk_delete( objenvs = &plToShExp ) ;

		vs$bulk_delete( grids  = &cvInfo.located_obj,
				theEnv = &cvInfo.module_info ) ;

		if( nbBound && objEnvs )
			vs$bulk_delete( count	= nbBound,
					objenvs = objEnvs +1 ) ;

		for( i=0; i<nbFrShExpBdry; i++ )
			_FREE( frShExpBdry[i].points ) ;
		_FREE( frShExpBdry ) ;

		for( i=0; i<nbToShExpBdry; i++ )
			_FREE( toShExpBdry[i].points ) ;
		_FREE( toShExpBdry ) ;

		_FREE( polyline ) ;

        __exitMethod ( name = "ACconstruct_feet", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End

		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSmergeShExp ;
