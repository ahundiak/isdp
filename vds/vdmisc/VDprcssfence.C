/*
	I/VDS	Copy
*/
#include <stdio.h>
#include <stdlib.h>
#include "EMSmsgdef.h"
#include "v_globalmsg.h"
#include "v_cmd.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "dp.h"
#include "dpmacros.h"
/*
 * Include of function prototypes.
 */
#include "GRgettoken.h"
#include "v_strngproto.h"
/*----------------------------------------------------------------------------*/
int VD_process_fence( msg, fence, keepOSes, OScount,
			keepClasses, filter, args, p_count, p_content,
			response, response_data )

/*
 * This function interfaced by macro vd_$process_fence.
 */

long			*msg ;
struct GRobj_env	*fence ;
OMuword			keepOSes[] ;
int			OScount,
			*p_count ;
OM_S_CLASSLIST		keepClasses[] ;
int			(*filter) __((	struct GRobj_env *object,
					VD_fenceArgs	 *args )) ;
VD_fenceArgs		*args ;
struct GRobj_env	**p_content ;
int			*response ;
char			*response_data ; {

	int			rejectedCount	= 0 ;
	struct GRobj_env	*rejectedSet	= NULL ;
	
	extern	OMuword		OPP_GRgrset_class_id ;

	if( vd_$is_ancestry_valid(	object	= &fence->_grid,
					classid	= OPP_GRgrset_class_id ) ) {

		struct GRevent event ;
		int	mask = GRm_DATA | GRm_RJT_MOVEON | GRm_MOVE_ON,
			size = sizeof event,
			tokenList[3] ;

		tokenList[0] = EX_DATA ;
		tokenList[1] = EX_RJT_MOVEON ; 
		tokenList[2] = GR_UNKNOWN_TYPE ;

		vd_$get_gs_content(	msg		= msg,
					gs		= &fence->_grid,
					spaceList	= keepOSes,
					spaceCount	= OScount,
					classList	= keepClasses,
					filter		= filter,
					args		= args,
					p_count		= p_count,
					p_content	= p_content,
					p_notCount	= &rejectedCount,
					p_notKeep	= &rejectedSet ) ;
					
		/*
		 * Highlight content.
		 */
		vd_$bulk_display( count  = *p_count,
				 dpmode = GRhd,
		 		 objenvs= *p_content ) ;
		 		 
		_FREE( rejectedSet ) ;

		if( *p_count ) {
/**
			ex$message( msgnumb = VD_gP_AccFenRej ) ;
 **/
			UI_prompt("Accept fence content/Reject" );

			GRget_token(	msg,
					tokenList,
					&mask,
					&event,
					&size,
					response,
					response_data ) ;

			if( *response != EX_DATA ) {
				/*
				 * Fence rejected.
				 */
				*p_count	= 0 ;
				*p_content	= NULL ;
				*msg		= MSSUCC ;
			}
			dp$erase_hilite( msg = msg ) ;
		} else {
			*p_count	= 0 ;
			*p_content	= NULL ;
			*msg		= MSSUCC ;
		}
	} else {
		/*
		 * Not a fence : return object, filter it anyway.
		 * It is taken advantage of the fact that
		 *		vd_$is_object_of_classes
		 * and		vd_$is_osnum_in_list
		 * are TRUE when the class list and the osnum list are not
		 * specified.
		 */
		if(    vd_$is_object_of_classes(
					objid		= fence->_objid,
					osnum		= fence->_osnum,
					classList	= keepClasses )
		    && vd_$is_osnum_in_list(
			 		osnum		= fence->_osnum,
			 		spaceCount	= OScount,
			 		spaceList	= keepOSes )
		    && ( filter ? filter( fence, args ) : TRUE ) ) {
			 *p_content = (struct GRobj_env *)
			 		VD_memdup( fence, sizeof *fence ) ;
			if( *p_content ) {
				 *p_count  = 1 ;
				 *msg      = MSSUCC ;
				 *response = EX_DATA ;
			} else {
				*p_content = NULL ;
				*p_count   = 0 ;
				*msg	   = EMS_I_Fail ;
			}
		} else {
			*p_content	= NULL ;
			*p_count	= 0 ;
			*msg		= MSSUCC ;
		}
	}
	return *msg & 1 ;

} /* VD_process_fence */
/*----------------------------------------------------------------------------*/

