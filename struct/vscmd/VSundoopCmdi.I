/* $Id: VSundoopCmdi.I,v 1.1.1.1 2001/01/04 21:10:28 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSundoopCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSundoopCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:28  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/03/15  18:35:26  pinnacle
# Replaced: vscmd/VSundoopCmdi.I for:  by impd252 for struct
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1998/01/02  11:28:56  pinnacle
# Replaced: vscmd/VSundoopCmdi.I for:  by svkadamb for struct
#
# Revision 1.4  1997/10/29  04:54:42  pinnacle
# Replaced: vscmd/VSundoopCmdi.I for:  by smpathak for struct
#
# Revision 1.2  1997/10/06  06:59:02  pinnacle
# Replaced: vscmd/VSundoopCmdi.I for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 *	10/28/97        S.M.Pathak      modification
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSundoopCmd ;

#include <stdio.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "igewindef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "COBmacros.h"
#include "vsdatamacros.h"
#include "vsrvformdef.h"
#include "vs.h"
#include "vsattr.h"

#include "vsdbgmacros.h"
#include "nddef.h"

/*
 * Includes of function prototypes.
 */
#include "vsophstproto.h"
#include "vsvirtualinf.h"

from GRgraphics		import	GRdisplay ;
from NDmacro		import	ACreturn_foot ;
from VSfeature		import	VSgetOperationMgr,
				VSgetOperationHistory ;
from VSmodFeature	import	VSundoOperation ;
from NDnode             import  NDget_objects;

/*----------------------------------------------------------------------------*/
method hiliteOperators( long *msg  ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	result ;	/* Result to undo	*/
	VSopHistory		*history,
				*h ;
	int			i ;
	struct GRid		oid ;
	struct IGRaltdisplay	dsp ;
	unsigned short		color	= 0 ;
	unsigned char		weight	= 2 ;
	unsigned char		style	= 5 ;

	SetProc( hiliteOperators ); Begin

	dsp.rgb_value	= NULL ;
	dsp.color	= &color ;
	dsp.weight	= &weight;
	dsp.style	= &style ;

	history = NULL ;

	if( !me->oprndCount ) goto wrapup ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
						      msg, 1, &result ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup );

	sts = om$send(	msg	= message VSfeature.VSgetOperationHistory(
						msg, &result.mod_env, &history),
			targetid= result._objid,
			targetos= result._osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetOperationHistory", wrapup ) ;

	for( h = history ; h ; h = h->next ) {
		if( !( h->resultType & VS_m_MOD_generic ) ) continue ;

		__DBGpr_int(" opCount ", h->opCount );

		for( i = 0 ; i < h->opCount ; i++ ) {

			enum GRdpmode dpMode = GRhdo ;

			oid.objid = h->opList[i].id ;
			oid.osnum = h->opList[i].os ;

			VSgetVirtualInfo( msg,
					  &oid,
					  NULL,
					  &oid ) ;

			__DBGpr_obj(" Display ", oid );

			om$send(msg	= message GRgraphics.GRdisplay(
						msg,
						&h->opList[i].env._MATRIX_TYPE,
						h->opList[i].env._MATRIX,
						&dpMode,
						&me->ModuleInfo.md_id ),
				targetid = oid.objid,
				targetos = oid.osnum ) ;
		}
	}

	wrapup :
		VSfreeOpHistory( history ) ;
		*msg = VS_K_ACT_SUCCESS ;
		End
		return OM_S_SUCCESS ;

} /* method hiliteOperators */
/*----------------------------------------------------------------------------*/
method hiliteResult( long *msg ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	result ;	/* Result to undo	*/

	if( me->oprndCount ) {
		sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							msg, 1, &result ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup );

		vs$bulk_display( objenvs = &result,  dpmode  = GRhhd ) ;
	}

	wrapup :
		*msg = VS_K_ACT_SUCCESS ;
		return OM_S_SUCCESS ;

} /* method hiliteResult */
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

	long			sts ;		/* OM return code.	*/
	int			i ;		/* Loop index.		*/
	struct GRobj_env	*locObj = NULL, /* Located objects	*/
				visibleResult ; /* ... after undo.	*/
	struct GRid		opMgr,		/* Operation manager.	*/
				src ;		/* Source of operator.	*/

	SetProc( Operation ); Begin

	__DBGpr_int(" oprtrCount ", me->oprtrCount );
	__DBGpr_int(" oprndCount ", me->oprndCount );

	if( !( locObj = _MALLOC( me->oprndCount + me->oprtrCount,
				 struct GRobj_env ) ) ) vs$mem_fail() ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
						msg,
						me->oprndCount + me->oprtrCount,
						locObj ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	/*
	 * Unhighlight located objects.
	 */
	dp$erase_hilite( msg = msg ) ;

	/*
	 * Erase result before undo takes place.
	 */
	visibleResult = locObj[0] ;
	vs$bulk_display( objenvs = &visibleResult,
			 dpmode  = GRbe ) ;

	/*
	 * Remove operators.
	 */
	for( i=1; i<=me->oprtrCount; i++ ) {

		sts = om$send(	msg	= message VSfeature.VSgetOperationMgr(
								msg, &opMgr ),
				targetid= visibleResult._objid,
				targetos= visibleResult._osnum ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetOperationMgr", wrapup ) ;

		/*
		 * CAUTION !
		 * If the operator to remove is the output of an ACheader, the
		 * object returned by "locate" will not be that object but
		 * a copy of it owned by the ACheader. To retrieve the right
		 * object, we need to perform a make-source on it, which will
		 * return a pretend, we then query this pretend, which is
		 * intelligent enough to return the ACheader's output and not
		 * the copy returned by locate.
		 * If the operator is not the output of an ACheader, the follo-
		 * wing process will work all the same.
		 */
		as$make_source( go_grid = locObj[i]._grid,
				mod_env = &locObj[i].mod_env,
				as_os	= me->ModuleInfo._MD_OS,
				as_grid = &src ) ;
		om$send(msg	= message NDmacro.ACreturn_foot(
						msg,
						"",
						&locObj[i]._grid,
						&locObj[i]._matrix_type,
						locObj[i]._matrix ),
			targetid= src.objid,
			targetos= src.osnum ) ;
		locObj[i].mod_env.md_id = me->ModuleInfo.md_id ;

		__DBGpr_obj(" Undo ", locObj[i]._grid );

		sts = om$send(	msg	= message VSmodFeature.VSundoOperation(
							msg,
							&visibleResult.mod_env,
							&locObj[i].mod_env,
							&locObj[i]._grid,
							&visibleResult ),
				targetid= opMgr.objid,
				targetos= opMgr.osnum ) ;
		if( *msg != MSINARG )
			__CheckRC( sts, *msg, "VSmodFeature.VSundoOperation",
				   wrapup ) ;
	}

	/*
	 * Display possibly new visible result.
	 */
	__DBGpr_obj(" VisResult ", visibleResult.obj_id );
	vs$bulk_display( objenvs = &visibleResult,
			 dpmode  = GRbd ) ;

	/*
	 * Redisplay old operator.
	 */
	vs$bulk_display( count	 = me->oprtrCount,
			 objenvs = locObj + 1,
			 dpmode  = GRbd ) ;

	wrapup :

	if( !( sts & 1 & *msg ) ) {
		om$send(msg	= message VSpartopCmd.setErrorStatus( *msg, 2 ),
			targetid= my_id ) ;
		me->ret = VS_K_ABORT_CMD ;
	} else	me->ret = VS_K_ACT_SUCCESS ;

	_FREE( locObj ) ;
	End
	return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/
method locate_action_handler(	int			*keepIt ;
				enum GRlocate_action	*action ;
				struct GRlc_info	*entry ;
				struct LC_action_args	*args ) {

	/*
	 * Keep only objects which are operators of the previously located
	 * result.
	 */
	long			sts,
				msg ;
	struct GRobj_env	resultOfOp ;
	struct GRid		opMgr ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							&msg, 1, &resultOfOp ),
			targetid= my_id ) ;

	sts = om$send(	msg	= message VSfeature.VSgetOperationMgr(
								&msg, &opMgr ),
			targetid= resultOfOp._objid,
			targetos= resultOfOp._osnum ) ;

	/*
	 * `VSundoOperation' called with the last argument set to NULL will
	 * not actually undo: it will only check that the input operator
	 * (pointed to by `entry' ) is indeed an operator of the previously
	 * located result. Message will fail if not.
	 */
	sts = om$send(	msg	= message VSmodFeature.VSundoOperation(
							&msg,
							&resultOfOp.mod_env,
							&entry->module_info,
							&entry->located_obj,
							NULL ),
			targetid= opMgr.objid,
			targetos= opMgr.osnum ) ;

	*keepIt = sts & 1 & msg ? TRUE : FALSE ;

	return OM_S_SUCCESS ;

} /* method locate_action_handler */
/*----------------------------------------------------------------------------*/
method getAllOperators( long *msg ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	result ;	/* Result to undo	*/
	VSopHistory		*history,
				*h ;
	int			i ;
	struct GRid		oid ;

	SetProc( getAllOperators ); Begin

	history = NULL ;
	if( !me->oprndCount ) goto wrapup ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
						      msg, 1, &result ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup );

	sts = om$send(	msg	= message VSfeature.VSgetOperationHistory(
						msg, &result.mod_env, &history),
			targetid= result._objid,
			targetos= result._osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetOperationHistory", wrapup ) ;

	for( h = history ; h ; h = h->next ) {
		if( !( h->resultType & VS_m_MOD_generic ) ) continue ;

		for( i = 0 ; i < h->opCount ; i++ ) {

			oid.objid = h->opList[i].id ;
			oid.osnum = h->opList[i].os ;

			__DBGpr_obj(" Operand ", oid );

			if( me->oprtrCount > me->maxOprtr ) {
				sts = VS_K_TOO_MANY_OPS ; goto wrapup ;
			}
			sts = om$send(	msg	= message VSlocateCmd.addLocObj(
								&oid,
								NULL,
								me->oprndCount + me->oprtrCount ),
					targetid= my_id ) ;
			if( sts & VS_K_OBJONCHEXIST )	sts = OM_S_SUCCESS ;
			else 				me->oprtrCount++ ;

		}
	}

	__DBGpr_int(" oprtrCount ", me->oprtrCount );
	wrapup :
		VSfreeOpHistory( history ) ;
		*msg = VS_K_ACT_SUCCESS ;
		End
		return OM_S_SUCCESS ;

} /* method getAllOperators */
/*----------------------------------------------------------------------------*/

method store_operand ( long *msg ; int putQ ) {

        long             sts ;

        int              nbRoot,
                         nbChild; 

	SetProc( store_operand ); Begin

        me->oprndCount = 0 ;


	/*
	 * Test the validity of the result object before storing the result
	 * part. Get the parents and the children of the result and if they are
	 * not existing then the result part is not valid object.
	 */
        nbRoot  = 0 ;
        nbChild = 0 ;
        sts = om$send( msg      = message NDnode.NDget_objects( ND_ROOT,
                                                                NULL,
                                                                0,
                                                                NULL,
                                                                0,
                                                                OM_K_MAXINT,
                                                                &nbRoot ),
                    targetid= me->event1.located_object[0].located_obj.objid,
                    targetos= me->event1.located_object[0].located_obj.osnum ) ;
        if( !( sts & 1 ) )
        {
		__DBGpr_com(" VS_K_RESTART_CMD 1 ");
        	me->ret = VS_K_RESTART_CMD ;
		return OM_S_SUCCESS;
        }
        sts = om$send( msg      = message NDnode.NDget_objects( ND_CHILDREN,
                                                                NULL,
                                                                0,
                                                                NULL,
                                                                0,
                                                                OM_K_MAXINT,
                                                                &nbChild ),
                    targetid= me->event1.located_object[0].located_obj.objid,
                    targetos= me->event1.located_object[0].located_obj.osnum ) ;

        if( !( sts & 1 ) )
        {
		__DBGpr_com(" VS_K_RESTART_CMD 2 ");
        	me->ret = VS_K_RESTART_CMD ;
        	return OM_S_SUCCESS;
        }

        if( nbRoot == 0 && nbChild == 0 )
        {
		__DBGpr_com(" VS_K_RESTART_CMD 3 ");
         	me->ret = VS_K_RESTART_CMD ;
         	return OM_S_SUCCESS;
        }

	/*
	 * Now that the result object is confirmed is a valid object. Hence
	 * add in the instance od locate class
	 */
	__DBGpr_obj(" AddLoc ", me->event1.located_object[0].located_obj );
        sts = om$send(  msg     = message VSlocateCmd.addLocObj(
                                &me->event1.located_object[0].located_obj,
                                &me->event1.located_object[0].module_info,
                                me->oprndCount ),
                        targetid= my_id ) ;

        me->oprndCount++ ;

        if( putQ && ( sts & 1 ) && *me->response != EX_OBJID ) {
                long size = sizeof( struct GRevent ) ;

                me->event1.num_id = 0 ;
                ex$putque(      msg             = msg,
                                response        = me->response,
                                byte            = &size,
                                buffer          = (char *) &me->event1.event ) ;
        }

        me->ret = sts & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	End 
        return OM_S_SUCCESS ;

} /* method store_operand */
/*----------------------------------------------------------------------------*/


end implementation VSundoopCmd ;
