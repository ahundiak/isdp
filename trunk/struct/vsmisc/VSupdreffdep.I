/*
	I/STRUCT
*/
class implementation GRcontext ;

#include <stdio.h>
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "msdef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "refdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "GRgetctxsupe.h"

from NDnode	import	NDchange_node ;
from NDmacro	import	ACconsume,
			ACtest_consumed ;
from ASsourcein	import	ACtest_consumed ;
/*----------------------------------------------------------------------------*/
static long VSprocessConsume( actOs, actEnv )

OMuword		actOs ;
struct GRmd_env *actEnv ; {

	long		sts,
			msg ;
	int		i,
			max ;
	OMuword		osnum,
			classid ;
	struct GRid	dummy ;

	extern OM_p_OSD	*OM_GA_OSDs ;
	extern OMuword	OPP_ACpretendin_class_id ;

	osnum = actOs ;
	max = OM_GA_OSDs[osnum]->CurSpaceMapSize ;

	/*
	 * Loop on all objects in object space, looking for ACpretendin's: they
	 * are the intermediary between associative objects in the master file
	 * and their parents in reference files.
	 */
	for( i = 0 ; i < max ; i++ ) {
		sts = om$get_classid(	objid		= i,
					osnum		= osnum,
					p_classid	= &classid ) ;
		if( !( sts & 1 ) ) continue ;

		if( om$is_ancestry_valid(
				superclassid	= OPP_ACpretendin_class_id,
				subclassid	= classid ) != OM_S_SUCCESS )
			continue ;

		/* !!! I really should send here an NDmacro.ACtest_consumed
		 * !!! message with respect to object, but the GRNUC dodos
		 * !!! forgot again to integrate the modification: ACpretendin
		 * !!! which is a union of ASsourcein & ACpretend, rejects
		 * !!! the method because ASsourcein implements it BUT ACpretend
		 * !!! rejects it. A 'from ASsourcein inherit ACtest_consumed'
		 * !!! is STILL missing in ACpretendin.S
		 */
		sts = om$send(	msg	= message ASsourcein.ACtest_consumed(
									&msg ),
				mode	= OM_e_wrt_message,
				senderid= i,
				targetid= i,
				targetos= osnum ) ;

		if( !( sts & 1 & msg ) ) continue ;

		sts = om$send(	msg	= message NDmacro.ACconsume(
							&msg, "", FALSE,
							&dummy, actEnv ),
				senderid= i,
				targetid= i,
				targetos= osnum ) ;

	}

	return OM_S_SUCCESS ;

} /* VSprocessConsume */
/*----------------------------------------------------------------------------*/
static long VScheckMismatchConnections( osnum, RefOsnum, actEnv, updateFlag,
					p_misCon )

OMuword		osnum,
		RefOsnum ;
struct GRmd_env	*actEnv ;
int		updateFlag,
		*p_misCon ; {

	long			sts ;
	OMuint			misCon ;
	int			i ;
	OM_S_TAG_CON_INFO	*tags ;
	OM_S_OBJID		tagObjid ;
	OMuword			version,
				TagConVers ;
	OM_S_CHANSELECT		toTaggedObj,
				toChild ;

	/*
	 * If `updateFlag' is FALSE, the count of mismatched connection is
	 * returned but no updating takes place, otherwise the mismatched
	 * connections are updated.
	 */

	tags = NULL ; *p_misCon = 0 ;

	sts = om$mismatched_connections(
					osnum		= osnum,
					tagged_osnum	= RefOsnum,
					p_count		= (OMuint *) &misCon ) ;
	if( !( sts & 1 ) ) {
		/*
		 * Object space is probably not tagged, ie. no tagged 
		 * inter-object space connection was made.
		 */

		return OM_S_SUCCESS ;
	}

	*p_misCon = misCon ;

	if( !misCon ) {
		/*
		 * No mismatched connections.
		 */
		return OM_S_SUCCESS ;
	}

	if( !updateFlag ) {
		return OM_S_SUCCESS ;
	}

	tags = (OM_S_TAG_CON_INFO *) malloc( misCon * sizeof *tags ) ;
	if( !tags ) return OM_E_NODYNMEM ;

	sts = om$mismatched_connections(
					osnum		= osnum,
					tagged_osnum	= RefOsnum,
					p_count		= &misCon,
					size		= misCon,
					p_tag_con_info	= tags ) ;

	for( i = 0 ; i < misCon ; i++ ) {

		/*
		 * Put object onto the compute batch queue via NDchange_node.
		 * Do not test return code since if object is not subclass of
		 * NDnode, message send will fail...
		 */
		om$send(msg	= message NDnode.NDchange_node( actEnv ),
			senderid= tags[i].objid,
			targetid= tags[i].objid,
			targetos= osnum ) ;
		/*
		 * Have this object's tag version now match that of its parent.
		 */
		om$tag_to_objid(	osnum	= RefOsnum,
					tag	= tags[i].tag,
					p_objid	= &tagObjid ) ;

		toTaggedObj.type		= OM_e_num ;
		toTaggedObj.u_sel.number	= tags[i].tag_chan ; 
		toChild.type			= OM_e_num ;
		toChild.u_sel.number		= tags[i].chan ;

		om$test_connection(
				objid			= tags[i].objid,
				osnum			= osnum,
				p_chanselect		= &toChild,
				tag_osnum		= RefOsnum,
				tag_objid		= tagObjid,
				p_tag_version		= &version,
				p_tag_connect_version	= &TagConVers,
				p_tag_chanselect	= &toTaggedObj,
				force_flag		= TRUE ) ;
					
					
	}

	_FREE( tags ) ;

	return sts ;

} /* VScheckMismatchConnections */
/*----------------------------------------------------------------------------*/
long VScheckRefFilesDependency( msg, updateFlag, nbModRef, ModRefList )

long 	*msg ;
int	updateFlag,
	*nbModRef ;
OMuword	ModRefList[] ; {

	long 		sts,		/* OM return code		*/
			numberOfBytes,
			BytesReceived ;
	char 		osname[OM_K_MAXOSNAME_LEN];
	short		flag ;
	int  		count,		/* ... of contexts		*/
			misCon,		/* Count of mismatched
					   connection in one ref. file	*/
			modRef,		/* Count of modified ref. files	*/
    			i ;		/* Loop index			*/
	OMuword		RefOsnum ;	/* Osnum of a ref file		*/
	struct GRid	ctxId,		/* the context id 		*/	
			rfmgr ;		/* Id of ref. file mgr		*/
	OM_S_CHANSELECT rfmgrTOctx ;	/* Ref. file mgr -> context	*/
	struct GRmd_env	ctxEnv,		/* Environment from context	*/
			ActiveEnv ;	/* Environment of mater file	*/

	/*
	 * If `updateFlag' is FALSE then the list and  count of reference files
	 * which have changed is returned and no update of the active file
	 * takes place, otherwise the active file is updated.
	 */

	modRef	= 0 ;
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	if( nbModRef ) *nbModRef = 0 ;

	numberOfBytes = sizeof ActiveEnv ;
	gr$get_module_env(	msg	= msg,
				sizbuf	= &numberOfBytes,
				buffer	= &ActiveEnv,
				nret	= &BytesReceived ) ;
	
	/*
	 * Reconsume objects in reference files.
	 */
	VSprocessConsume( ActiveEnv._MD_OS, &ActiveEnv ) ;
		
	/*
	 * Get all attached reference files and process mismatched connections
	 * in all of them.
	 */
	sts = om$make_chanselect(	
				channame	= "Super_rfmgr.to_context",
				p_chanselect	= &rfmgrTOctx ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	/*
	 * Get the context Super.
	 */
	sts = GRgetctxsuper( msg, &rfmgr ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	sts = om$get_channel_count(	osnum		= rfmgr.osnum,
					objid		= rfmgr.objid,
					p_chanselect	= &rfmgrTOctx,
					count		= (OMuint *) &count ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	/*
	 * Loop on contexts.
	 */
	for( i = 0 ; i < count ; ++i ) {

		sts = om$send(
			msg	= message GRcontext.GRgetinstance(
							msg,
							&ctxEnv._MATRIX_TYPE,
							ctxEnv._MATRIX,
							&RefOsnum,
							&flag,
							&ctxId ),
			senderid	= rfmgr.objid,
			targetos	= rfmgr.osnum,
			p_chanselect	= &rfmgrTOctx,
			to		= i,
			from		= i ) ;

		if( !( 1 & sts & *msg ) ) continue ;

		/*
		 * See if this object space is active before
		 * trying to use this context object.
		 */
		 sts = om$os_number_to_name(	osnum	= RefOsnum,
						osname	= osname ) ;

		if( !( 1 & sts ) ) {
			/*
			 * Skip this osnum.
			 */
			continue ;
		}

		if( !( flag & GRACTIVATED_CONTEXT ) ) {
			/*
			 * This is the master file. Skip it.
			 */
			continue ;
		}

		sts = VScheckMismatchConnections(	ActiveEnv._MD_OS,
							RefOsnum,
							&ActiveEnv,
							updateFlag,
							&misCon ) ;
		if( misCon ) {
			if( ModRefList ) ModRefList[modRef++] = RefOsnum ;
		}
			

	} /* End for */

	if( nbModRef ) *nbModRef = modRef ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VScheckRefFilesDependency */
/*----------------------------------------------------------------------------*/

end implementation GRcontext ;
