/*
	I/STRUCT
	This function is interfaced by macro vs$extract_plates_from_RDB.
*/
#include <stdio.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "gr.h"
#include "vsglobalmsg.h"
#include "vsRDBdef.h"
#include "vsRISmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsRDBproto.h"
/*----------------------------------------------------------------------------*/
long VSextractPlatesFromRDB( msg, errStr, material, p_count, p_plates )

long	*msg ;
char	*errStr,
	*material,
	***p_plates ;
int	*p_count ; {

	long	sts ;
	char	searchCriteria[VS_K_MAX_CHARS],
		**plist	= NULL ;
	int	pcount	= 0 ;

	*p_count	= 0 ;
	*p_plates	= NULL ;
	if( errStr ) *errStr = '\0' ;

	/*
	 * SELECT	n_itemrev
	 * FROM		mat_and_fam
	 * WHERE		n_itemname	= '<material>'
	 *		AND	vs_type		= 'plate'
	 */
	sprintf(	searchCriteria,
			"%s='%s' AND %s='%s'",
			PDU_PARTID_ATTR,
			material,
			VS_K_PDM_vstypeAttr,
			VS_K_PDM_plateType ) ;

	sts = vs$RISquery(	table	= VS_K_PDM_matAndFamCat,
				select	= PDU_REVISION_ATTR,
				where	= searchCriteria,
				p_count	= &pcount,
				p_list	= &plist ) ;

	if( !sts ) {
		*msg		= MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_QyPltFailed,
					type	= "%s",
					var	= `material`,
					buff	= errStr ) ;
		}
	} else {
		*p_count	= pcount ;
		*p_plates	= plist ;
		*msg		= MSSUCC ;
	}

	return *msg & 1 ;

} /* VSextractPlatesFromRDB */
/*----------------------------------------------------------------------------*/

