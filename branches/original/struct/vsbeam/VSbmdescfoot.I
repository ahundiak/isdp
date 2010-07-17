/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <stdio.h>
#include <string.h>
#include "UOMdef.h"
#include "griodef.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"

%safe
extern int	VSdescribeFoot __(( long, OMuword, char*, double, char* )) ;
%endsafe
/*----------------------------------------------------------------------------*/
method VSdescribeOutput( long *msg ; char *nameOfAttr, *description ) {

	long			sts ;
	int			ACrc,
				index = -1 ;
	double			val ;
	char			unit[UOM_K_MAX_LEN],
				value[UOM_K_MAX_LEN] ;
	struct ret_struct	rs ;
	struct GRid		myGRid ;
	struct GRmd_env		myEnv ;

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	VSgetVirtualInfo( msg, &myGRid, &myEnv, NULL ) ;

	sts = om$send(	msg	= message ACcpx.ACgive_structure(
				      &ACrc, &index, nameOfAttr, &rs, &myEnv ),
			targetid= my_id ) ;
	if( !( sts & 1 & ACrc ) ) {
		strcpy( description, nameOfAttr ) ;
	} else {
		val = rs.var.root_pm_st.value ;
		VSdescribeFoot( VS_m_BEAM, OM_Gw_current_OS, nameOfAttr, val,
				unit ) ;
		if( *unit ) {
			sprintf( value, " = %g (%s)", val, unit ) ;
		} else {
			sprintf( value, " = %g", val ) ;
		}
		strcat( description, value ) ;
	}

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSdescribeOutput */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
