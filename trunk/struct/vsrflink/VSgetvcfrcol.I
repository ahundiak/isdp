/*
	I/STRUCT
*/
class implementation ACrg_collect ;

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
/*----------------------------------------------------------------------------*/
long VSgetVectorFrColl( msg, collId, xName, yName, zName, vector )

long		*msg ;
struct GRid	*collId ;
GRname		xName,
		yName,
		zName ;
IGRvector	vector ; {

	long			sts ;
	char			*names[3] ;
	int			i,
				index ;		/* For ACgive_structure	*/
	struct ret_struct	rs ;		/* For ACgive_structure	*/
	struct GRmd_env		collEnv ;	/* Probably not used ...*/

	names[0] = xName ;
	names[1] = yName ;
	names[2] = zName ;
	MAidmx( msg, collEnv._MATRIX ) ; collEnv._MATRIX_TYPE = MAIDMX ;
	collEnv._MD_ID	= NULL_OBJID ;
	collEnv._MD_OS	= collId->osnum ;

	for( i = 0 ; i < 3 ; i++ ) {
		index = -1 ;

		sts = om$send(	msg	= message NDmacro.ACgive_structure(
						(int *) msg, &index, names[i],
						&rs, &collEnv ),
				senderid= NULL_OBJID,
				targetid= collId->objid,
				targetos= collId->osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACgive_structure", wrapup ) ;

		vector[i] = rs.var.root_pm_st.value ;
	}

	*msg	= MSSUCC ;
	sts 	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSgetVectorFrColl */
/*----------------------------------------------------------------------------*/

end implementation ACrg_collect ;

