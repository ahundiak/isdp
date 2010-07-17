/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsophstproto.h"
/*----------------------------------------------------------------------------*/
method VSgetOperationHistory(	long		*msg ;
				struct GRmd_env	*myEnv ;
				VSopHistory	**p_history ; ) {

	long			sts,		/* OM return code	*/
				notUsed ;	/* Self-explanatory	*/
	VSopHistory		history ;

	history.next = NULL ;

	*msg = MSSUCC ;
	sts = om$send(	msg 	= message ACncpx.ACbubble_up(
				&notUsed,
				"",
				VS_K_ConsumedIx,
				message VSfeature.VSisOriginal(
							TRUE,
							VS_K_READ_OMmsg ),
				message VSfeature.VSgetOperation(msg, &history),
				OM_e_wrt_object ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "ACncpx.ACbubble_up( VSgetOperation )", wrapup ) ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			VSfreeOpHistory( history.next ) ;
			*p_history = NULL ;
		} else {
			/*
			 * If I am an output of a macro, ACbubble_up will have
			 * been sent to my counterpart in the macro definition,
			 * hence the id of my counterpart will be in the
			 * history: I have to put myself there instead.
			 */
			unsigned long		resType ;

			om$send(msg	= message VSfeature.VSgetResultType(
								msg, &resType ),
				targetid= my_id ) ;
			if( resType & VS_m_IN_ASSEMBLY ) {

				VSopHistory	*next = history.next,
						*prev = NULL ;

				while( next ) {
					prev = next ;
					next = next->next ;
				}

				prev->resultId = my_id ;
				prev->resultOs = OM_Gw_current_OS ;
				prev->resultEnv= *myEnv ;
				prev->resultType =   prev->resultType
						   & ~VS_m_IN_DEFINITION
						   | VS_m_IN_OCCURRENCE ;
			}
			*p_history = history.next ;
		}
		return sts ;

} /* method VSgetOperationHistory */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
