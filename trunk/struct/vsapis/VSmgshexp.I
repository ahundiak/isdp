/* $Id: VSmgshexp.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSmgshexp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSmgshexp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1996/04/25  11:02:38  pinnacle
# Replaced: vsapis/VSmgshexp.I for:  by rchennup for struct
#
# Revision 1.1  1996/02/20  23:45:18  pinnacle
# Created: ./vsapis/VSmgshexp.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *
 ***************************************************************************/

class implementation VSshellExp ;

#include <stdio.h>
#include <math.h>
#include "OMmacros.h"
#include "madef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "exmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "VDSsymb_def.h"
#include "vsshexpdef.h"
#include "vscmdmacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

#define DELTA			5000	/* Used with the length vector	      */
					/* tolerance to have more precision.  */

from GRcurve		import GRendpts ;

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
static long VSmergeExpandedCurve( msg, 
				  mgXpansId,
				  frXpansId,
			          frXpansEnv,
			          toXpansId,
			          toXpansEnv,
				  cstEnv )

long			*msg ;
struct GRid		*mgXpansId ;
struct GRid		*frXpansId ;
struct GRmd_env		*frXpansEnv ;
struct GRid		*toXpansId ;
struct GRmd_env		*toXpansEnv ;
struct GRmd_env		*cstEnv ; {

	long			sts ;
	int			i,
				j,
				nbExCvFr,
				nbExCvTo ;
	struct GRobj_env	*exCvFr,
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
	mergeIdCnst.osnum = cstEnv->_MD_OS ;\
	sts = om$construct(classname = "VSmergeExpCv",\
			   osnum     = mergeIdCnst.osnum,\
			   p_objid   = &mergeIdCnst.objid,\
			   msg	     = message GRgraphics.GRconstruct( &cst ));\
	if( sts & 1 & *msg ) {\
		__DBGpr_obj( "\t\tmerged expanded curve", mergeIdCnst ) ;\
		vs$bulk_display( grids	= &mergeIdCnst,\
				 theEnv = cstEnv ) ;\
	} else {\
		 __DBGpr_com( "\t\tmerged expanded curve NOT CONSTRUCTED" ) ;\
		 goto wrapup ;\
	}

	SetProc( VSmergeExpandedCurve ) ; Begin

	exCvFr	= exCvTo  = NULL ;
	endPtFr = endPtTo = NULL ;

	__DBGpr_obj( "Merged shell expansion", *mgXpansId ) ;

	/*
	 * Fill construction list ( Display and Level come from first expanded
	 * curve parent ).
	 */
	vs$fill_cnst_list( Cnst_list	= cst,
			   Msg		= msg,
			   Env_info	= cstEnv,
			   Display	= NULL,
			   Level	= 0,
			   Class_attr	= &attr ) ;

	attr.parent_list    = parents ;
	attr.feature_att    = NULL ;
	attr.representation = AC_NO_REP ;

	/*
	 * First parent is always the merged shell expansion constructed.
	 */
	parents[0]._grid   = *mgXpansId ;
	parents[0].mod_env = *cstEnv ;

	/*
	 * Get all expanded curves attached to the "from" shell expansion.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_expanded_curves(
							      msg,
							      frXpansEnv,
							      &nbExCvFr,
							      &exCvFr ),
		       senderid = NULL_OBJID,
		       targetid = frXpansId->objid,
		       targetos = frXpansId->osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_expanded_curves", wrapup ) ;

	__DBGpr_obj( "FROM shell expansion", *frXpansId ) ;

	/*
	 * Get all expanded curves attached to the "to" shell expansion.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_expanded_curves(
							      msg,
							      toXpansEnv,
							      &nbExCvTo,
							      &exCvTo ),
		       senderid = NULL_OBJID,
		       targetid = toXpansId->objid,
		       targetos = toXpansId->osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_expanded_curves", wrapup ) ;

	__DBGpr_obj( "TO shell expansion", *toXpansId ) ;

	/*
	 * Get y translation of the constructed merged shell expansion.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_y_translation(
								    msg,
								    cstEnv,
								    &yTrans ),
		       senderid = NULL_OBJID,
		       targetid = mgXpansId->objid,
		       targetos = mgXpansId->osnum ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_y_translation", wrapup ) ;

	__DBGpr_dbl( "Y translation", yTrans ) ;

	/*
	 * Get end points of expanded curves attached to the "from" shell
	 * expansion.
	 */
	if( !( endPtFr = _MALLOC( 2*3*nbExCvFr, double ) ) )
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
		               senderid = NULL_OBJID,
			       targetid = exCvFr[i]._objid,
			       targetos = exCvFr[i]._osnum ) ;

		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		sts = om$send( msg	= message GRcurve.GRendpts(
							msg,
							&exCvFr[i]._matrix_type,
							exCvFr[i]._matrix,
							endPtFr + 6*i,
							endPtFr + 6*i +3 ),
		               senderid = NULL_OBJID,
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
	if( !( endPtTo = _MALLOC( 2*3*nbExCvTo, double ) ) )
		vs$mem_fail() ;

	__DBGpr_int( "Count of expanded curves onto TO", nbExCvTo ) ;

	for( i=0; i<nbExCvTo; i++ ) {

		__DBGpr_obj( "\texpanded curve", exCvTo[i]._grid ) ;

		sts = om$send( msg	= message NDmacro.ACreturn_foot(
							   msg,
							   VS_K_sxExpandedCurve,
							   &curveId,
							   NULL,
							   NULL ),
		               senderid = NULL_OBJID,
			       targetid = exCvTo[i]._objid,
			       targetos = exCvTo[i]._osnum ) ;

		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		sts = om$send( msg	= message GRcurve.GRendpts(
							msg,
							&exCvTo[i]._matrix_type,
							exCvTo[i]._matrix,
							endPtTo + 6*i,
							endPtTo + 6*i +3 ),
		               senderid = NULL_OBJID,
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

	wrapup :
		_FREE( exCvFr  ) ;
		_FREE( exCvTo  ) ;
		_FREE( endPtFr ) ;
		_FREE( endPtTo ) ;

		End
		return sts ;

} /* VSmergeExpandedCurve */
/*----------------------------------------------------------------------------*/
long VSmerge_shell_expansion( msg,
			      frXpansId,
			      frXpansEnv,
			      toXpansId,
			      toXpansEnv,
			      mgXpansId )

long			*msg ;
struct GRid		*frXpansId ;
struct GRmd_env		*frXpansEnv ;
struct GRid		*toXpansId ;
struct GRmd_env		*toXpansEnv ;
struct GRid		*mgXpansId ; {

	/*
	 * This function is interfaced by macro 'vs$merge_shell_expansion'.
	 */

	long			sts ;
	struct GRobj_env	parents[2] ;
	struct GRmd_env 	curEnv ;
	struct GRvg_construct	cst ;
	struct VScnst_list	attr ;

	SetProc( VSmerge_shell_expansion ) ; Begin

	mgXpansId->objid = NULL_OBJID ;

	__DBGpr_obj( "FROM shell expansion", *frXpansId ) ;
	__DBGpr_obj( "TO shell expansion",   *toXpansId ) ;

	/*
	 * Get current module environnement.
	 */
	sts = ex$get_cur_mod( osnum = &curEnv._MD_OS,
			      id    = &curEnv._MD_ID ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;

	/*
	 * Fill construction list.
	 */
	vs$fill_cnst_list( Cnst_list	= cst,
			   Msg		= msg,
			   Env_info	= &curEnv,
			   Display	= NULL,
			   Level	= 0,
			   Class_attr	= &attr ) ;

	attr.parent_list  = parents ;
	attr.parent_count = 2 ;

	parents[0]._grid   = *frXpansId ;
	parents[0].mod_env = frXpansEnv ? *frXpansEnv : curEnv ;
	parents[1]._grid   = *toXpansId ;
	parents[1].mod_env = toXpansEnv ? *toXpansEnv : curEnv ;

	attr.representation = AC_NO_REP ;
	attr.feature_att    = NULL ;

	/*
	 * Construct merge shell expansion.
	 */
	mgXpansId->osnum = curEnv.md_id.osnum ;

	sts = om$construct( classname = "VSmergeShExp",
			    osnum     = mgXpansId->osnum,
			    p_objid   = &mgXpansId->objid,
			    msg       = message GRgraphics.GRconstruct( &cst ) ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

	__DBGpr_obj( "Created merge shell expansion", *mgXpansId ) ;

	/*
	 * Merge expanded curve.
	 */
	sts = VSmergeExpandedCurve( msg, 
				    mgXpansId,
				    frXpansId,
			            frXpansEnv ? frXpansEnv : &curEnv,
			            toXpansId,
			            toXpansEnv ? toXpansEnv : &curEnv,
				    &curEnv ) ;

	__CheckRC( sts, *msg, "VSmergeExpandedCurve", wrapup ) ;

	/*
	 * Display merge shell expansion.
	 */
	vs$bulk_display( grids	= mgXpansId,
			 theEnv = &curEnv ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( mgXpansId->objid != NULL_OBJID )
				vs$bulk_delete( grids  = mgXpansId,
						theEnv = &curEnv ) ;
		}

		End
		return sts ;

} /* VSmerge_shell_expansion */
/*----------------------------------------------------------------------------*/

end implementation VSshellExp ;
