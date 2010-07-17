/*
	I/STRUCT
*/
class implementation VSgapDtector ;

#include <stdio.h>
#include <string.h>
#include "UOMdef.h"
#include "griodef.h"
#include "vsiomacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method VSdescribeOutput( long *msg ; char *nameOfOutput, *description ) {

	long			sts ;
	int			rc,
				index = -1 ;
	struct ret_struct	rs ;
	struct GRid		myGRid ;
	struct GRmd_env		myEnv ;

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	VSgetVirtualInfo( msg, &myGRid, &myEnv, NULL ) ;

	sts = om$send(	msg	= message ACcpx.ACgive_structure(
			 	      &rc, &index, nameOfOutput, &rs, &myEnv ),
			targetid= my_id ) ;
	if( !( sts & 1 & rc ) ) {
		strcpy( description, nameOfOutput ) ;
	} else {
		char	*unit ;
		char	value[UOM_K_MAX_LEN] ;

		vs$system_to_unit(	msg	= msg,
					value	= rs.var.root_pm_st.value,
					type	= GRIO_DISTANCE,
					osnum	= OM_Gw_current_OS,
					p_unit	= &unit ) ;

		sprintf( value, " = %g (%s)", rs.var.root_pm_st.value, unit ) ;
		strcat( description, value ) ;
	}

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSdescribeOutput */
/*----------------------------------------------------------------------------*/

end implementation VSgapDtector ;
