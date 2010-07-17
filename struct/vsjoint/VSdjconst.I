/*
	I/STRUCT
*/ 
class implementation VSdivJoint ;

#include <limits.h>
#include "EMSmsgdef.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

from VSsubFeature	import	VSsetIndex ;
/*----------------------------------------------------------------------------*/
method GRconstruct( struct GRvg_construct *cl ) {

	long			*msg,		/* Completion code	*/
				sts ;		/* OM return code	*/
#define MAX VS_K_MAX_SUBS
	OM_S_OBJID		subJs[MAX] ;	/* List of sub-joints  	*/
	int			i,		/* Loop-on-outputs index*/
				subCount,	/* Count of sub-features*/
				nbSubJsCreated;	/* Count of sub-joints	*/
	struct VScnst_list 	*attr = NULL ;	/* Class attributes	*/
#define PARENTJN	0
#define FEATURE0	1
#define FEATURE1	2
#define SJPC		3			/* Sub-jnt parent count	*/
	struct GRobj_env	parents[SJPC] ;	/* For sub-joints	*/
	struct GRid		subFs[MAX] ;	/* Subs of div'd feature*/
	struct VScnst_list	partList ;	/* For sub-joints	*/
	VSdivArgs		*dvArgs ;	/* Division information	*/
	VSpartAttr		*theirAttr ;	/* Attr. of sub-features*/
	struct GRvg_construct	theirCnl ;	/* Cnst. of sub-features*/
	struct GRsymbology	mySymb ;	/* My symbology attr.	*/
	OMuword			subClassid ;	/* Class of sub-joints	*/
	VSsubJointInfo		*jnInfo ;	/* Info for sub-joints	*/
	GRname			subJnName ;	/* Name for a sub-joint	*/

	SetProc( VSdivJoint_GRconstruct ) ; Begin ; __DBGpr_me() ;

	nbSubJsCreated = subCount = 0 ;

	VSresetObjidList( MAX, subJs ) ;

	msg = cl->msg ;

	/*
	 * Must init sub-mask here, since this flag will be tested in the
	 * methods used during construction.
	 */
	sts = om$send(	msg	= message VSdivFeature.VSsetSubMask(
							msg, VS_K_SET_ALL, 0 ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSdivFeature.VSsetSubMask", wrapup ) ;

	/*
	 * Must zero out joint-attributes pointer otherwise we will get
	 * sent a GRputattr with those attributes which we will send
	 * up to the top joint ... (`cl->class_attr' is for sub-joints).
	 */
	attr			= (struct VScnst_list *) cl->class_attr ;
	dvArgs			= (VSdivArgs *) attr->feature_att ;
	attr->feature_att	= NULL ;

	__DBGpr_int( "Parent count", attr->parent_count ) ;

	cl->name = NULL ;
	sts = om$send(	msg	= message VSfeature.GRconstruct( cl ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	attr->feature_att	= (char *) dvArgs ;

	if( !( sts & 1 & *msg ) ) {
		__DBGpr_com( "VSfeature.GRconstruct wrt message FAILED" ) ;
		goto wrapup ;
	}

	jnInfo = (VSsubJointInfo *) dvArgs->divInfo ;

	/*
	 * Now stick two sub-joints under you, with the attributes of your
	 * construction list.
	 */

	theirCnl		= *cl ;
	theirCnl.class_attr 	= (char *) &partList ;
	theirCnl.newflag	= FALSE ;
	theirCnl.geometry	= NULL ;
	theirAttr		= (VSpartAttr *) dvArgs->subFeatureAttr ;
	partList.parent_count	= SJPC ;
	partList.feature_att	= (char *) theirAttr ;
	partList.parent_list	= parents ;
	partList.representation	= attr->representation ;

	parents[PARENTJN]._objid	= my_id ;
	parents[PARENTJN]._osnum	= OM_Gw_current_OS ;
	parents[PARENTJN].mod_env	= *cl->env_info ;

	parents[FEATURE1]		= jnInfo->otherFeature ;
	parents[FEATURE0].mod_env	= jnInfo->divFeature.mod_env ;

	if( !cl->display ) {

		/*
		 * Sending wrt message because complex is a GRowner and
		 * therefore GRputsymb will be forwarded to components (outputs)
		 * that it does not yet have. This must be done before
		 * ACconstruct_feet.
		 */
		__DBGpr_com( "Transferring my symbology to sub-joints" );
		sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

		theirCnl.display= &mySymb.display_attr ;
		theirCnl.level	= mySymb.level ;
	}
	sts = om$send(	msg	= message ACncpx.ACget_NV_rep(
						&partList.representation ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	__DBGpr_int( "Rep for sub-joints", partList.representation ) ;	

	subClassid = dvArgs->subFeatureClassid ;

	sts = om$send(	msg	= message VSdivFeature.VSget_sub_features(
							msg, &subCount, subFs ),
			targetid= jnInfo->divFeature._objid,
			targetos= jnInfo->divFeature._osnum ) ;
	__CheckRC( sts, *msg, "VSdivFeature.VSget_sub_features", wrapup ) ;

	for( i = 0 ; i < subCount ; i++ ) {

		if( IF_NULL_OBJID( subFs[i].objid ) ) {
			__DBGpr_int( "Sub-feature not generated", i ) ;
			continue ;
		}
		__DBGpr_int( "Building sub-joint #", i ) ;

		__DBGpr_obj( "Trying sub-feature", subFs[i] ) ;

		parents[FEATURE0]._grid	= subFs[i] ;

		*msg = EMS_E_OMerror ;

		sts = om$construct(	classid	= subClassid,
					p_objid	= subJs + i,
					osnum	= OM_Gw_current_OS ) ;
		__CheckRC( sts, 1, "om$construct( VSsubFeature )", wrapup ) ;

		/*
		 * Set sub-joint's index BEFORE formatting it since its
		 * compute method will behave according to that very index.
		 */
		sts = om$send(	msg	= message VSsubFeature.VSsetIndex(
									msg, i),
				targetid= subJs[i] ) ;

		sts = om$send(	msg	= message GRgraphics.GRconstruct(
								&theirCnl ),
				targetid= subJs[i] ) ;

		/*
		 * If GRconstruct failed, object has deleted itself,
		 * continue with next sub-feature, since we may be in
		 * a case where:
		 *
		 * +-------------+      +-------------+      +-------------+  
		 * |1            |      |2            |      |2            |
		 * |             | -A-> +--j23--------+ -B-> +-------------+ 
		 * |             |      |3            |      |4            |
		 * |             |      |             |      +-------------+ 
		 * |             |      |             |      |5            | 
		 * +-------------+      +-------------+      +-------------+
		 *
		 * Splitting plates with placement of joints, when we arrive
		 * at B and 3 has been split into 4 and 5, we are trying
		 * to replace j23 by joints joining 4 and 5 to 2. Trying to
		 * joint 5 and 2 will obviously fail, so we must go on to
		 * establish j42.
		 */
		if( !( sts & 1 & *theirCnl.msg ) ) {
			__DBGpr_int( "GRconstruct failed for", subJs[i] ) ;
			subJs[i] = NULL_OBJID ;
			/*
			 * Set sub-joint as not generated.
			 */
			om$send(msg	= message VSdivFeature.VSsetSubMask(
						msg, VS_K_REM_BITS, 1 << i ),
				targetid= my_id ) ;

			/*
			*msg	 = MSFAIL ;
			goto wrapup ;
			*/
			continue ;
		}
		/*
		 * NOTE: sub-joint #0 will carry the name of this here object.
		 */
		if( i >= 1 && jnInfo->dir ) {
			theirCnl.name = subJnName ;

			/*
			 * Find a name for sub-joints from parents it joins.
			 */
			VSmakeJointName(	msg,
						&parents[FEATURE0]._grid,
						&parents[FEATURE1]._grid,
						jnInfo->dir,
						subJnName ) ;
			sts = om$send(	msg	= message GRgraphics.GRputname(
							msg, subJnName ),
					targetid= subJs[i] ) ;
			__CheckRC( sts, *msg, "GRgraphics.GRputname", wrapup ) ;
			__DBGpr_str( "Sub #i>=1's name", subJnName ) ;
		}
		nbSubJsCreated++ ;
	}

	if( nbSubJsCreated ) {
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
	} else {
		sts	= OM_W_ABORT ;
		*msg	= EMS_W_NoSolution ;
	}

	wrapup :
	if( !( sts & 1 & *msg ) ) {
		struct GRobj_env	*operand ;
		long			isConsumed ;

		/*
		 * Send `hard' NDdelete to sub-joints: we do not care about
		 * their possible overriding of NDdelete.
		 */
		for( i = 0 ; i < subCount ; i++ ) {
			if( !IF_NULL_OBJID( subJs[i] ) ) {
				om$send(msg	= message ACncpx.NDdelete(
								cl->env_info ),
					mode	= OM_e_wrt_message,
					targetid= subJs[i] ) ;
			}
		}
		om$send(msg	= message VSfeature.NDdelete( cl->env_info ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
		if( *msg & 1 ) *msg = MSFAIL ;
		/*
		 * If operand parent is still consumed, unconsume it !
		 * The ACconstruct_feet methods are supposed to unconsume
		 * operand in case of failure, but here failure may occur after
		 * this method, eg. in the construction of sub-joints.
		 */
		operand	= attr->parent_list + VS_K_ConsumedIx ;
		om$send(msg	= message NDmacro.ACtest_consumed( &isConsumed),
			targetid= operand->_objid,
			targetos= operand->_osnum ) ;
		if( isConsumed ) {
			long rc ;
			__DBGpr_com( "Parent was consumed, restoring ..." ) ;
			vs$unconsume(	msg	= &rc,
					object	= &operand->_grid,
					mod_env	= &operand->mod_env,
					compute	= FALSE ) ;

		}
	}
		
	End
	return sts ;

} /* method GRconstruct */
/*----------------------------------------------------------------------------*/

end implementation VSdivJoint ;
