/*
	I/STRUCT
*/
class implementation VSexpandedCv ;

#include <stdio.h>
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"

/*----------------------------------------------------------------------------*/
method VSevaluate( long 		*msg ;
		   int			count ;
		   struct GRid		list[] ;
		   struct GRmd_env	*myEnv ;
		   short		level ;
		   struct IGRdisplay	*display )
{
	int			sts ;
	struct GRsymbology	mySymb ;
	struct GRid		curve ;

        __enterMethod ( name = "VSevaluate" //, argfmt = "", args = ``
        );

	/*
	 * Get my curve parent.
	 */
	sts = VSgetVirtualInfo( msg,
				list +1,
				NULL,
				&curve ) ;

	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	/*
	 * Take my curve parent's symbology.
	 */
	if( !display ) {
		sts = om$send( msg	= message GRvg.GRgetsymb( msg,
								  &mySymb ),
			       targetid = curve.objid,
			       targetos = curve.osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

		sts = om$send( msg	= message GRvg.GRputsymb( msg,
								  &mySymb ),
			       mode	= OM_e_wrt_message,
			       targetid = my_id ) ;

		__CheckRC( sts, *msg, "GRvg.GRputsymb", wrapup ) ;

		display = &mySymb.display_attr ;
		level	= mySymb.level ;
	}

	/*
	 * Evaluate myself.
	 */
	sts = om$send( msg	= message VShelper.VSevaluate( msg,
							       count,
							       list,
							       myEnv,
							       level,
							       display ),
		       mode	= OM_e_wrt_message,
		       targetid = my_id ) ;

	wrapup :

        __exitMethod ( name = "VSevaluate", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		return sts ;

} /* VSevaluate */
/*----------------------------------------------------------------------------*/

end implementation VSexpandedCv ;
