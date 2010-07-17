/*
	I/STRUCT
	This function is interfaced by macro vs$extract_shapes_from_RDB.
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
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
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
#include "vsRDBproto.h"
/*----------------------------------------------------------------------------*/
long VSextractShapesFromRDB( msg, errStr, material, p_count, p_shapes )

long	*msg ;
char	*errStr,
	*material,
	***p_shapes ;
int	*p_count ; {

	long	sts ;
	char	searchCriteria[VS_K_MAX_CHARS] ;
	OMuword	actOs ;
	int	cpCount	= 0,
		count	= 0,
		i ;
	char	**cpList= NULL ;

	*p_count	= 0 ;
	*p_shapes	= NULL ;
	if( errStr ) *errStr = '\0' ;

	/*
	 * First look for user-made composite profiles stored in active file.
	 */
	ex$get_cur_mod( osnum = &actOs ) ;
	sts = VSgetCmpPrflFamsFromDir( msg, actOs, material,
					 &cpCount, &cpList ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Now go for RIS !
	 * SELECT	n_itemrev
	 * FROM		mat_and_fam
	 * WHERE		n_itemname	= '<material>'
	 *		AND	vs_type		= 'cross_section'
	 */

	sprintf(	searchCriteria,
			"%s='%s' AND %s='%s'",
			PDU_PARTID_ATTR,
			material,
			VS_K_PDM_vstypeAttr,
			VS_K_PDM_profileType ) ;

	sts = vs$RISquery(	table	= VS_K_PDM_matAndFamCat,
				select	= PDU_REVISION_ATTR,
				where	= searchCriteria,
				p_count	= &count,
				p_list	= p_shapes ) ;
	if( !sts ) {
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_QyPrfFailed,
					type	= "%s",
					var	= `material`,
					buff	= errStr ) ;
		}
		goto wrapup ;
	}
	
	/*
	 * The composite profiles must be added at the end of the list, since
	 * the caller of this function, may want to search the index of a
	 * profile in the list needed the retrieve the parameters of the
	 * profile: the index is not used for composite profiles but is used
	 * by regular profiles, known to PDM/PDU, to index into a catalog.
	 * Hence if we put regular profiles first the index will be OK.
	 */
	if( cpCount ) {
		int	total = count + cpCount,
			j ;
		char	**newptr ;

		newptr = (char **) realloc( (char *) *p_shapes,
					    total * sizeof( char ** ) ) ;
		if( !newptr ) {
			*msg = EMS_E_NoDynamicMemory ;
			goto wrapup ;
		}
		*p_shapes = newptr ;

		for( j = 0, i = count ; i < total ; i++ ) {
			(*p_shapes)[i] = cpList[j] ;
			j++ ;
		}
	}
	*msg = MSSUCC ;
	*p_count = count + cpCount ;

	wrapup :
		if( !( *msg & 1 ) ) {
			if( cpCount && cpList ) {
				di$free( lines = cpList, count = cpCount ) ;
			}
			VSfreeList( count, *p_shapes ) ;
		}

		return *msg & 1 ;

} /* VSextractShapesFromRDB */
/*----------------------------------------------------------------------------*/

