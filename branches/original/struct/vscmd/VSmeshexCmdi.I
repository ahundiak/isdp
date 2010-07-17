/* $Id: VSmeshexCmdi.I,v 1.1.1.1 2001/01/04 21:10:25 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSmeshexCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmeshexCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/01  14:57:30  pinnacle
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

class implementation VSmeshexCmd ;

#include <stdio.h>
#include <math.h>
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "acrepdef.h"
#include "EMSmsgdef.h"
#include "vs.h"
#include "vsshexpdef.h"
#include "vscmddef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */

#define DELTA			5000	/* Used with the length vector	      */
					/* tolerance to have more precision.  */

from VSshellExp 	import VSget_expanded_curves ;
from VSmergeShExp	import VSget_y_translation ;
from NDmacro		import ACreturn_foot ;
from GRcurve		import GRendpts ;
from GRgraphics 	import GRconstruct ;

/*----------------------------------------------------------------------------*/
static int VScanMergeExpandedCurve( a1, b1, a2, b2, yTrans )

double	*a1,
	*b1,
	*a2,
	*b2,
	yTrans ; {

	/*
	 * 'a1' : Start point of an expanded curve placed onto a FROM shell exp.
	 * 'b1' : End	point of an expanded curve placed onto a FROM shell exp.
	 * 'a2' : Start point of an expanded curve placed onto a TO   shell exp.
	 * 'b2' : End	point of an expanded curve placed onto a TO   shell exp.
	 * 'yTrans' : Y translation used to translate the FROM shell expansion.
	 *
	 * This function returns TRUE if the two expanded curves can be merged,
	 * otherwise return FALSE.
	 */

	long		msg ;
	double		a1_t[3],
			b1_t[3],
			tollenvec ;
	int		merge ;

#define SAME_POINT( pt1, pt2 )\
	( fabs( (pt1)[0] - (pt2)[0] ) <= 2*(DELTA+1)*tollenvec ) &&\
	( fabs( (pt1)[1] - (pt2)[1] ) <= 2*(DELTA+1)*tollenvec )

	BSEXTRACTPAR( &msg, BSTOLLENVEC, tollenvec ) ;

	a1_t[0] = a1[0] ;
	a1_t[1] = a1[1] + yTrans ;
	a1_t[2] = a1[2] ;

	b1_t[0] = b1[0] ;
	b1_t[1] = b1[1] + yTrans ;
	b1_t[2] = b1[2] ;

	merge = FALSE ;

	if( SAME_POINT( a1_t, a2 ) ) merge = TRUE ;
	if( SAME_POINT( a1_t, b2 ) ) merge = TRUE ;
	if( SAME_POINT( b1_t, a2 ) ) merge = TRUE ;
	if( SAME_POINT( b1_t, b2 ) ) merge = TRUE ;

	return merge ;

#undef SAME_POINT

} /* VScanMergeExpandedCurve */
/*----------------------------------------------------------------------------*/
method handleError( int error ) {

	/*
	 * Delete constructed merged shell expansion.
	 */
	if( !IF_NULL_OBJID( me->constructedObject.objid ) )
		vs$bulk_delete( grids  = &me->constructedObject,
				theEnv = &me->cstEnv ) ;

	om$send( msg	  = message VSpartopCmd.handleError( error ),
		 mode	  = OM_e_wrt_message,
		 targetid = my_id ) ;

	return OM_S_SUCCESS ;

} /* handleError */
/*----------------------------------------------------------------------------*/
method merge_expanded_curve( long *msg ) {

	long			sts ;
	int			i,
				j,
				nbExCvFr,
				nbExCvTo ;
	struct GRobj_env	shExp[2],
				*exCvFr,
				*exCvTo,
				parents[3] ;
	struct GRid		curveId,
				mergeIdCnst ;
	double			yTrans,
				*endPtFr,
				*endPtTo ;
	struct GRvg_construct	cst ;
	struct VScnst_list	attr ;

#define CONSTRUCT_AND_DISPLAY( parent1, parent2, parentCount )\
	parents[1] = (parent1) ;\
	parents[2] = (parent2) ;\
	attr.parent_count = (parentCount) ;\
	mergeIdCnst.osnum = me->cstEnv._MD_OS ;\
	sts = om$construct(classname = "VSmergeExpCv",\
			   osnum     = mergeIdCnst.osnum,\
			   p_objid   = &mergeIdCnst.objid,\
			   msg	     = message GRgraphics.GRconstruct( &cst ));\
	if( sts & 1 & *msg ) {\
		__DBGpr_obj( "\t\tmerged expanded curve", mergeIdCnst ) ;\
		vs$bulk_display( grids	= &mergeIdCnst,\
				 theEnv = &me->cstEnv ) ;\
	} else {\
		 __DBGpr_com( "\t\tmerged expanded curve NOT CONSTRUCTED" ) ;\
		 goto wrapup ;\
	}

	SetProc( VSmeshexCmd_merge_expanded_curve ) ; Begin

	exCvFr	= exCvTo  = NULL ;
	endPtFr = endPtTo = NULL ;

	__DBGpr_obj( "Merged shell expansion", me->constructedObject ) ;

	/*
	 * Fill construction list ( Display and Level come from first expanded
	 * curve parent ).
	 */
	vs$fill_cnst_list( Cnst_list	= cst,
			   Msg		= msg,
			   Env_info	= &me->cstEnv,
			   Display	= NULL,
			   Level	= 0,
			   Class_attr	= &attr ) ;

	attr.parent_list    = parents ;
	attr.feature_att    = NULL ;
	attr.representation = AC_NO_REP ;

	/*
	 * First parent is always the merged shell expansion constructed.
	 */
	parents[0]._grid   = me->constructedObject ;
	parents[0].mod_env = me->cstEnv ;

	/*
	 * Get shell expansions located.
	 */
	sts = om$send( msg	= message VSlocateCmd.getLocObjs( msg,
								  2,
								  shExp ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	/*
	 * Get all expanded curves attached to the "from" shell expansion.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_expanded_curves(
							      msg,
							      &shExp[0].mod_env,
							      &nbExCvFr,
							      &exCvFr ),
		       targetid = shExp[0]._objid,
		       targetos = shExp[0]._osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_expanded_curves", wrapup ) ;

	__DBGpr_obj( "FROM shell expansion", shExp[0]._grid ) ;

	/*
	 * Get all expanded curves attached to the "to" shell expansion.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_expanded_curves(
							      msg,
							      &shExp[1].mod_env,
							      &nbExCvTo,
							      &exCvTo ),
		       targetid = shExp[1]._objid,
		       targetos = shExp[1]._osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_expanded_curves", wrapup ) ;

	__DBGpr_obj( "TO shell expansion", shExp[1]._grid ) ;

	/*
	 * Get y translation of the constructed merged shell expansion.
	 */
	sts = om$send( msg	= message VSmergeShExp.VSget_y_translation(
								    msg,
								    &me->cstEnv,
								    &yTrans ),
		       targetid = me->constructedObject.objid,
		       targetos = me->constructedObject.osnum ) ;

	__CheckRC( sts, *msg, "VSmergeShExp.VSget_y_translation", wrapup ) ;

	__DBGpr_dbl( "Y translation", yTrans ) ;

	/*
	 * Get end points of expanded curves attached to the "from" shell
	 * expansion.
	 */
	if( !( endPtFr = _MALLOC( 2*3*(nbExCvFr+1), double ) ) )
		vs$mem_fail() ;

	__DBGpr_int( "Count of expanded curves onto FROM", nbExCvFr ) ;

	for( i=0; i<nbExCvFr; i++ ) {

		__DBGpr_obj( "\texpanded curve", exCvFr[i]._grid ) ;

		sts = om$send( msg	= message NDmacro.ACreturn_foot(
							   msg,
							   VS_K_sxExpandedCurve,
							   &curveId,
							   NULL,
							   NULL ),
			       targetid = exCvFr[i]._objid,
			       targetos = exCvFr[i]._osnum ) ;

		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		sts = om$send( msg	= message GRcurve.GRendpts(
							msg,
							&exCvFr[i]._matrix_type,
							exCvFr[i]._matrix,
							endPtFr + 6*i,
							endPtFr + 6*i +3 ),
			       targetid = curveId.objid,
			       targetos = curveId.osnum ) ;

		__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

		__DBGpr_vec( "\t\tstart point", endPtFr + 6*i	 ) ;
		__DBGpr_vec( "\t\tend point",	endPtFr + 6*i +3 ) ;
	}

	/*
	 * Get end points of expanded curves attached to the "to" shell
	 * expansion.
	 */
	if( !( endPtTo = _MALLOC( 2*3*(nbExCvTo+1), double ) ) )
		vs$mem_fail() ;

	__DBGpr_int( "Count of expanded curves onto FROM", nbExCvFr ) ;

	for( i=0; i<nbExCvTo; i++ ) {

		__DBGpr_obj( "\texpanded curve", exCvTo[i]._grid ) ;

		sts = om$send( msg	= message NDmacro.ACreturn_foot(
							   msg,
							   VS_K_sxExpandedCurve,
							   &curveId,
							   NULL,
							   NULL ),
			       targetid = exCvTo[i]._objid,
			       targetos = exCvTo[i]._osnum ) ;

		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		sts = om$send( msg	= message GRcurve.GRendpts(
							msg,
							&exCvTo[i]._matrix_type,
							exCvTo[i]._matrix,
							endPtTo + 6*i,
							endPtTo + 6*i +3 ),
			       targetid = curveId.objid,
			       targetos = curveId.osnum ) ;

		__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

		__DBGpr_vec( "\t\tstart point", endPtTo + 6*i	 ) ;
		__DBGpr_vec( "\t\tend point",	endPtTo + 6*i +3 ) ;
	}

	/*
	 * Merge expanded curves two by two.
	 */
	for( i=0; i<nbExCvFr; i++ ) {

		for( j=0; j<nbExCvTo; j++ ) {

			if( IF_NULL_OBJID( exCvTo[j]._objid ) ) continue ;

			if( VScanMergeExpandedCurve( endPtFr + 6*i,
						     endPtFr + 6*i +3,
						     endPtTo + 6*j,
						     endPtTo + 6*j +3,
						     yTrans ) ) {

				__DBGpr_com( "Merged expanded curves"  ) ;
				__DBGpr_obj( "\tFROM", exCvFr[i]._grid ) ;
				__DBGpr_obj( "\tTO  ", exCvTo[j]._grid ) ;

				CONSTRUCT_AND_DISPLAY( exCvFr[i],
						       exCvTo[j],
						       3 ) ;

				exCvFr[i]._objid = NULL_OBJID ;
				exCvTo[j]._objid = NULL_OBJID ;

				break ;
			}
		}
	}

	/*
	 * 'Merge' expanded curves attached to the "from" shell expansion
	 * not merged with an expanded curve attached to the "to" shell
	 * expansion.
	 */
	__DBGpr_com( "Alone on FROM" ) ;

	for( i=0; i<nbExCvFr; i++ ) {

		if( IF_NULL_OBJID( exCvFr[i]._objid ) ) continue ;

		__DBGpr_obj( "\t", exCvFr[i]._grid ) ;

		CONSTRUCT_AND_DISPLAY( exCvFr[i], exCvFr[i], 2 ) ;
	}

	/*
	 * 'Merge' expanded curves attached to the "to" shell expansion
	 * not merged with an expanded curve attached to the "from" shell
	 * expansion.
	 */
	__DBGpr_com( "Alone on TO" ) ;

	for( i=0; i<nbExCvTo; i++ ) {

		if( IF_NULL_OBJID( exCvTo[i]._objid ) ) continue ;

		__DBGpr_obj( "\t", exCvTo[i]._grid ) ;

		CONSTRUCT_AND_DISPLAY( exCvTo[i], exCvTo[i], 2 ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	me->constructedObject.objid = NULL_OBJID ;

	wrapup :
		*msg = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

		_FREE( exCvFr  ) ;
		_FREE( exCvTo  ) ;
		_FREE( endPtFr ) ;
		_FREE( endPtTo ) ;

		End
		return OM_S_SUCCESS ;

} /* merge_expanded_curve */
/*----------------------------------------------------------------------------*/

end implementation VSmeshexCmd ;
