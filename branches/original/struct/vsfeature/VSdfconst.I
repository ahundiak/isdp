/*
	I/STRUCT
*/ 
class implementation VSdivFeature ;

#include <limits.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsweld.h"
#include "vsjoint.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"

from VSsubFeature	import	VSsetIndex ;
/*----------------------------------------------------------------------------*/
method GRconstruct( struct GRvg_construct *cl ) {

	long			*msg,		/* Completion code	*/
				sts ;		/* OM return code	*/
	struct VScnst_list 	*attr ;		/* Class attributes	*/
	struct GRobj_env	*operand ;	/* My operand		*/
	VSdspRep		oprndRep ;	/* Rep. of operand	*/
#define MAX VS_K_MAX_SUBS
%safe
	OM_S_OBJID		subs[MAX] ;	/* List of sub-features	*/
%endsafe
	int			i,		/* Loop-on-feet index	*/
				subCount,	/* Count of sub-features*/
				subMax ;	/* Max. of sub-features	*/
	unsigned int		subMask ;	/* Mask of sub-features	*/
	struct GRobj_env	input ;		/* For sub-features	*/
	struct VScnst_list	partList ;	/* For sub-features	*/
	VSdivArgs		*dvArgs ;	/* Division information	*/
	VSpartAttr		*theirAttr ;	/* Attr. of sub-features*/
	struct GRvg_construct	theirCnl ;	/* Cnst. of sub-features*/
	struct GRsymbology	mySymb ;	/* My symbology attr.	*/
	char			*saveName ;	/* Stores #1's name	*/
	OMuword			subClassid ;	/* Class of sub-features*/
	struct GRobj_env	moi,		/* My little self	*/
				elBfDiv,	/* Element before div.	*/
				divOprtr ;	/* Operator of division	*/

	subCount = 0 ;

	VSresetObjidList( MAX, subs ) ;

	saveName = cl->name ;

	msg = cl->msg ;

	/*
	 * Save the representation of the operand : the computation of this
	 * object may require a change of representation of its operand parent.
	 * and we want to be able to restore its original rep., should something
	 * have failed. The ACconstruct_feet methods are supposed to restore
	 * the original representation of the operand when they have changed it,
	 * as well as unconsume the operand in case of failure, but here
	 * failure may occur after this method, eg. in the construction of
	 * sub-features.
	 */
	attr	= (struct VScnst_list *) cl->class_attr ;
	operand	= attr->parent_list + VS_K_ConsumedIx ;
	om$send(msg	= message ACncpx.ACget_NV_rep( &oprndRep ),
		targetid= operand->_objid,
		targetos= operand->_osnum ) ;

	/*
	 * Must init sub-mask here, since this flag will be tested in the
	 * methods used during construction.
	 */
	sts = om$send(	msg	= message VSdivFeature.VSsetSubMask(
							msg, VS_K_SET_ALL, 0 ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSdivFeature.VSsetSubMask", wrapup ) ;

	/*
	 * Must zero out feature-attributes pointer otherwise we will get
	 * sent a GRputattr with those attributes which we will send
	 * up to the top feature ...
	 */
	dvArgs			= (VSdivArgs *) attr->feature_att ;
	attr->feature_att	= NULL ;

	cl->name = NULL ;
	sts = om$send(	msg	= message VSfeature.GRconstruct( cl ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	attr->feature_att	= (char *) dvArgs ;

	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Now stick two source features under you to consume your feet, with
	 * the attributes of your construction list.
	 */

	theirCnl		= *cl ;
	theirCnl.class_attr 	= (char *) &partList ;
	theirCnl.newflag	= FALSE ;
	theirCnl.geometry	= NULL ;
	theirAttr		= (VSpartAttr *) dvArgs->subFeatureAttr ;
	partList.parent_count	= 1 ;
	partList.feature_att	= (char *) theirAttr ;
	partList.parent_list	= &input ;
	partList.representation	= attr->representation ;
	input.mod_env		= *cl->env_info ;

	if( !cl->display ) {

		/*
		 * Sending wrt message because complex is a GRowner and
		 * therefore GRputsymb will be forwarded to components (feet)
		 * that it does not yet have. This must be done before
		 * ACconstruct_feet.
		 */
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

	subClassid = dvArgs->subFeatureClassid ;

	/*
	 * Find out how many sub-features were generated during your construc-
	 * tion.
	 */
	sts = om$send(	msg	= message VSdivFeature.VSgetSubMask(
					msg, &subMask, &subCount, &subMax ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSdivFeature.VSgetSubMask", wrapup ) ;

	for( i = 0 ; i < subMax ; i++ ) {

		if( !( subMask & ( 1 << i ) ) ) continue ;

		input._objid = my_id ;
		input._osnum = OM_Gw_current_OS ;

		*msg = EMS_E_OMerror ;

		sts = om$construct(	classid	= subClassid,
					p_objid	= subs + i,
					osnum	= OM_Gw_current_OS ) ;
		__CheckRC( sts, 1, "om$construct( VSsubFeature )", wrapup ) ;

		/*
		 * Set sub-feature's index BEFORE formatting it since its
		 * compute method will behave according to that very index.
		 */
		sts = om$send(	msg	= message VSsubFeature.VSsetIndex(
									msg, i),
				targetid= subs[i] ) ;

		sts = om$send(	msg	= message GRgraphics.GRconstruct(
								&theirCnl ),
				targetid= subs[i] ) ;

		if( !( sts & 1 & *theirCnl.msg ) ) {
			/*
			 * If GRconstruct failed, object has deleted itself.
			 */
			subs[i] = NULL_OBJID ;
			*msg	= MSFAIL ;
			goto wrapup ;
		}
		/*
		 * NOTE: sub-feature #0 will carry the name of this here object.
		 */
		if( i == 1 ) {
			sts = om$send(	msg	= message GRgraphics.GRputname(
								msg, saveName ),
					targetid= subs[i] ) ;
			__CheckRC( sts, *msg, "GRgraphics.GRputname", wrapup ) ;
		}
	}

	moi._objid	= my_id ;
	moi._osnum	= OM_Gw_current_OS ;
	moi.mod_env	= *cl->env_info ;
	/*
	 * CAUTION: parents may be pretends ! we must get the virtual parents.
	 */
	sts = VSgetVirtualInfo(	msg,
				&attr->parent_list[0]._grid,
				&elBfDiv.mod_env,
				&elBfDiv._grid ) ;
	sts = VSgetVirtualInfo(	msg,
				&attr->parent_list[1]._grid,
				&divOprtr.mod_env,
				&divOprtr._grid ) ;

	sts = vs$joinAfterDivision(
			msg		= msg,
			jnInfo		= (VSjoinInfo *) dvArgs->divInfo,
			elBfDiv		= &elBfDiv,
			elAfDiv		= &moi,
			divOperator	= &divOprtr,
			subElement0	= subs[0],
			subElement1	= subs[1],
			subEnv		= theirCnl.env_info ) ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :

	if( !( sts & 1 & *msg ) ) {
		long			isConsumed ;

		/*
		 * Send `hard' NDdelete to sub-features: we do not care about
		 * their possible overriding of NDdelete.
		 */

		for( i = 0 ; i < subCount ; i++ ) {
			if( !IF_NULL_OBJID( subs[i] ) ) {
				om$send(msg	= message ACncpx.NDdelete(
								cl->env_info ),
					mode	= OM_e_wrt_message,
					targetid= subs[i] ) ;
			}
		}

		om$send(msg	= message VSfeature.NDdelete( cl->env_info ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
		if( *msg & 1 ) *msg = MSFAIL ;

		/*
		 * If operand parent is still consumed, unconsume it !
		 */
		om$send(msg	= message NDmacro.ACtest_consumed( &isConsumed),
			targetid= operand->_objid,
			targetos= operand->_osnum ) ;
		if( isConsumed ) {
			long rc ;
			vs$unconsume(	msg	= &rc,
					object	= &operand->_grid,
					mod_env	= &operand->mod_env,
					rep	= oprndRep,
					compute	= TRUE ) ;

		}
	}
		
	cl->name = saveName ;

	return sts ;

} /* method GRconstruct */
/*----------------------------------------------------------------------------*/

end implementation VSdivFeature ;
