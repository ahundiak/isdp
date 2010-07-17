/*
	I/STRUCT
*/
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "msdef.h"
#include "vsRDBdef.h"
#include "vsRDBmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsRDBproto.h"
/*----------------------------------------------------------------------------*/
long VSextractParameters( msg, errStr, family, material, part, size,
			  p_count, pmNames, pmValues )

/*
 * This function is interfaced by macro vs$extractParameters.
 */
long	*msg ;
char	*errStr,
	*family,
	*material,
	*part ;
int	size,
	*p_count ;
char	*pmNames[] ;
double	pmValues[] ; {


	vs$getPpartData(	msg	= msg,
				errStr	= errStr,
				family	= family,
				material= material,
				part	= part,
				size	= size,
				p_count	= p_count,
				pmNames	= pmNames,
				pmValues= pmValues ) ;
	if( !( *msg & 1 ) ) goto wrapup ;
 
	wrapup :
		return *msg & 1 ;

} /* VSextractParameters */
/*----------------------------------------------------------------------------*/
