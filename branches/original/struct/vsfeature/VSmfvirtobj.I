/*
	I/STRUCT
*/
class implementation VSmodFeature ;

#include <stdlib.h>
#include "OMmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "nddef.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

extern struct GRid 	*NDrealloc_object_buffer() ;
/*----------------------------------------------------------------------------*/
method NDget_virtual_objects(	int		type ;
				struct GRid	*list;
				int		size ;
				struct GRid	**buffer ;
				int		ifrom,
						ito,
						*count,
						*vCount ) {

	long		sts ;		/* OM return code		*/
	struct GRid	*myParents,	/* List of my parents		*/
			*hisChildren,	/* Children of parent #0	*/
			*vList = NULL ;	/* List of virtual parents	*/
	int		i, j,		/* Loop index			*/
			hisCount,	/* Of parent 0's children	*/
			myCount,	/* Of parents			*/
			iv,		/* Loop-on-virtual parents index*/
			vSize = 0 ;	/* Size of vList		*/

	myParents = NULL ; hisChildren = NULL ;
	
	*vCount	= 0;

	if( type & ND_CHILDREN ) {
		/*
		 * Evacuate this case first.
		 */
		sts = om$send(	msg	= message ACncpx.NDget_virtual_objects(
 									type,
									list,
                	                				size,
                        	        				buffer,
                                					ifrom,
                                					ito,
        								count,
        								vCount),
        			targetid= my_id,
        			mode	= OM_e_wrt_message ) ;
        	goto wrapup ;
        }

	if( !( type & ND_ROOT ) ) { sts = OM_E_INVARG ; goto wrapup ; }

	/*
	 * Get parents, start at 0 since we need this one later.
	 */
	sts = om$send(	msg	= message NDnode.NDget_objects( type,
								NULL,
                	                			0,
                        	        			&myParents,
                                				0,
                                				ito,
                                				&myCount ),
			targetid = my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	if( !myCount ) {
		/*
		 * I have no parents...
		 */
		 sts = OM_S_SUCCESS ; goto wrapup ;
	}

	/* So here parents are wanted and we have parents.
	 * Add consumed parent's children (don't forget to remove
	 * yourself from list !).
	 */
	myParents = (struct GRid *) VSmemdup(	myParents,
						myCount * sizeof *myParents ) ;

	if( !myParents ) { sts = OM_E_NODYNMEM ; goto wrapup ; }

	sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_CHILDREN | ND_IN_BUF,
							NULL,
                	               			0,
                                			&hisChildren,
                               				0,
                               				OM_K_MAXINT,
                               				&hisCount ),
		targetid = myParents[0].objid,
		targetos = myParents[0].osnum ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	hisChildren = (struct GRid *) VSmemdup(	hisChildren,
						hisCount * sizeof *hisChildren ) ;
	if( !hisChildren ) { sts = OM_E_NODYNMEM ; goto wrapup ; }

	/*
	 * Since I am a child of my parent, I remove myself from the
	 * list. Note : hisCount >= 1.
	 */
	for( i = j = 0 ; j < hisCount ; ) {
		if(    IF_EQ_OBJID( my_id, hisChildren[j].objid )
		    && OM_Gw_current_OS == hisChildren[j].osnum ) {

		    	j++ ;
		} else {
			hisChildren[i++] = hisChildren[j++] ;
		}
	}
	*count = myCount ;
	*vCount = *count + hisCount - 1 ;

	if( type & ND_IN_BUF ) {
		/*
		 * Return virtual parents using cache buffer.
		 */

		vSize = *vCount ;
		*buffer = NDrealloc_object_buffer( vSize ) ;
		if( !*buffer ) {
			sts = OM_E_NODYNMEM ; goto wrapup ;
		} else {
			vList = *buffer ;
		}	
	} else {
		if( !vSize || !vList ) {
			/*
			 * Caller just want the counts.
			 */
			 goto wrapup ;
		} else {
			/*
			 * Return virtual parents in input array.
			 */
			vSize = size ;
			vList = list ;
		}
	}

	/*
	 * Copy parents from `ifrom' to `ito'.
	 */
	for( iv = 0, i = ifrom ; i < *count && iv < vSize ; i++, iv++ ) {
		vList[iv] = myParents[i] ;
	}
	/*
	 * Copy parent 0's children if they fit in index range.
	 */
	for( i = 0 ; iv <= ito && iv < vSize && i < hisCount - 1 ; i++, iv++ ) {
		vList[iv] = hisChildren[i] ;
	}

	sts = OM_S_SUCCESS ;

	wrapup :
		_FREE( myParents ) ;
		_FREE( hisChildren ) ;
		return sts ;

} /* method NDget_virtual_objects */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;
