/*
	I/STRUCT
*/
class implementation VSstfBeam ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRconstruct( struct GRvg_construct *cl ) {

	long			sts ;		/* OM return code	*/
	struct VScnst_list	*vsargs ;
	VSstfnrAttr		*stfnr ;

	/*
	 * Dereference pointers to set on-which-side flag then call ancestor's
	 * construct method.
	 */
	vsargs	= (struct VScnst_list	*) cl->class_attr ;
	stfnr	= (VSstfnrAttr		*) vsargs->feature_att ;

	sts = om$send(	msg	= message VSstfBeam.VSputPlateSide(
					cl->msg, stfnr->onWhichSideOfPlate ),
			targetid= my_id ) ;
	__CheckRC( sts, *cl->msg, "VSstfBeam.VSputPlateSide", wrapup ) ;

	sts = om$send(	msg	= message VSstfBeam.VSputConstructionType(
						cl->msg, stfnr->constructType ),
			targetid= my_id ) ;
	__CheckRC( sts, *cl->msg, "VSstfBeam.VSputConstructionType", wrapup ) ;


	/*
	 * Modify referencing to invoke source beam's GRconstruct.
	 */
	vsargs->feature_att = (char *) &stfnr->attr ;
	sts = om$send(	msg	= message VSsrcBeam.GRconstruct( cl ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	/*
	 * Reset reference.
	 */
 	vsargs->feature_att = (char *) stfnr ;
 
	wrapup :
		return sts ;

} /* method GRconstruct */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ;

