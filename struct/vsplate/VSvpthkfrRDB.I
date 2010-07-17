/*
	I/STRUCT
*/ 
class implementation VSvarPlate ;

#include <string.h>
#include <stdlib.h>
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsRDBmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsRDBproto.h"
/*----------------------------------------------------------------------------*/
method VSselectThicknessFromRDB(	long	*msg ;
					double	minVal,
						*rdbVal ;
					char	*thkName ) {

	long		sts ;			/* OM return code	*/
	VSpartAttr	myAttr ;		/* My part attributes	*/
	VSplateAttr	myInfo ;		/* Some attributes	*/
	char		*thkname ;		/* Thickness name found	*/

	thkname = NULL ;
	/*
	 * Get thicknesses from Relational Data Base.
	 */
	myAttr.Iwant = VS_m_PartFam | VS_m_MatType ;
	myAttr.specific	= (void *) &myInfo ;
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	vs$find_thickness_in_RDB(	msg		= msg,
					material	= myAttr.info.material,
					family		= myAttr.info.family,
					value		= minVal,
					p_thkname	= &thkname,
					p_thickness	= rdbVal ) ;

	if( *msg & 1 ) {
		struct GRid cachedPart ;

		strcpy( thkName, thkname ) ;

		/*
		 * Must load part into model should it be a new one.
		 */
		vs$load_part_from_RDB(	msg		= msg,
					family		= myAttr.info.family,
					material	= myAttr.info.material,
					part		= thkName,
					osnum		= OM_Gw_current_OS,
					object		= &cachedPart ) ;
		__CheckRC( 1, *msg, "vs$load_part_from_RDB", wrapup ) ;
	}

	wrapup :
		_FREE( thkname ) ;
		return sts ;

} /* method VSselectThicknessFromRDB */
/*----------------------------------------------------------------------------*/

end implementation VSvarPlate ;

