/*
	I/STRUCT
*/
class implementation VSplate ;

#include <stdio.h>
#include <string.h>
#include "DImacros.h"
#include "msdef.h"
#include "EMSutlmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"
/*----------------------------------------------------------------------------*/
method VStransIPATHToName(	long		*msg ;
				VSixPath	*ipath ;
				GRname		name ) {

	long			sts ;		/* OM return code	*/
	int			count ;
	VSobjDef		myDef ;		/* My object definition	*/
	int			map[2] ;
	GRname			cmpNames[2] ;
	struct GRid		myOutput ;

	/*
	 * Path is in the form: { n1, n2 }
	 * Get name of output at index n1 = ipath[0].
	 */
	sts = om$send(	msg	= message VScpx.VSgetObjDef( msg, &myDef ),
			targetid= my_id ) ;
	strcpy( name, myDef.output.names[ipath->ls[0]] ) ;

	switch( ipath->sz ) {
	case 1	: goto wrapup ;
	case 2	:
	sts = om$send(	msg	= message ACncpx.ACreturn_foot(
					msg, name, &myOutput, NULL, NULL ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "ACncpx.ACreturn_foot", wrapup ) ;

	{ OM_S_CHANSELECT toCmps ;
	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		       chan_selector = &toCmps ) ;

	  sts = om$get_channel_count(	objid		= myOutput.objid,
					osnum		= myOutput.osnum,
					p_chanselect	= &toCmps,
					count		= (OMuint *) &count ) ;
	  __CheckRC( sts, 1, "om$get_channel_count", wrapup ) ;
	}


	/*
	 * Now get name of component of output at index n2 = ipath[1].
	 */
	sts = om$send(	msg	= message VSplate.VStopBottomMapping(
						msg, count, map, cmpNames ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSplate.VStopBottomMapping", wrapup ) ;

	     if( ipath->ls[1] == map[0] )	DIstrcat( name, cmpNames[0] ) ;
	else if( ipath->ls[1] == map[1] )	DIstrcat( name, cmpNames[1] ) ;
	else {
		GRname dollarN ;

		VSgenCmpName( ipath->ls[1], dollarN ) ;

		DIstrcat( name, dollarN ) ;
	}
	break ;
	default	:
		sts = om$send(	msg	= message VSfeature.VStransIPATHToName(
							msg, ipath, name ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	} /* switch */

	wrapup :
		return sts ;

} /* method VStransIPATHToName */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;

