/*
	I/STRUCT
*/
class implementation VSfrzBeam ;

#include <string.h>
#include "vsRDBdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define EQ_STRING( s1, s2 ) !strcmp( (s1), (s2) )
/*----------------------------------------------------------------------------*/
method	ACgive_structure(	int			*ok,
							*notUsed ;
				char			*attrName ;
				struct ret_struct	*attrVal ;
				struct GRmd_env		*myEnv ) {

	long			sts ;		/* OM completion code	*/

	*ok	= TRUE ;
	sts	= OM_S_SUCCESS ;

	if( EQ_STRING( attrName, VS_K_prMbrGeoAttr ) ) {

		attrVal->type			= double_type ;
		attrVal->var.root_pm_st.value	= me->geomType ;

	} else {
		/*
		 * Use ancestor class's message to do the job.
		 */
		sts = om$send(	msg	= message VSsrcBeam.ACgive_structure(
							ok, notUsed, attrName,
							attrVal, myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__CheckRC( sts, *ok, "VSsrcBeam.ACgive_structure", wrapup ) ;
	}		

	wrapup :
		return sts ;

} /* method ACgive_structure */
/*----------------------------------------------------------------------------*/

end implementation VSfrzBeam ;

