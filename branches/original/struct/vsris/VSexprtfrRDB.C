/*
	I/STRUCT
	This function is interfaced by macro vs$extract_parts_from_RDB.
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exmacros.h"
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
long VSextractPartsFromRDB( msg, errStr, family, material, p_count, p_parts )

long	*msg ;
char	*errStr,
	*material,
	*family,
	***p_parts ;
int	*p_count ; {

	long	sts ;

	*p_count	= 0 ;
	*p_parts	= NULL ;
	if( errStr ) *errStr = '\0' ;

	if( *family == '#' ) {

		OMuword	actOs ;
		int	cpCount	= 0 ;
		char	**cpList= NULL ;

		/*
		 * It's the family of a user-made composite profiles stored in
		 * the active file.
		 */
		ex$get_cur_mod( osnum = &actOs ) ;
		sts = VSgetCmpPrflPrtsFromDir( msg, actOs, material, family,
						 &cpCount, &cpList ) ;
		if( !( sts & 1 & *msg ) ) {
			*msg = MSFAIL ;
		} else {
			*p_count = cpCount ;
			*p_parts = cpList ;
		}
	} else {
		int	pcount	= 0 ;
		char	**plist	= NULL,
			searchCriteria[VS_K_MAX_CHARS] ;

		/*
		 * Now go for RIS !
		 * SELECT	n_itemname
		 * FROM		<family>
		 * WHERE	n_itemrev = '<material>'
		 */
		sprintf( searchCriteria, "%s='%s'",
			 PDU_REVISION_ATTR, material ) ;

		sts = vs$RISquery(	table	= family,
					select	= PDU_PARTID_ATTR,
					where	= searchCriteria,
					p_count	= &pcount,
					p_list	= &plist ) ;
		if( !sts ) {
			*msg		= MSFAIL ;
			if( errStr ) {
				ex$message(	msgnumb	= VS_gW_QyPrtFailed,
						type	= "%s",
						var	= `family`,
						buff	= errStr ) ;
			}
		} else {
			*p_count	= pcount ;
			*p_parts	= plist ;
			*msg		= MSSUCC ;
		}
	}

	return *msg & 1 ;

} /* VSextractPartsFromRDB */
/*----------------------------------------------------------------------------*/

