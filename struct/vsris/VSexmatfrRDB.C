/*
	I/STRUCT
	This function is interfaced by macro vs$extract_materials_from_RDB.
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
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
#include "vsstrngproto.h"
#include "vsRDBproto.h"
/*----------------------------------------------------------------------------*/
long VSextractMaterialsFromRDB( msg, errStr, p_count, p_materials )

long	*msg ;
char	*errStr,
	***p_materials ;
int	*p_count ; {

	long	sts ;
	char	**compressed	= NULL,
		**mlist		= NULL ;
	int	mcount,
		count ;

	*p_count	= 0 ;
	*p_materials	= NULL ;
	*msg		= MSSUCC ;
	if( errStr ) *errStr = '\0' ;

	/*
	 * SELECT	n_itemname
	 * FROM		mat_and_fam
	 */
	sts = vs$RISquery(	table	= VS_K_PDM_matAndFamCat,
				select	= PDU_PARTID_ATTR,
				p_count	= &mcount,
				p_list	= &mlist ) ;

	if( !sts ) {
		*msg = MSFAIL ;
		VSfreeList( mcount, mlist ) ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_QyMatFailed,
					buff	= errStr ) ;
		}
		goto wrapup ;
	} else if( !mcount ) {
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_NoMaterials,
					buff	= errStr ) ;
		}
		goto wrapup ;
	}

	/*
	 * Remove duplicate entries in list, since the way the catalog
	 * is made we have a material entry for each family type.
	 */
	VSremove_dups_in_list( msg, mcount, mlist, &count, &compressed ) ;

	if( *msg & 1 ) {
		VScopyList( msg, compressed, count, p_materials ) ;
		if( *msg & 1 ) *p_count = count ;
	}


	wrapup :
	_FREE( compressed ) ;
	VSfreeList( mcount, mlist ) ;
		return *msg & 1 ;

} /* VSextractMaterialsFromRDB */
/*----------------------------------------------------------------------------*/

