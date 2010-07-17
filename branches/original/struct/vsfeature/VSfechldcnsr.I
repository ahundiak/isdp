/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "OMmacros.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

extern OMuword		OPP_ACpretend_class_id,
			OPP_VSfeature_class_id ;
/*----------------------------------------------------------------------------*/
method VSisChildConsumingMe(	long		*msg ;
				struct GRid	*child ;
				int		*consuming ;
				struct GRid	*virtChild ) {

	/*
	 * NOTE: this message assumes
	 * 1) That `*child' is really one of my children.
	 * 2) That I am consumed.
	 *
	 * We handle the case when the child is a pretend, which happens
	 * when I am in one design file and child in another design file
	 * (associativity across reference files) or if I am in a macro
	 * and child is not. A child is said to be VIRTUAL if it is linked
	 * to me via an ACpretend or ACpretendin object. Hence the 3 following
	 * cases:
	 *
	 * a) me -child-> <-parent- child
	 * b) me -child-> <-parent- ACpretend -child-> <-parent- child
	 * c) me -notification-> <-listener- ACpretendin -child-> <-parent- child
	 */

	long		sts ;
	struct GRid	*p_virtList,	/* Pointer to virtual children	*/
			*list ;
	int		i,		/* Loop index			*/
			count,		/* Count of virtual children	*/
			checkTypes ;	/* Must further check types ?	*/
	unsigned long	myType,		/* My feature type		*/
			chType ;	/* Some child's type		*/

	p_virtList	 = NULL ;
	virtChild->objid = NULL_OBJID ;
	list		 = NULL ;

	/*
	 * Is child a VSfeature ?
	 */
	if( vs$is_ancestry_valid(	object	= child,
					classid	= OPP_VSfeature_class_id ) ) {
		/*
		 * Make virtual list point to REAL child.
		 */
		p_virtList	= child ;
		count		= 1 ;
		checkTypes	= TRUE ;

	} else if( vs$is_ancestry_valid(object	= child,
					classid	= OPP_ACpretend_class_id ) ) {
		/*
		 * Then get pretend's children.
		 */
		struct GRid	*buffer ;

		sts = om$send(	msg	= message NDnode.NDget_objects(
						ND_CHILDREN | ND_IN_BUF,
						NULL,
						0,
						&buffer,
						/* from = */ 0,
						/* to   = */ OM_K_MAXINT,
						&count ),
				targetid= child->objid,
				targetos= child->osnum ) ;	
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

		if( count ) {
			list = (struct GRid *) VSmemdup( buffer,
						 count * sizeof *buffer ) ;

			if( !list ) vs$mem_fail() ;

		}

		/*
		 * Are pretend's children VSfeatures ?
		 */
		checkTypes	= FALSE ;

		for( i = 0 ; i < count ; i++ ) {
			if( vs$is_ancestry_valid(	
					object	= list + i,
					classid	= OPP_VSfeature_class_id ) ) {

				/*
				 * Got a candidate ...
				 */
				checkTypes = TRUE ;
			} else {
				/*
				 * Not a candidate: flag it.
				 */
				list[i].objid = NULL_OBJID ;
			}
		}
		if( checkTypes ) p_virtList = list ;
	} else {
		/*
		 * Some other non-important child.
		 */
		checkTypes = FALSE ;
	}

	if( !checkTypes ) {
		*consuming = FALSE ; *msg = MSSUCC ; sts = OM_S_SUCCESS ;
		goto wrapup ;
	}

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &myType ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

	*consuming = FALSE ;
	for( i = 0 ; i < count ; i++ ) {

		if( IF_NULL_OBJID( p_virtList[i].objid ) ) continue ;

		sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &chType ),
				targetid= p_virtList[i].objid,
				targetos= p_virtList[i].osnum ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

		if(    ( myType & VS_m_PLATE ) && ( chType & VS_m_PLATE )
		    || ( myType & VS_m_BEAM  ) && ( chType & VS_m_BEAM  ) ) {
		    	if( ( chType & VS_m_MOD_generic )
		    	||  ( chType & VS_m_SUB_generic ) == VS_m_SUB_generic ) {
		    		/*
		    		 * This child is consuming me, since there may
		    		 * only be one, this is it.
		    		 */
		    		*consuming = TRUE ;
				*virtChild = p_virtList[i] ;
				break ;
		    	}
		}
	} /* for */

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( list ) ;
		return sts ;

} /* method VSisChildConsumingMe */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

