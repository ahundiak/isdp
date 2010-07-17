/*
	I/STRUCT
*/
class implementation VSxtrBeam ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRconstruct( struct GRvg_construct *cst ) {

	long			sts ;
	struct VScnst_list	*vsargs ;

	vsargs = (struct VScnst_list *) cst->class_attr ;

	*cst->msg	= MSINARG ;
	sts		= OM_W_ABORT ;

	if( vsargs ) {
		int	*p_extEnd = (int *) vsargs->feature_att ;

		if( p_extEnd ) me->extEnd = *p_extEnd ;

		if( me->extEnd == 0 || me->extEnd == 1 ) {
			char *saveAttr = vsargs->feature_att ;

			vsargs->feature_att = NULL ;

			sts = om$send(	msg	= message VSfeature.GRconstruct(
									cst ),
					mode	= OM_e_wrt_message,
					targetid= my_id ) ;

			vsargs->feature_att = saveAttr ;			
		}
	}

	return sts ;

} /* method GRconstruct */
/*----------------------------------------------------------------------------*/

end implementation VSxtrBeam ;

