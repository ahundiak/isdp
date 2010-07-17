/*
	I/STRUCT
*/
class implementation VSshellExp ;

#include <stdio.h>
#include "nddef.h"
#include "msdef.h"
#include "vsshexpdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method VSget_baseline_point( long		*msg ;
			     struct GRmd_env	*myEnv ;
			     double		*baseline )
{
	long			sts ;	 /* OM return code.		      */
	int			count ;  /* Count of parents.		      */
	struct GRid		ASbaln ; /* Baseline plane parent.	      */
	struct GRobj_env	GRbaln ; /* Graphic of the above parent.      */
	struct IGRplane 	plane ;  /* Plane definition.		      */
	double			plNm[3] ;/* Plane normal.		      */

	SetProc( VSshellExp_VSget_baseline_point ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "VSget_baseline_point" //, argfmt = "", args = ``
        );

	VSzerovc( baseline ) ;

	/*
	 * See if we have a 'baseline' plane parent.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
								NULL,
								0,
								NULL,
								0,
								OM_K_MAXINT,
								&count ),
		       targetid = my_id ) ;

	*msg = sts & 1 ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

	__DBGpr_int( "Count of parents", count ) ;

	/*
	 * Get point of 'baseline' plane parent if any.
	 */
	if( me->flagAttr & VS_K_sxUseYTranslation ) count -= 1 ;
	if( count == 2 || count == 4 ) {

		sts = om$send( msg	= message NDnode.NDget_objects(ND_ROOT,
								       &ASbaln,
								       1,
								       NULL,
								       1,
								       1,
								       &count ),
			       targetid = my_id ) ;

		*msg = sts & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

		sts = VSgetVirtualInfo( msg,
					&ASbaln,
					&GRbaln.mod_env,
					&GRbaln._grid ) ;

		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		__DBGpr_obj( "Baseline plane", GRbaln._grid ) ;

		VSmulmx( myEnv->_MATRIX, GRbaln._matrix, GRbaln._matrix,
			 &GRbaln._matrix_type ) ;

		plane.normal = plNm ;
		plane.point  = baseline ;

		sts = om$send( msg	= message GRvg.GRdetplane(
							   msg,
							   &GRbaln._matrix_type,
							   GRbaln._matrix,
							   &plane ),
			       targetid = GRbaln._objid,
			       targetos = GRbaln._osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;

		__DBGpr_vec( "Baseline point", baseline ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :

        __exitMethod ( name = "VSget_baseline_point", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End
		return sts ;

} /* VSget_baseline_point */
/*----------------------------------------------------------------------------*/

end implementation VSshellExp ;
