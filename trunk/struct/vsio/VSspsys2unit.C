/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include "OMminimum.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "msdef.h"		/* For MS...		*/
#include "UOMdef.h"
#include "griodef.h"
#include "griomacros.h"
#include "EMSmsgdef.h"
#include "vsmeasdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

extern char	*VS_Gp_UnitBuffer ;
/*----------------------------------------------------------------------------*/
static long VSgetWUcvtAndName( msg, osnum, table, WU, factor )
 
long	*msg ;
OMuword	osnum ;
char	*table,
	*WU ;
double	*factor; {

	long	sts ;
	short	onlyOne = 1 ;
	double	one ;
	char	wu[UOM_K_MAX_LEN] ;

	if( OM_K_NOT_AN_OS == osnum ) ex$get_cur_mod( osnum = &osnum ) ;

	sts = co$cvt_imp_to_wrk(	msg		= msg,
					unit_type	= table,
					osnum		= osnum,
					primary		= 1.0,
					result		= factor ) ;
	__CheckRC( sts, *msg, "co$cvt_imp_to_wrk", wrapup ) ;

	sts = co$cvt_imp_to_alias(
			msg		= msg,
			unit_type	= table,
			osnum		= osnum,
			num_alias	= &onlyOne,
			working_units	= factor,
			cvt_list	= wu ) ;
	__CheckRC( sts, *msg, "co$cvt_imp_to_alias", wrapup ) ;

	/*
	 * Isolate name of unit in string : pattern " 1 <unit> "
	 */
	sscanf( wu, "%lf %s", &one, WU ) ;

	wrapup :
		return sts ;

} /* VSgetWUcvtAndName */
/*----------------------------------------------------------------------------*/
int VSspecialSys2unit( msg, mod_os, value, table, unit )

long	*msg	;	/* OUT : completion code		*/
OMuword	mod_os	;	/* IN  : object space of UOM table	*/
double	value	;	/* IN  : system value to convert	*/
char	*table	;	/* IN  : UOM table			*/
char	**unit	; {	/* OUT : pointer to unit (static buffer)*/

	long	sts ;
	double	distFactor,		/* User dist. -> sys. dist.	*/
		massFactor ;		/* User mass  -> sys. mass	*/
	char	distUnit[UOM_K_MAX_LEN],
		massUnit[UOM_K_MAX_LEN] ;
	char	Unit[UOM_K_MAX_LEN] ;	/* Buffer for converted value	*/

	*unit = NULL ;

	sts = VSgetWUcvtAndName( msg, mod_os, GRIO_DISTANCE,
				 distUnit, &distFactor ) ;
	__CheckRC( sts, *msg, "VSgetWUcvtAndName", wrapup ) ;

	sts = VSgetWUcvtAndName( msg, mod_os, VS_K_uomMASS,
				 massUnit, &massFactor ) ;
	__CheckRC( sts, *msg, "VSgetWUcvtAndName", wrapup ) ;

	if( !strcmp( table, VS_K_uomVOLUMETRIC_MASS ) ) {

		value /= distFactor * distFactor * distFactor / massFactor ;
		sprintf( Unit, "%g %s**3/%s", value, distUnit, massUnit ) ;

	} else if( !strcmp( table, VS_K_uomMOMENT_OF_INERTIA ) ) {

		value /= massFactor * distFactor * distFactor ;
		sprintf( Unit, "%g %s %s**2", value, massUnit, distUnit ) ;

	} else if( !strcmp( table, VS_K_uomVOLUME ) ) {

		value /= distFactor * distFactor * distFactor ;
		sprintf( Unit, "%g %s**3", value, distUnit ) ;

	} else {
		*msg	= MSFAIL ; sts = OM_W_ABORT ;
		goto wrapup ;
	}

	*unit = strcpy( VS_Gp_UnitBuffer, Unit ) ;

	wrapup :
		return sts ;

} /* VSspecialSys2unit */
/*----------------------------------------------------------------------------*/

