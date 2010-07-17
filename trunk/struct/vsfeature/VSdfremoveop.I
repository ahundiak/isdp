/* $Id: VSdfremoveop.I,v 1.2 2001/04/14 17:09:45 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        struct/vsfeature/VSdfremoveop.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdfremoveop.I,v $
 *      Revision 1.2  2001/04/14 17:09:45  jayadev
 *      remove operator problem
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/14/00        Jayadev         remove operator fails 
 *                                      when one of the sub-features
 *                                      of a feature is deleted 
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
class implementation VSdivFeature ;

#include <stdlib.h>
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
#include "vsvirtualinf.h"

extern struct GRid	NULL_GRID ;
#define _VSMEMDUP( p, n, t ) ((t *) VSmemdup( (p), (n) * sizeof( t ) ))
/*----------------------------------------------------------------------------*/
long VSundoRejoiningInducedByOperator( msg, subsIds, subsEnv )

long		*msg ;
struct GRid	subsIds[2] ;
struct GRmd_env	*subsEnv ; {

	/*
	 * Treat the case when, for instance a beam which was joined to
	 * a plate has been split in two by a point, and the two sub-beams
	 * have been rejoined to the plate with two sub-joints. When the
	 * operation point is removed, the two sub-joints must go and the
	 * original joint be restored:
	 *
	 * +-beam------------------+		+-sub-beam1++-sub-beam2-+
	 * |                       |		|          ||           |
	 * | joint                 | -split->	|sub-joint1||sub-joint2 |
	 * +-=-=-=-=-=-=-=-=-=-=-=-+		+-=-=-=-=-=||-=-=-=-=-=-+
	 * +-plate-----------------+		+-plate-----------------+
	 *
	 * Graphwise:
	 *
	 * plate        beam		plate           beam             point
	 *   |            |		  |               |                |
	 *   +------+-----+               +-------+-------+                |
	 *          |			  |       |       |                |
	 *        joint			  |     joint     +-------+--------+
	 *				  |       |               |
	 *				  |   div. joint        div. beam
	 *				  |	  |               |
	 *                                | +-----+-----+   +-----+-----+
	 *				  | |           |   |           |
	 *				  | |           | sub-beam1  sub-beam2
	 *				  | |           |   |           |
	 *                                +-+-----------)---+           |
	 *				  |	   |    |               |
	 *				  |  sub-joint1 |               |
	 *				  |             |               |
	 *				  +-------------+---------------+
	 *					        |
	 *					    sub-joint2
	 *
	 */
	long		sts ;
	int		i,
			j,
			jcount	= 0,
			deleted ;
	unsigned long	type ;
	VSjointList	*jL	= NULL ;
	struct GRid	opMgr ;

	/*
	 * For the sub-joints on each sub-feature, the deletes them, the undo
	 * will be carried by the joint division manager when it becomes aware
	 * that all the sub-joints it carries are gone.
	 */
	for( i = 0 ; i < 2 ; i++ ) {
		sts = om$send(	msg	= message VSfeature.VSgetJoints(
							msg, subsEnv,
							&jcount, &jL ),
				senderid= subsIds[i].objid,
				targetid= subsIds[i].objid,
				targetos= subsIds[i].osnum ) ;
		if( !( sts & 1 & *msg ) ) continue ;

		for( j = 0 ; j < jcount ; j++ ) {
			om$send(msg	= message VSfeature.VSgetResultType(
								msg, &type ),
				senderid= jL[j].joint._objid,
				targetid= jL[j].joint._objid,
				targetos= jL[j].joint._osnum ) ;
			if( !( type & VS_m_SUB_JOINT ) ) continue ;
			/*
			 * Got one: gets its division manager and send it a
			 * remove operator message, with a null operator since
			 * divided joints have none.
			 */
			om$send(msg	= message VSfeature.VSgetOperationMgr(
				 				msg, &opMgr ),
				senderid= jL[j].joint._objid,
				targetid= jL[j].joint._objid,
				targetos= jL[j].joint._osnum ) ;

			om$send(msg	= message VSmodFeature.VSremoveOperator(
							msg, subsEnv,
							&NULL_GRID, &deleted ),
				senderid= opMgr.objid,
				targetid= opMgr.objid,
				targetos= opMgr.osnum ) ;
		}
		_FREE( jL ) ; jL = NULL ; jcount = 0 ;
	}

	return sts ;

} /* VSundoRejoiningInducedByOperator */
/*----------------------------------------------------------------------------*/
long VSrmJointsIfAny( msg, operator, subsEnv, subsCount, subsIds )

long		*msg ;
struct GRid	*operator,
		subsIds[] ;
struct GRmd_env *subsEnv ;
int		subsCount ; {

	long			sts ;
	int			i,
				j,
				k,
				jcount = 0 ;
	VSjointList		*jlist = NULL ;

	if( subsCount == 2 ) {
		VSundoRejoiningInducedByOperator( msg, subsIds, subsEnv ) ;
	}
	for( i = 0 ; i < subsCount ; i++ ) {
		/*
		 * Beware some sub-features may be NULL_OBJID if they have
		 * been deleted.
		 */
		if( IF_NULL_OBJID( subsIds[i].objid ) ) continue ;

		sts = om$send(	msg	= message VSfeature.VSgetJoints(
						msg, subsEnv, &jcount, &jlist ),
				senderid= subsIds[i].objid,
				targetid= subsIds[i].objid,
				targetos= subsIds[i].osnum ) ;
		if( !( sts & 1 & *msg ) || !jcount ) {
			continue ;
		}
		for( j = 0 ; j < jcount ; j++ ) {
			if( IF_EQ_GRID(	*operator,
					jlist[j].otherFeature._grid ) ) {
				/*
				 * Sub-feature was joined to operator.
				 */
				om$send(msg	= message NDnode.NDdisplay(
							0,
							GRbe,
							&jlist[j].joint.mod_env ),
					senderid= jlist[j].joint._objid,
					targetid= jlist[j].joint._objid,
					targetos= jlist[j].joint._osnum ) ;
				vs$bulk_delete(	objenvs = &jlist[j].joint ) ;
				break ;
			}
			for( k = i + 1 ; k < subsCount ; k++ ) {
				if( !IF_EQ_GRID(subsIds[k],
						jlist[j].otherFeature._grid ) ){
					continue ;
				}
				/*
				 * Sub-feature was joined to another
				 * sub-feature.
				 */
				om$send(msg	= message NDnode.NDdisplay(
							0,
							GRbe,
							&jlist[j].joint.mod_env ),
					senderid= jlist[j].joint._objid,
					targetid= jlist[j].joint._objid,
					targetos= jlist[j].joint._osnum ) ;

				vs$bulk_delete(	objenvs = &jlist[j].joint ) ;
			}
		}
		_FREE( jlist ) ; jlist = NULL ; jcount = 0 ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	return sts ;

} /* VSrmJointsIfAny */
/*----------------------------------------------------------------------------*/
method VSremoveOperator(long		*msg ;
			struct GRmd_env *myEnv ;
			struct GRid	*operator ;
			int		*deleted ) {

	long		sts ;			/* OM return code	*/
	int		i,			/* Loop index		*/
			j,			/* Loop index		*/
			nbRoots,		/* Count of my roots	*/
			*nbgKids = NULL,	/* Counts of grand kids	*/
			nbSubFeatures,		/* # of sub-features	*/
			action ;		/* Values follow ...	*/
#define	_disappear	1
#define _fillHoles	2
	struct GRid	parent,			/* One of my roots	*/
			subFtrs[VS_K_MAX_SUBS],	/* List of my children	*/
			**gKids = NULL,		/* Lists of grand kids	*/
			*victim = NULL ;	/* Me & my kids		*/
	struct GRobj_env
			virtual ;		/* Vir. parent if nested*/
	VSdspRep	rep0 ;			/* Repres. of sub-pl. #0*/
	int		maxSubFeatures,		/* Max # of sub-features*/
			unconsumeParent,	/* Unconsume parent ?	*/
			nonNull ;		/* Index of 1st non-null
						    sub-feature		*/
	OM_S_OBJID	saveMdId ;
	OMuword	        clsId ;

	*msg	 	= MSFAIL ;
	sts	 	= OM_E_ABORT ;
	*deleted	= FALSE ;

        __DBGpr_com(" VSremoveOperator of VSdivFeature ");
	sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_ROOT,
							&parent,
							1,
							NULL,
							VS_K_ConsumedIx,
							VS_K_ConsumedIx,
							&nbRoots ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	action = nbRoots > 2 ? _fillHoles : _disappear ;

	if( action == _fillHoles ) {
	  /*
	   * Lost one operator parent, but others remain: recompute
	   * yourself to fill the holes.
	   */
	  struct GRid	moi ;
	  int		cn_type = ND_COMP ;

	  sts = om$send(msg	= message NDnode.NDdisconnect( 1, operator ),
			targetid= my_id ) ;
	  __CheckRC( sts, 1, "NDnode.NDdisconnect", wrapup ) ;

	  moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;
	  nd$wait_batch(	type		= GR_GEOM_POSTED,
	  			l_object 	= &moi,
	  			l_obj_info	= &cn_type,
	  			nb_obj		= 1 ) ;
	  *msg = MSSUCC ;

	  goto wrapup ;
	}

	/*
	 * Unconsume parent. First give it the same representation as
	 * sub-feature #0 which is an image of parent feature.
	 */
	sts = om$send(	msg	= message VSdivFeature.VSget_sub_features(
							msg,
							&maxSubFeatures,
							subFtrs ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSdivFeature.VSget_sub_features", wrapup ) ;
	__DBGpr_int(" maxSubFeatures ",maxSubFeatures);

	/*
	 * If there are more than 1 sub-feature which is consumed then we
	 * cannot remove the operator easily, since we would have to merge
	 * the operators which cause consumes of several sub-features...
         */
	/* 
	 * Some of the sub-features might have been deleted 
         */
	j = 0 ;
	for( i = 0 ; i < maxSubFeatures ; i++ ) {
	  sts = om$get_classid ( osnum     = subFtrs[i].osnum,
				 objid     = subFtrs[i].objid,
				 p_classid = &clsId ) ;
	  if(!(sts&1) || (clsId == 0)) { 
	    __DBGpr_com(" one of the subfeatures is null");
	    subFtrs[i].objid = NULL_OBJID;
	    subFtrs[i].osnum = 2;
	  }
	}
	
	for( i = 0 ; i < maxSubFeatures ; i++ ) {
	  if(!IF_NULL_OBJID( subFtrs[i].objid )){ 
	    sts = om$send(	msg	= message NDmacro.ACtest_consumed( msg ),
				targetid= subFtrs[i].objid,
				targetos= subFtrs[i].osnum ) ;
	    if( *msg & 1 ) {
	      __DBGpr_obj("consumed subFeature",subFtrs[i]);
	      j++ ;
	      if( j > 1 ) {
		*msg = EMS_E_InvalidCase ;
		sts  = OM_W_ABORT ;
		__DBGpr_com(" consumed test failed ");
		goto wrapup ;
	      }
	    }
	  }
	}
	
        nonNull = -1 ;
	for( i = 0 ; i < maxSubFeatures ; i++ ) {
		if( nonNull == -1 ) {
			if( !IF_NULL_OBJID( subFtrs[i].objid ) ) {
				nonNull = i ;
			}
		}
	}

	if( nonNull == -1 ) {
		/*
		 * Something wrong.
		 */
		vs$inv_arg() ;
	}
	/*
	 * Remove possible joints either between operator and sub-features
	 * or between sub-features.
	 */
	VSrmJointsIfAny( msg, operator, myEnv, maxSubFeatures, subFtrs ) ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &rep0 ),
			targetid= subFtrs[nonNull].objid,
			targetos= subFtrs[nonNull].osnum ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	/*
	 * Get virtual parent (my REAL parent may be a pretend).
	 */
	sts = VSgetVirtualInfo( msg, &parent,
				&virtual.mod_env, &virtual._grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	sts = om$send(	msg	= message ACncpx.ACput_NV_rep( rep0 ),
			targetid= virtual._objid,
			targetos= virtual._osnum ) ;
	__CheckRC( sts, 1, "ACncpx.ACput_NV_rep", wrapup ) ;

	/*
	 * Disconnect children of both sub-features and re-connect them to
	 * parent feature. Then go away, as well as sub-features.
	 */
	if( !(	  ( gKids   = _MALLOC( maxSubFeatures, struct GRid * ) )
	       && ( nbgKids = _MALLOC( maxSubFeatures, int           ) ) ) ) {
		vs$mem_fail() ;
	}
	for( i = 0 ; i < maxSubFeatures ; i++ ) {
		gKids[i] = NULL ; nbgKids[i] = 0 ;
	}

	unconsumeParent	= TRUE ;
	nbSubFeatures	= 0 ;
	for( i = 0 ; i < maxSubFeatures ; i++ ) {

		if( !IF_NULL_OBJID( subFtrs[i].objid ) ) {

			sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_CHILDREN | ND_IN_BUF,
							NULL,
							0,
							gKids + i,
							0,
							OM_K_MAXINT,
							nbgKids + i ),
					targetid= subFtrs[i].objid,
					targetos= subFtrs[i].osnum ) ;
			__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

			nbSubFeatures++ ;
		} else {
			nbgKids[i] = 0 ;
		}
	
		if( nbgKids[i] ) {
			gKids[i] = _VSMEMDUP(	gKids[i],
						nbgKids[i],
						struct GRid ) ;
			if( !gKids[i] ) vs$mem_fail() ;
			if( VSgetConsumer(	subFtrs + i,
						nbgKids[i],
						gKids[i] ) != -1 ) {
				unconsumeParent = FALSE ;
			}
		}
	}
	/*
	 * Unconsume parent only if no consumer will be connected to it,
	 * otherwise it will have its consume bit cleared.
	 */
	if( unconsumeParent ) {
		sts = vs$unconsume(	msg	= msg,
					object	= &parent,
					mod_env	= &virtual.mod_env,
					compute	= TRUE ) ;
		__CheckRC( sts, *msg, "vs$unconsume", wrapup ) ;

	}

	for( i = 0 ; i < maxSubFeatures ; i++ ) {

		for( j = 0 ; j < nbgKids[i] ; j++ ) {

			sts = om$send(
				msg	= message NDnode.NDchange_connect(
						1,
						subFtrs + i,	/* Old root */
						&parent ),	/* New root */
				targetid= gKids[i][j].objid,
				targetos= gKids[i][j].osnum ) ;
			__CheckRC( sts, 1, "NDnode.NDchange_connect", wrapup ) ;
		}
	}

	/*
	 * Now I disconnect from my parents. This could be done
	 * in NDdelete but my NDdelete tests parent count, which
	 * if non-zero, results in a different action.
	 */
	sts = om$send(	msg	= message NDnode.NDdisconnect( 0, NULL),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDdisconnect", wrapup ) ;

	/*
	 * Put parent feature onto batch Q if grand-children have been hooked
	 * onto it (else unconsume has put it back to a decent state).
	 */
	if( nbgKids[0] || nbgKids[1] ) {
		int cn_type = ND_COMP ;

		sts = nd$wait_batch(	type		= GR_GEOM_POSTED,
					l_obj_info	= &cn_type,
					l_object	= &parent,
					nb_obj		= 1 ) ;
		__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;

	}

	/*
	 * I and my children must go.
	 */
	if( !( victim	= _MALLOC( nbSubFeatures + 1, struct GRid ) ) ) {
		vs$mem_fail() ;
	}
	victim[0].objid = my_id ;
	victim[0].osnum = OM_Gw_current_OS ;
	for( j = 1, i = 0 ; i < maxSubFeatures ; i++ ) {
		if( !IF_NULL_OBJID( subFtrs[i].objid ) ) {
			victim[j++] = subFtrs[i] ;
		}
	}

	/*
	 * Note the following display will trigger an exec batch if the batch
	 * defer flag is off.
	 */
	vs$bulk_display(	count	= nbSubFeatures + 1,
				grids	= victim,
				theEnv	= myEnv,
				dpmode	= GRbe ) ;

	saveMdId = myEnv->_MD_ID ;
	myEnv->_MD_ID = NULL_OBJID ;
	sts = nd$wait_batch(	type		= GR_DELETED,
				l_object	= victim,
				nb_obj 		= nbSubFeatures + 1 ) ;
	myEnv->_MD_ID = saveMdId ;
	__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;

	*deleted = TRUE ;

	/*
	 * Redisplay parent which has disappeared because other
	 * graphics at the same location have been erased.
	 */
	vs$bulk_display( objenvs = &virtual, dpmode = GRbd ) ;

	*msg	 = MSSUCC ;
	sts	 = OM_S_SUCCESS ;

	wrapup :
		if( gKids ) {
			for( i = 0 ; i < maxSubFeatures ; i++ )
				if( nbgKids[i] ) _FREE( gKids[i] ) ;
			_FREE( gKids	) ;
		}
		_FREE( nbgKids		) ;
		_FREE( victim		) ;
		return sts ;

} /* method VSremoveOperator */
/*----------------------------------------------------------------------------*/

end implementation VSdivFeature ;
