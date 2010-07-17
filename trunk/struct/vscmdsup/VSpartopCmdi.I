/* $Id: VSpartopCmdi.I,v 1.1.1.1 2001/01/04 21:10:30 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmdsup/VSpartopCmdi.I
 *
 * Description: Includes methods to store input on a generator queue and 
 *		construct an object using input.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSpartopCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:30  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/08/14  18:52:06  pinnacle
# Added dbg macros
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      08/14/98  EJM     TR#179801428  This file used to debug TR. Didn't
 *                        need changing to fix bug, but, added dbg macro code.
 ***************************************************************************/

class implementation VSpartopCmd ;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "EMSmsgdef.h"
#include "vs.h"
#include "vsglobalmsg.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsmiscmacros.h"
/* #define  vsDEBUG */
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetmsgkey.h"
#include "vsgrenvproto.h"
#include "vsioproto.h"

from GRgraphics	import	GRconstruct ;
from GRvg	import	GRgeomprops ;
from ACncpx	import	ACget_NV_rep ;

extern void	VSfixBeamRep() ;

/*----------------------------------------------------------------------------*/
method setFlags( int flags ) {

	SetProc( setFlags ); Begin

	__DBGpr_int("flags", flags);
	me->partOpFlags = flags ;

	End
	return OM_S_SUCCESS ;

} /* method setFlags */
/*----------------------------------------------------------------------------*/
method setMinMaxOperators( int min, max ) {

	me->minOprtr = min ;
	me->maxOprtr = max ;

	return OM_S_SUCCESS ;

} /* method setMinMaxOperators */
/*----------------------------------------------------------------------------*/
method store_operand ( long *msg ; int putQ ) {

	long	sts ;

	SetProc( store_operand ); Begin

	me->oprndCount = 0 ;


	sts = om$send(	msg	= message VSlocateCmd.addLocObj(
				&me->event1.located_object[0].located_obj,
				&me->event1.located_object[0].module_info,
				me->oprndCount ),
			targetid= my_id ) ;

	me->oprndCount++ ;

	if( putQ && ( sts & 1 ) && *me->response != EX_OBJID ) {
		long size = sizeof( struct GRevent ) ;

		__DBGpr_com("Calling putque");

		me->event1.num_id = 0 ;
		ex$putque(	msg	 	= msg,
				response	= me->response,
				byte		= &size,
				buffer		= (char *) &me->event1.event ) ;
	}

	me->ret = sts & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	End

	return OM_S_SUCCESS ;

} /* method store_operand */
/*----------------------------------------------------------------------------*/
method store_operator( long *msg ; int putQ  ) {

	long			sts ;
	struct GRlc_info	*toStore	= me->event1.located_object ;
	int			maxOp		= me->maxOprtr ;


	SetProc( store_operator ); Begin

	if( me->oprtrCount > maxOp ) {
		sts = VS_K_TOO_MANY_OPS ; goto wrapup ;
	}
	sts = om$send(	msg	= message VSlocateCmd.addLocObj(
					&toStore->located_obj,
					&toStore->module_info,
					me->oprndCount + me->oprtrCount ),
			targetid= my_id ) ;
	if( sts & VS_K_OBJONCHEXIST )	sts = OM_S_SUCCESS ;
	else 				me->oprtrCount++ ;

	if( sts & 1 ) {
		if( putQ && *me->response != EX_OBJID ) {
			long size = sizeof( struct GRevent ) ;

			__DBGpr_com("Calling putque");

			me->event1.num_id = 0 ;
			ex$putque(
				msg	 	= &sts,
				response	= me->response,
				byte		= &size,
				buffer		= (char *) &me->event1.event ) ;
		}
	}

	sts = sts & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;


	wrapup :
		me->ret = sts ;
	End
		return OM_S_SUCCESS ;

} /* method store_operator */
/*----------------------------------------------------------------------------*/
method decrease_operator()
{
	if (  me->oprtrCount ) 
	{
		me->oprtrCount-- ;
	}
	return OM_S_SUCCESS;

} /* method decrease_operator */
/*----------------------------------------------------------------------------*/
method process_fence( long *msg ; int type ) {

	long			sts ;
	int			nbElems	= 0,
				store	= FALSE,
				maxOp	= me->maxOprtr ;
	struct GRobj_env	fence,
				*Elems	= NULL ;
				
	SetProc( process_fence ); Begin

	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	vs$process_fence(	msg		= &sts,
				fence		= &fence,
				p_count		= &nbElems,
				p_content	= &Elems,
				filter		= me->PFAH,
				args		= &me->PFAHarg,
				classList	= me->locate_eligible,
				response	= me->response,
				response_data	= me->response_data ) ;

	__DBGpr_int("nbElems", nbElems);

	if( sts == EMS_I_Fail ) {
		/*
		 * `fence' was not a fence, let other method handle it.
		 * Do not put accept point onto queue or command will loop
		 * forever.
		 */
		__DBGpr_com("fence was not a fence, sts = EMS_I_Fail");

		if( type == VS_K_OPRND ) {
			sts = om$send(
				msg	= message VSpartopCmd.store_operand(
								msg, FALSE ),
				targetid= my_id ) ;
		} else {
			sts = om$send(
				msg	= message VSpartopCmd.store_operator(
								msg, FALSE ),
				targetid= my_id ) ;
		}
	} else if( sts & 1 ) {
		int		h,
				*which,
				index ;

		which = type == VS_K_OPRND ? &me->oprndCount : &me->oprtrCount ;

		for( h = 0 ; h < nbElems && (sts & 1) ; h++ ) {

			index = type == VS_K_OPRND
				? me->oprndCount
				: me->oprndCount + me->oprtrCount ;
				
			sts = om$send(
				msg	= message VSlocateCmd.addLocObj(
							&Elems[h]._grid,
							&Elems[h].mod_env,
							index ),
				targetid= my_id ) ;
			
			(*which)++ ;

			store = TRUE ;

			if( type == VS_K_OPRTR && me->oprtrCount > maxOp ) {
				sts = VS_K_TOO_MANY_OPS ;
				_FREE( Elems ) ;
				goto wrapup ;
			}
		}
		_FREE( Elems ) ;

		if( !store ) {
			__DBGpr_com("sts = VS_K_NO_FENCE");
			sts = VS_K_NO_FENCE ;
			goto wrapup ;
		} else {

			ex$message(	msgnumb		= VS_gI_NEltsFound,
					type		= "%d",
					var		= `h`,
					justification	= CENTER_JUS ) ;
			VS_Wait_timer( 50 ) ;
		}
	}

	sts = sts & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	wrapup :
		me->ret = sts ;
	End
		return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method discard_operators( long *msg ) {

	/*
	 * operands	: 0 through me->oprndCount - 1
	 * operators	: me->oprndCount through me->oprtrCount - 1
	 */

	me->ret =
	om$send(msg	= message VSlocateCmd.rmLastLocObjs( me->oprndCount ),
		targetid= my_id ) ;

	me->oprtrCount = 0 ;

	return OM_S_SUCCESS ;

} /* method discard_operators */
/*----------------------------------------------------------------------------*/
method discard_all_input( long *msg ) {

	me->ret = om$send( msg	   = message VSlocateCmd.rmLastLocObjs( 0 ),
		           targetid= my_id ) ;

	me->oprtrCount = me->oprndCount = 0 ;

	return OM_S_SUCCESS ;

} /* discard_all_input */
/*----------------------------------------------------------------------------*/
method construct( long *msg ; struct GRvg_construct *cst ) {

	long			sts ;
	struct VScnst_list	*attr = (struct VScnst_list *) cst->class_attr ;

	SetProc( construct ); Begin
	/*
	 * Unhilite parents.
	 */
	vs$bulk_display(count	= attr->parent_count,
			objenvs	= attr->parent_list,
			dpmode	= GRhe ) ;

	/*
	 * Construct object.
	 */
	me->constructedObject.osnum = me->cstEnv._MD_OS ;

	__DBGpr_str("me->const_class", me->const_class);

	sts = om$construct(
			classname= me->const_class,
			osnum	 = me->cstEnv._MD_OS,
			p_objid	 = &me->constructedObject.objid,
			msg	 = message GRgraphics.GRconstruct( cst ) ) ;

	if( sts & 1 & *msg ) {
		__DBGpr_int("Constructed successfully, objid = ", me->constructedObject.objid);
		vs$bulk_display(count	= 1,
				grids	= &me->constructedObject,
				theEnv	= &me->cstEnv,
				dpmode	= GRbd ) ;
	} else {
		__DBGpr_com("Unsuccessful construction");
		om$send(msg	= message VSpartopCmd.setErrorStatus(
								*msg, 2 ),
			targetid= my_id ) ;
		/*
		 * Redisplay operand which has probably been erased
		 * during the course of the operation. Operand is
		 * parent #0.
		 */
		if( !( me->partOpFlags & VS_m_POnoOperandRedisp ) ) {
			vs$bulk_display(objenvs	= attr->parent_list + 0,
					dpmode	= GRbd ) ;
		}
	}
	End
	return sts ;

} /* method construct */
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

	long			sts ;
	struct GRobj_env	*parents ;
	int			minOp = me->minOprtr,
				total,  i ;
	struct GRvg_construct	cst ;
	struct VScnst_list	attr ;


	SetProc( operation ); Begin

	parents = NULL ;
	i = 0; /* prevent compiler warning; only used in DEBUG */

	if( me->oprtrCount < minOp ) { sts = VS_K_NEED_OP ; goto wrapup ; }

	total = me->partOpFlags & VS_m_POallOprtsOn1Opnd
				? me->oprtrCount + me->oprndCount
				: me->oprtrCount + 1 ;

	__DBGpr_int("me->oprndCount", me->oprndCount);
	__DBGpr_int("me->oprtrCount", me->oprtrCount);
	__DBGpr_int("total calculated", total);

	if( !( parents = _MALLOC( total, struct GRobj_env ) ) ) {
		sts = VS_K_ABORT_CMD ; goto wrapup ;
	}
	/*
	 * Get parents.
	 */
	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							msg, total, parents ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "VSlocateCmd.getLocObjs", wrapup ) ;

#ifdef vsDEBUG
	__DBGpr_com("List of parents using 'total' variable");
	for(i=0; i<me->oprtrCount + me->oprndCount; i++)
	   printf("\t  parents[%d].obj_id.objid = %d\n", i, parents[i].obj_id.objid);
#endif

	__DBGpr_int("me->partOpFlags", me->partOpFlags);

	if( me->partOpFlags & VS_m_POconstWithSymb ) {
		__DBGpr_com("Calling vs$cnstDefaults");

		vs$cnstDefaults(	msg	= msg,
					symb_id	= me->ModuleInfo.md_id,
					symb	= &me->ActiveRep,
					level	= &me->ActiveLevel,
					display	= &me->ActiveDisplay ) ;

		vs$fill_cnst_list(	Cnst_list	= cst,
					Msg		= msg,
					Env_info	= &me->cstEnv,
					Display		= &me->ActiveDisplay,
					Level		= me->ActiveLevel,
					Class_attr	= &attr ) ;
	} else {			
	       /*
	 	* Fill construction list, do not specify the display
	 	* parameters since object will take its parent part's.
	 	*/
		vs$fill_cnst_list(	Cnst_list	= cst,
					Msg		= msg,
					Env_info	= &me->cstEnv,
					Display		= NULL,
					Level		= 0,
					Class_attr	= &attr ) ;
	}

	if( me->partOpFlags & VS_m_POconstWithRep ) {
		VSfixBeamRep(	me->ActiveRep.representation,
				&attr.representation ) ;
	} else {
		__DBGpr_com("attr.representation = AC_NO_REP");
		attr.representation = AC_NO_REP ;
	}

	/*
	 * Note : when OM constructs this command object, all instance
	 * data are zeroed out, hence if `me->classAttr' has not been
	 * set by a sub-class, it is NULL.
	 */
	attr.feature_att	= me->classAttr ;

	if( me->partOpFlags & VS_m_POallOprtsOn1Opnd ) {
		/*
		 * All operators operate on one operand.
		 */

		int			i,
					ioperand = me->oprndCount - 1 ;
		struct GRobj_env	save ;

		__DBGpr_com("Construct with VS_m_POallOprtsOn1Opnd");

		attr.parent_count	= 1 + me->oprtrCount ;
		attr.parent_list	= parents + ioperand ;

		for( i = 0 ; i < me->oprndCount ; i++ ) {
			save		  = parents[ioperand] ;
			parents[ioperand] = parents[i] ;
			ex$message(	
				msgnumb		= VS_gI_ProcessingSomething,
				type		= "%d",
				var		= `i+1`,
				field		= KEYIN_FIELD,
				justification	= CENTER_JUS ) ;
			sts = om$send(	msg	= message VSpartopCmd.construct(
						 		msg, &cst ),
					targetid= my_id ) ;
			parents[ioperand] = save ;
		}
		ex$message( in_buff = "", field = KEYIN_FIELD ) ;
		sts = VS_K_ACT_SUCCESS ;
	} else {
		__DBGpr_com("Construct  without  VS_m_POallOprtsOn1Opnd");

		attr.parent_count	= me->oprtrCount + me->oprndCount ;
		attr.parent_list	= parents ;
		sts = om$send(	msg	= message VSpartopCmd.construct(
						 		msg, &cst ),
				targetid= my_id ) ;
		sts = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
	}

	wrapup :
		_FREE( parents ) ;
		me->ret = sts ;
	End
		return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/
method handleError( int error ) {

	long	msg,
		msgkey ;
	int	selector	= 0 ;
	int	doAction	= TRUE ;

	switch( error ) {
		case VS_K_TOO_MANY_OPS	:
			msgkey		= VS_gW_TooManyOps ;
			selector	= _previous_state ;
			om$send(msg	= message VSpartopCmd.discard_operators(
									&msg ),
				targetid= my_id ) ;
			break ;
		case VS_K_RESTART_CMD	:
			me->state = me->next_state = 0 ;
			msgkey		= VS_gE_ErrEncCmdRst ;
			selector	= _go_next_state ;
			om$send(msg	= message VSpartopCmd.discard_all_input(
									&msg ),
				targetid= my_id ) ;
			break ;
		case VS_K_ABORT_CMD	:
			msgkey		= VS_gE_ErrEncCmdTrm ;
			selector	= _terminate ;
			break ;
		case VS_K_NO_FENCE	:
			msgkey		= VS_gW_NoObjLoc ;
			doAction	= FALSE ;
			break ;
		default			:
			msgkey		= MS_NO_MSG ;
			doAction	= FALSE ;
			break ;
	}
	if( msgkey != MS_NO_MSG ) {
		ex$message(	msgnumb		= msgkey,
				justification	= CENTER_JUS ) ;
		if( doAction ) {
			om$send(msg	= message CEO.action(
							selector,
							NULL,
							(int *) &me->ret ),
				targetid= my_id ) ;
		}
	}

	me->ret = VS_K_ACT_SUCCESS ;

	return OM_S_SUCCESS ;

} /* method handleError */
/*----------------------------------------------------------------------------*/
method setErrorStatus( long msg ; int wait ) {

	if( !( msg & 1 ) ) {
		msg = VSgetMsgKey( msg ) ;
		ex$message(	msgnumb		= msg,
				field		= ERROR_FIELD,
				justification	= CENTER_JUS ) ;
		if( wait ) sleep( wait ) ;
	}
	return OM_S_SUCCESS ;

} /* method setErrorStatus */
/*----------------------------------------------------------------------------*/
method displaySurfaceNormal( enum GRdpmode mode ) {

	long			msg ;
	struct GRobj_env	sf ;
	int			index = me->oprtrCount + me->oprndCount - 1 ;
	extern OMuword		OPP_EMSsubbs_class_id ;

	om$send(msg	= message VSlocateCmd.getLocObjAtIndex(
							&msg, index, &sf ),
		targetid= my_id ) ;

	if( ( msg & 1 )
	    && vs$is_ancestry_valid(	object	= &sf._grid,
	    				classid	= OPP_EMSsubbs_class_id ) ) {
		VSdisplaySurfaceNormal(	&msg,
					&sf,
					FALSE,
					&me->ActiveDisplay,
					mode ) ;
	}

	return OM_S_SUCCESS ;

} /* method displaySurfaceNormal */
/*----------------------------------------------------------------------------*/

end implementation VSpartopCmd;
