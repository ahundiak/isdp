/*
	I/STRUCT

	This function is interfaced by macro vs$extract_parms_from_RDB.
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "gr.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsRDBdef.h"
#include "vsRISmacros.h"
#include "vsRDBmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
#include "vsRDBproto.h"

extern long	VSgetCmpPrflParms() ;
/*----------------------------------------------------------------------------*/
long VSextractParmsFromRDB( msg, errStr, family, material, part,
					p_count, p_names, p_values )

long	*msg ;
char	*errStr,
	*material,
	*family,
	*part,
	***p_names ;
int	*p_count ;
double	**p_values ; {

	long	sts ;
	OMuword	actOs ;
	int	pmCount = 0 ;
	char	*pmName[VS_K_MAX_PARMS] ;
	double	pmValue[VS_K_MAX_PARMS] ;

	*p_count	= 0 ;
	*p_values	= NULL ;
	*p_names	= NULL ;
	if( errStr ) *errStr = '\0' ;

	if( *family == '#' ) {
		ex$get_cur_mod( osnum = &actOs ) ;
		sts = VSgetCmpPrflParms( msg, actOs, material, family,
					part, p_count, p_names, p_values ) ;

		if( !( sts & 1 & *msg ) ) {

			*msg = MSFAIL ;
			if( errStr ) {
				ex$message(	msgnumb	= VS_gW_CantGetPrflPms,
						type	= "%s%s",
						var	= `family,part`,
						buff	= errStr ) ;
			}
					 
			goto wrapup ;
		} else {
			*msg = MSSUCC ;
			/*
			 * Skip RIS.
			 */
			goto wrapup ;
		}
	}

	vs$extractParameters(	msg	= msg,
				errStr	= errStr,
				family	= family,
				material= material,
				part	= part,
				size	= VS_K_MAX_PARMS,
				p_count	= &pmCount,
				pmNames	= pmName,
				pmValues= pmValue ) ;
	if( !( *msg & 1 ) || !pmCount ) { *msg = MSFAIL ; goto wrapup ; }

	VScopyList( msg, pmName, pmCount, p_names ) ;
	*p_values = (double *) VSmemdup( pmValue, pmCount * sizeof( double ) ) ;

	if( !( *p_names && *p_values ) ) {
		*msg = EMS_E_NoDynamicMemory ;
		goto wrapup ;
	}
	*p_count = pmCount ;
	*msg = MSSUCC ;

	wrapup :
		if( !( *msg & 1 ) ) {
			_FREE( *p_values ) ; *p_values = NULL ;
			VSfreeList( pmCount, *p_names ) ; *p_names = NULL ;
		}

		return *msg & 1 ;

} /* VSextractParmsFromRDB */
/*----------------------------------------------------------------------------*/

