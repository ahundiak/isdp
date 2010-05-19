/*
	I/VDS	Copy
	
Abstract
	Recusively retrieves the leaves of the owner/component graph, given
	a root owner.
Arguments
	OUT	long		*msg		Completion code
	IN	struct GRid	*target		Root of ownership graph.
	OUT	int		*count		... of components
	OUT	struct GRid	**leaves	list of components
Note
	`*leaves' is malloced, it is up to the caller to free it if not NULL.
	Function will return no leaves if `*target' is not an owner.
	If function fails `*count' will be set to 0 and `*leaves' to NULL.
*/
#include <stdio.h>		/* For NULL		*/
#include <stdlib.h>		/* For malloc and free	*/
#include "OMminimum.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "gr.h"			/* Structs GR* for graphic info	*/
#include "msdef.h"
#include "EMSutlmacros.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"
/*
 * Inclues of function prototypes.
 */
#include "v_ocgrleaves.h"
/*----------------------------------------------------------------------------*/
static long VD__getLeavesOfOwnerCmpGraph( msg, target, count, leaves )

long		*msg ;
struct GRid	*target	;
int		*count ;
struct GRid	**leaves ; {

	long		sts ;
	int		nbCmps ;
	OM_S_CHANSELECT	toCmps ;

	ems$make_chanselect( chan_label    = GRcmpowner_to_components,
			     chan_selector = &toCmps ) ;
	sts = om$get_channel_count(	p_chanselect	= &toCmps,
					objid		= target->objid,
					osnum		= target->osnum,
					count		= (OMuint *) &nbCmps ) ;
	if( !( sts & 1 ) || !nbCmps ) {
		
		if( leaves ) {
			(*leaves)[*count] = *target ;
		}
		(*count)++ ;
	} else {
		int		i ;
		struct GRid	cmp ;

		for( i = 0 ; i < nbCmps ; i++ ) {
			/*
			 * OK to use this OM primitives since the
			 * owner/component channel is ordered.
			 */
			sts = om$get_objid_at_index(
				p_chanselect	= &toCmps,
				objid		= target->objid,
				osnum		= target->osnum,
				index		= i,
				objidaddr	= &cmp.objid,
				osnumaddr	= &cmp.osnum ) ;
			if( !( sts & 1 ) ) {
				*msg = EMS_E_OMerror ;
				goto wrapup ;
			}

			/*
			 * Now explore component `cmp'.
			 */
			sts = VD__getLeavesOfOwnerCmpGraph(
					msg, &cmp, count, leaves ) ;
			if( !( sts & 1 & *msg ) ) goto wrapup ;
		}
	}
			
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		return sts ;

} /* VD__getLeavesOfOwnerCmpGraph */
/*----------------------------------------------------------------------------*/
long VD_getLeavesOfOwnerCmpGraph( msg, target, count, leaves )

long		*msg ;
struct GRid	*target	;
int		*count ;
struct GRid	**leaves ; {

	long 	sts ;

	*count = 0 ; *leaves = NULL ;

	/*
	 * First count leaves.
	 */
	sts = VD__getLeavesOfOwnerCmpGraph( msg, target, count,
					    (struct GRid **) NULL ) ;
	if( !( sts & 1 & *msg ) || !*count ) goto wrapup ;

	if( !( *leaves = _MALLOC( *count, struct GRid ) ) ) vd_$mem_fail() ;

	/*
	 * Now get leaves.
	 */
	*count = 0 ;
	sts = VD__getLeavesOfOwnerCmpGraph( msg, target, count, leaves ) ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *leaves ) ; *leaves = NULL ; *count = 0 ;
		}
		return sts ;

} /* VD_getLeavesOfOwnerCmpGraph */
/*----------------------------------------------------------------------------*/
