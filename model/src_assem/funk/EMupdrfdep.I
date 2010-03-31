class implementation GRcontext ;

#include <stdio.h>
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "refdef.h"

#include "DIdef.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

from NDnode	import	NDchange_node ;

static long EMcheckMismatchConnections( osnum, RefOsnum, actEnv, updateFlag,
					p_misCon )

OMuword		osnum, RefOsnum ;
struct GRmd_env	*actEnv ;
int		updateFlag, *p_misCon ; 
{
long			sts ;
OMuint			misCon ;
int			i ;
OM_S_TAG_CON_INFO	*tags ;
OM_S_OBJID		tagObjid ;
OMuword			version, TagConVers ;
OM_S_CHANSELECT		toTaggedObj, toChild ;

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
	if( !( sts & 1 ) ) 
	{
		/*
		 * Object space is probably not tagged, ie. no tagged 
		 * inter-object space connection was made.
		 */
#ifdef DEBUG
		printf( "Osnum [%d] not tagged\n", RefOsnum ) ;
#endif
		return OM_S_SUCCESS ;
	}

	*p_misCon = misCon ;

	if( !misCon ) 
	{
		/*
		 * No mismatched connections.
		 */
#ifdef DEBUG
		printf( "No mismatched connections in [%d]\n", RefOsnum ) ;
#endif
		return OM_S_SUCCESS ;
	}

#ifdef DEBUG
	printf( "Mismatched connections : [%d]\n", misCon ) ;

#endif
	if( !updateFlag ) 
	{

#ifdef DEBUG
		printf( "Updating of mismatches not required\n" ) ;
#endif
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

	for( i = 0 ; i < misCon ; i++ ) 
	{
#ifdef DEBUG
		printf( "Mismatched id : [%d]\n", tags[i].objid ) ;
#endif
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

#ifdef DEBUG
		printf( "Tagged objid : [%d]\n", tagObjid ) ;
#endif

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
	if ( tags ) free( tags ) ;

	return sts ;

}
/*----------------------------------------------------------------------------*/
long EMcheckRefFilesDependency( msg, updateFlag, nbModRef, ModRefList )

long 	*msg ;
int	updateFlag, *nbModRef ;
OMuword	ModRefList[] ; 
{
long 		sts,		/* OM return code		*/
		numberOfBytes,
		BytesReceived ;
char 		osname[OM_K_MAXOSNAME_LEN];
short		flag ;
int  		count,		/* ... of contexts		*/
		misCon,		/* Count of mismatched
				   connection in one ref. file	*/
		modRef,		/* Count of modified ref. files	*/
		i, j ;		/* Loop index			*/
OMuword		RefOsnum ;	/* Osnum of a ref file		*/
struct GRid	ctxId,		/* the context id 		*/	
		rfmgr ;		/* Id of ref. file mgr		*/
OM_S_CHANSELECT rfmgrTOctx ;	/* Ref. file mgr -> context	*/
struct GRmd_env	ctxEnv,		/* Environment from context	*/
		ActiveEnv ;	/* Environment of mater file	*/

struct GRid     pid;
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

#ifdef DEBUG
	printf( "Active osnum : [%d]\n", ActiveEnv.md_id.osnum ) ;
#endif

	/* 
	 * See if the environment contains a EMpart definition,
	 * If not found, return.
	 */
	sts = asm$get_file_part( msg = msg,
				mod_env = &ActiveEnv,
				part_id = &pid );

	if( !( sts & *msg & 1 ) )
	{
#ifdef DEBUG
		printf( "Active Os is not a FilePart\n");
#endif
		return sts;
	}

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
	for( i = 0 ; i < count ; ++i ) 
	{
		if( ModRefList ) 
		{
			/* 
			 * Check if the RefOsnum is not already in
			 * the ModRefList and then process it. This is
 			 * to make a unique list of osnums
			 */
			for( j = 0; j < *nbModRef; j++ )
			{
				if( ModRefList[j] == RefOsnum )
					break;
			}
			/* RefOsnum already in the list  */
			if ( j != *nbModRef ) 
			{
				*msg	= MSSUCC ;
				sts	= OM_S_SUCCESS ;
				return sts;
			}
		}

		sts = om$send(
			msg	= message GRcontext.GRgetinstance(
							msg,
							&ctxEnv.md_env.matrix_type,
							ctxEnv.md_env.matrix,
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
#ifdef DEBUG
		printf( "Osnum  : [%d]\n", RefOsnum ) ;
		printf( "Osname : [%s]\n", osname ) ;
#endif
		if( !( 1 & sts ) ) 
		{
			/*
			 * Skip this osnum.
			 */
#ifdef DEBUG
			printf( "No OS name for [%d]\n", RefOsnum ) ;
#endif
			continue ;
		}

		if( !( flag & GRACTIVATED_CONTEXT ) ) 
		{
			/*
			 * This is the master file. Skip it.
			 */
#ifdef DEBUG
			printf( "Context not active for [%s]\n", osname ) ;
#endif
			continue ;
		}

		sts = EMcheckMismatchConnections(	ActiveEnv.md_id.osnum,
							RefOsnum,
							&ActiveEnv,
							updateFlag,
							&misCon ) ;
		if( misCon ) 
		{
			if( ModRefList ) 
				ModRefList[modRef++] = RefOsnum ;
		}
	} /* End for */

	if( nbModRef ) 
		*nbModRef = modRef ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

wrapup :
	return sts ;
}

end implementation GRcontext ;
