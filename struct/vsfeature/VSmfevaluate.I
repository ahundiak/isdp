/*
	I/STRUCT
*/ 
class implementation VSmodFeature ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method VSevaluate(	long			*msg ;
			int			count ;
			struct GRid		list[] ;
			struct GRmd_env		*myEnv ;
			short			level ;
			struct IGRdisplay	*display )  {

	int			sts ;		/* OM return code	*/
        struct GRsymbology	mySymb ;	/* My symbology		*/
        VSdspRep		myRep ;		/* My representation	*/
	struct GRid		virtual ;
	struct GRmd_env		env ;

	/*
	 * Beware that parent may be a pretend which does not
	 * understand messages "GRvg.GRgetsymb" and "ACncpx.ACget_NV_rep":
	 * retrieve feature pointed to by pretend.
	 */
	sts = VSgetVirtualInfo( msg, list + VS_K_ConsumedIx,
				&env, &virtual ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	/*
	 * Take parent-to-be-consumed's symbology (it is at index 0).
	 * Do it before VSevaluate which needs a symbology to construct feet.
	 */
	if( !display ) {
		sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb),
				targetid= virtual.objid,
				targetos= virtual.osnum ) ;
		__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;
	
		sts = om$send(	msg	= message GRvg.GRputsymb( msg, &mySymb),
				targetid= my_id,
				mode	= OM_e_wrt_message ) ;
		__CheckRC( sts, *msg, "GRvg.GRputsymb", wrapup ) ;

		display	= &mySymb.display_attr ;
		level	= mySymb.level ;
	}

	/*
	 * Transfer representation as well.
	 */
	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= virtual.objid,
			targetos= virtual.osnum ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	/*
	 * Use wrt message or it will bubble up!
	 */
	sts = om$send(	msg	= message ACncpx.ACput_NV_rep( myRep ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	sts = om$send(	msg	= message VSfeature.VSevaluate(
							msg,
							count,
							list,
							myEnv,
							level,
							display ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

        wrapup :
                return sts ;

} /* method VSevaluate */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;

