/*
	I/STRUCT
*/
class implementation VSmodFeature ;

#include "nddef.h"
#include "ndmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
#include "vsvirtualinf.h"

extern	OMuword		OPP_VSmodJoint_class_id ;

/*----------------------------------------------------------------------------*/
method VSremoveOperator( long		*msg ;
			struct GRmd_env *myEnv ;
			struct GRid	*operator ;
			int		*deleted ) {

	long		sts ;		/* OM return code	*/
	int		nbRoots,	/* Count of my roots	*/
			nbKids,		/* Count of my children	*/
			action ;	/* Values follow ...	*/
#define	_disappear	1
#define _fillHoles	2
	struct GRid	MyGRid,		/* Avoids OM expansion	*/
			Operator,	/* Operator parent	*/
			Operand,	/* Operand parent	*/
			*myKids ;	/* List of my children	*/
	OM_S_CHANSELECT	*toMyRoots,	/* Chan. me -> my roots	*/
			*toMyKids ;	/* Chan. me -> my kids	*/
	struct GRobj_env
			virtual ;	/* My virtual parent	*/

	int		i;
	struct GRid	rootJoint;
 
 
	MyGRid.objid = my_id ; MyGRid.osnum = OM_Gw_current_OS ;
	Operator = *operator ;

	*deleted = FALSE ;
	*msg	 = MSFAIL ;
	sts	 = OM_E_ABORT ;

	/*
	 * We are going to perform operations on our children: get channels.
	 */
	NDget_channel( &toMyRoots, &toMyKids ) ;

	sts = om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								NULL,
								0,
								NULL,
								0,
								OM_K_MAXINT,
								&nbRoots ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	action = nbRoots > 2 ? _fillHoles : _disappear ;

	switch( action ) {

	case _fillHoles	:
	  /*
	   * Lost one boundary, but others remain: recompute yourself to
	   * fill the holes.
	   */

	  sts = om$send( msg	 = message NDnode.NDdisconnect( 1, &Operator ),
			 targetid= my_id ) ;
	  __CheckRC( sts, 1, "NDnode.NDdisconnect", wrapup ) ;

	  {

	    struct GRid moi ;
	    int 	cn_type = ND_COMP ;
	    moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;

	    nd$wait_batch(	type		= GR_GEOM_POSTED,
				l_object	= &moi,
				l_obj_info	= &cn_type,
				nb_obj		= 1 );
	  }
	  break ;

	case _disappear	:
		/*
		 * Disconnect children and re-connect them to parent feature.
		 * Then go away. First collect future ex-children to tell them
		 * to recompute after reconnection.
		 */

		sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_CHILDREN | ND_IN_BUF,
							NULL,
							0,
							&myKids,
							0,
							OM_K_MAXINT,
							&nbKids ),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;


		/*
		 * Retrieve id of operand parent feature.
		 */

		sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_ROOT,
							&Operand,
							1,
							NULL,
							VS_K_ConsumedIx,
							VS_K_ConsumedIx,
							&nbRoots ),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

		/*
		 * Retrieve virtual parent, if any and get parent's module
		 * environment (my REAL parent may be a pretend).
		 */

		sts = VSgetVirtualInfo( msg, &Operand,
					  &virtual.mod_env, &virtual._grid ) ;
		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		/*
		 * Transfer your representation to your parent. This will
		 * force parent to recompute.
		 */

		sts = om$send(	msg	= message VSmodFeature.VStransferRep(
						msg, &Operand, &virtual ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSmodFeature.VStransferRep", wrapup ) ;

		if( nbKids ) {
			/*
			 * Connection stuff is done on REAL parent.
			 */
			sts = om$send(	msg	= message NDnode.NDchange_connect(
								1,
						/* Old root */	&MyGRid,
						/* New root */	&Operand ),
					p_chanselect = toMyKids ) ;
			__CheckRC( sts, 1, "NDnode.NDchange_connect", wrapup ) ;

			/*
			 * Now I disconnect from my parents. This could be done
			 * in NDdelete but my NDdelete tests parent count, which
			 * if non-zero, results in a different action.
			 */
			sts = om$send(
				msg	= message NDnode.NDdisconnect( 0, NULL),
				targetid= my_id ) ;
			__CheckRC( sts, 1, "NDnode.NDdisconnect", wrapup ) ;

			for( i = 0; i< nbKids ; i++ ) {

			if( vs$is_ancestry_valid ( 
					object =  &myKids[i],
					classid = OPP_VSmodJoint_class_id ) ) {
				sts = om$send(	
					msg = message NDnode.NDget_objects(
							ND_ROOT,
							&rootJoint,
							1,
							NULL,
							VS_K_ConsumedIx,
							VS_K_ConsumedIx,
							&nbRoots ),
					targetid =myKids[i].objid,
					targetos = myKids[i].osnum );
				__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

			 	sts = om$send(
						msg	= message 
						NDmacro.ACtest_consumed( msg),
					targetid = myKids[i].objid,
					targetos = myKids[i].osnum ) ;
				__CheckRC( sts, 1, "NDmacro.ACtest_consume", wrapup ) ;

				if( ! *msg ) {
					/*
					 * If REAL parent is a pretend, it will
					 * understand ACunconsume.
					 */

					sts = vs$unconsume(
							msg	= msg,
							object	= &rootJoint,
							mod_env	= &virtual.mod_env,
							compute	= TRUE ) ;
					__CheckRC( sts, *msg, "vs$unconsume", wrapup ) ;
				} else {
					int cn_type = ND_COMP ;
					/*
					 * Parent will recompute in good consumed state
					 * for consuming child to exploit it.
					 */

					sts = nd$wait_batch(
						type		= GR_GEOM_POSTED,
						l_obj_info	= &cn_type,
						l_object	= &rootJoint,
						nb_obj		= 1 ) ;
					__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;
				}

				sts = nd$wait_batch(
					type		= GR_DELETED,
					l_object	= &myKids[i],
					nb_obj		= 1 ) ;
				__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;
				}
			}
			/*
			 * If I was consumed (by one of my children), my parent
			 * shall now stay consumed for that child. If not, I
			 * must unconsume my parent.
			 */

			 sts = om$send(
				msg	= message NDmacro.ACtest_consumed( msg),
				targetid= my_id ) ;
			__CheckRC( sts, 1, "NDmacro.ACtest_consume", wrapup ) ;

			if( ! *msg ) {
				/*
				 * If REAL parent is a pretend, it will
				 * understand ACunconsume.
				 */

				sts = vs$unconsume(
						msg	= msg,
						object	= &Operand,
						mod_env	= &virtual.mod_env,
						compute	= TRUE ) ;
				__CheckRC( sts, *msg, "vs$unconsume", wrapup ) ;
			} else {
				int cn_type = ND_COMP ;
				/*
				 * Parent will recompute in good consumed state
				 * for consuming child to exploit it.
				 */

				sts = nd$wait_batch(
					type		= GR_GEOM_POSTED,
					l_obj_info	= &cn_type,
					l_object	= &Operand,
					nb_obj		= 1 ) ;
				__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;
			}

		} else {
			/*--------------------------------------------------*\
			 | No children: I am the last feature of the chain. |
			 | Disconnect from parents anyway, since upcoming   |
			 | NDdelete will test parent count to take an       |
			 | appropriate action.                              |
			\*--------------------------------------------------*/
			/*
			 * Unconsume parent (parent feature (input) is #0).
			 * Do not force to compute since
			 *		VSmodFeature.VStransferRep
			 * already provoked a recompute of parent.
			 */

			sts = vs$unconsume(	msg	= msg,
						object	= &Operand,
						mod_env	= &virtual.mod_env,
						compute	= FALSE ) ;
			__CheckRC( sts, *msg, "vs$unconsume", wrapup ) ;

			sts = om$send(
				msg	= message NDnode.NDdisconnect( 0, NULL),
				targetid= my_id ) ;
			__CheckRC( sts, 1, "NDnode.NDdisconnect", wrapup ) ;

		}

		vs$bulk_display( objids = &my_id, theEnv = myEnv, dpmode = GRbe ) ;

		if( action == _disappear && !nbKids ) {
			/*
			 * Redisplay parent.
			 */

			vs$bulk_display( objenvs = &virtual, dpmode = GRbd ) ;
		}
		sts = nd$wait_batch(	type		= GR_DELETED,
					l_object	= &MyGRid,
					nb_obj 		= 1 ) ;
		__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;

		*deleted = TRUE ;

		break ;

	} /* switch */

	*msg	 = MSSUCC ;
	sts	 = OM_S_SUCCESS ;

	wrapup :

		return sts ;

} /* method VSremoveOperator */
/*----------------------------------------------------------------------------*/
IGRint VSornBmRmOp(struct GRid *beamId)
{
	long		sts,msg ;	/* OM return code	*/
	int		nbRoots,	/* Count of my roots	*/
			nbKids,		/* Count of my children	*/
			action ;	/* Values follow ...	*/
	struct GRid	MyGRid,		/* Avoids OM expansion	*/
			Operand;	/* Operand parent	*/
	struct GRobj_env
			virtual ;	/* My virtual parent	*/

	int		i,retFlag = 0,cn_type;
	struct GRid	rootJoint;
 
 
	MyGRid.objid = beamId->objid ; MyGRid.osnum = beamId->osnum ;

		/*
		 * Retrieve id of operand parent feature.
		 */

		sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_ROOT,
							&Operand,
							1,
							NULL,
							VS_K_ConsumedIx,
							VS_K_ConsumedIx,
							&nbRoots ),
				senderid = NULL_OBJID,
				targetid = beamId->objid,
				targetos = beamId->osnum) ;
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

		/*
		 * Retrieve virtual parent, if any and get parent's module
		 * environment (my REAL parent may be a pretend).
		 */

		sts = VSgetVirtualInfo( &msg, &Operand,
					  &virtual.mod_env, &virtual._grid ) ;
		__CheckRC( sts, msg, "VSgetVirtualInfo", wrapup ) ;

		/*
		 * Transfer your representation to your parent. This will
		 * force parent to recompute.
		 */

		sts = om$send(	msg	= message VSmodFeature.VStransferRep(
						&msg, &Operand, &virtual ),
				senderid = NULL_OBJID,
				targetid = beamId->objid,
				targetos = beamId->osnum ) ;
		__CheckRC( sts, msg, "VSmodFeature.VStransferRep", wrapup ) ;
			/*
			 * Now I disconnect from my parents. This could be done
			 * in NDdelete but my NDdelete tests parent count, which
			 * if non-zero, results in a different action.
			 */
			sts = om$send(
				msg	= message NDnode.NDdisconnect( 0, NULL),
				senderid = NULL_OBJID,
				targetid = beamId->objid, 
				targetos = beamId->osnum ) ;
			__CheckRC( sts, 1, "NDnode.NDdisconnect", wrapup ) ;
		sts = nd$wait_batch(	type		= GR_DELETED,
					l_object	= &MyGRid,
					nb_obj 		= 1 ) ;
		__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;
		cn_type = ND_COMP;
				sts = nd$wait_batch(
					type		= GR_GEOM_POSTED,
					l_obj_info	= &cn_type,
					l_object	= &Operand,
					nb_obj		= 1 ) ;
				__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;
	retFlag = 1;
	wrapup :
	return retFlag ;
}

end implementation VSmodFeature ;
