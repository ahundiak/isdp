/*
	I/STRUCT
*/ 
class implementation VSplate ;

#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method ACgive_path(	int		*rc ;
			struct GRid	*idOfOutput ;
			char		*nameOfOutput ; ) {

	long		msg,		/* Completion code	*/
			sts ;		/* OM return code	*/
	VSdspRep	myRep ;		/* My representation	*/

	/*
	 * If we are in 2D and the id of the foot whose name is wanted is
	 * that of our component (which is a surface), we return "plate:base"
	 * instead of "plate", so that when we have moved to 3D, we get
	 * an ACreturn_foot message with "plate:base" and then return the
	 * base surface of our component solid ( whose foot name is "plate" ),
	 * instead of the component solid itself.
	 */
	*nameOfOutput	= '\0' ;
	*rc		= FALSE ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;
	if( myRep & AC_2D_REP ) {
		struct GRid	graphicCmp ;

		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						&msg, VS_K_plGrCmpName,
						&graphicCmp, NULL, NULL ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup ) ;

		if( IF_EQ_GRID( *idOfOutput, graphicCmp ) ) {
			strcpy( nameOfOutput, VS_K_plBotSfPath ) ;
			*rc = TRUE ;
		}
	}

	if( !*nameOfOutput ) {
		/*
		 * Let ancestor class's method do the job.
		 */
		sts = om$send(	msg	= message VSfeature.ACgive_path(
						rc, idOfOutput, nameOfOutput ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}
	wrapup :
		return sts ;

} /* method ACgive_path */
/*----------------------------------------------------------------------------*/
 
end implementation VSplate ;

