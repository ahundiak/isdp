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
method VSget_limiting_points( long		*msg ;
			      struct GRmd_env	*myEnv ;
			      double		*beginPoint,
						*endPoint )
{
	long			sts ;	 /* OM return code.		      */
	int			i,	 /* Loop index. 		      */
				count ;  /* Count of parents.		      */
	struct GRid		ASbegin, /* Begin plane parent. 	      */
				ASend ;  /* End plane parent.		      */
	struct GRobj_env	GRbegin, /* Graphic of the begin plane parent.*/
				GRend ;  /* Graphic of the end plane parent.  */
	struct IGRplane 	plane ;  /* Plane definition.		      */
	double			plNm[3] ;/* Plane normal.		      */

	SetProc( VSshellExp_VSget_limiting_points ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "VSget_limiting_points" //, argfmt = "", args = ``
        );

	for( i=0; i<3; i++ ) {
		beginPoint[i] = IGE_DESIGN_LIMITS_MIN ;
		endPoint[i]   = IGE_DESIGN_LIMITS_MAX ;
	}

	/*
	 * See if we have a 'begin' and 'end' planes parent.
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
	 * Get point of 'begin' and 'end' planes parent if any.
	 */
	if( me->flagAttr & VS_K_sxUseYTranslation ) count -= 1 ;
	if( count > 2 ) {
		int	tmp ;

		/*
		 * Begin point.
		 */
		sts = om$send( msg	= message NDnode.NDget_objects(ND_ROOT,
								       &ASbegin,
								       1,
								       NULL,
								       count-2,
								       count-2,
								       &tmp ),
			       targetid = my_id ) ;

		*msg = sts & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

		sts = VSgetVirtualInfo( msg,
					&ASbegin,
					&GRbegin.mod_env,
					&GRbegin._grid ) ;

		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		__DBGpr_obj( "Begin plane", GRbegin._grid ) ;

		VSmulmx( myEnv->_MATRIX, GRbegin._matrix, GRbegin._matrix,
			 &GRbegin._matrix_type ) ;

		plane.normal = plNm ;
		plane.point  = beginPoint ;

		sts = om$send( msg	= message GRvg.GRdetplane(
							  msg,
							  &GRbegin._matrix_type,
							  GRbegin._matrix,
							  &plane ),
			       targetid = GRbegin._objid,
			       targetos = GRbegin._osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;

		__DBGpr_vec( "Begin point", beginPoint ) ;

		/*
		 * End point.
		 */
		sts = om$send( msg	= message NDnode.NDget_objects(ND_ROOT,
								       &ASend,
								       1,
								       NULL,
								       count-1,
								       count-1,
								       &tmp ),
			       targetid = my_id ) ;

		*msg = sts & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

		sts = VSgetVirtualInfo( msg,
					&ASend,
					&GRend.mod_env,
					&GRend._grid ) ;

		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		__DBGpr_obj( "End plane", GRend._grid ) ;

		VSmulmx( myEnv->_MATRIX, GRend._matrix, GRend._matrix,
			 &GRend._matrix_type ) ;

		plane.normal = plNm ;
		plane.point  = endPoint ;

		sts = om$send( msg	= message GRvg.GRdetplane(
							    msg,
							    &GRend._matrix_type,
							    GRend._matrix,
							    &plane ),
			       targetid = GRend._objid,
			       targetos = GRend._osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;

		__DBGpr_vec( "End point", endPoint ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :

        __exitMethod ( name = "VSget_limiting_points", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End
		return sts ;

} /* VSget_limiting_points */
/*----------------------------------------------------------------------------*/

end implementation VSshellExp ;
