/*
	I/STRUCT
	This function is interfaced by macro vs$extract_grades_from_RDB.
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
long VSextractGradesFromRDB( msg, errStr, material, p_count, p_grades )

long	*msg ;
char	*errStr,
	*material,
	***p_grades ;
int	*p_count ; {

	long	sts ;
	char	searchCriteria[VS_K_MAX_CHARS],
		**glist	= NULL ;
	int	gcount	= 0 ;

	*p_count	= 0 ;
	*p_grades	= NULL ;
	*msg		= MSSUCC ;
	if( errStr ) *errStr = '\0' ;

	/*
	 * SELECT	n_itemrev
	 * FROM		material
	 * WHERE	n_itemname = '<material>'
	 */
	sprintf( searchCriteria, "%s='%s'", PDU_PARTID_ATTR, material ) ;

	sts = vs$RISquery(	table	= VS_K_PDM_matCat,
				select	= PDU_REVISION_ATTR,
				where	= searchCriteria,
				p_count	= &gcount,
				p_list	= &glist ) ;

	if( !sts ) {
		*msg = MSFAIL ;
		VSfreeList( gcount, glist ) ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_QyGrdFailed,
					buff	= errStr,
					type	= "%s",
					var	= `material` ) ;
		}
		goto wrapup ;
	} else if( !gcount ) {
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_NoGrades,
					buff	= errStr,
					type	= "%s",
					var	= `material` ) ;
		}
		goto wrapup ;
	} else {
		*p_count	= gcount ;
		*p_grades	= glist ;
	}

	wrapup :
		return *msg & 1 ;

} /* VSextractGradesFromRDB */
/*----------------------------------------------------------------------------*/
