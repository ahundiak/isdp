/*
	I/STRUCT
	This function is interfaced by macro vs$find_thickness_in_RDB.
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "msmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "bstypes.h"
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
#include "bsquicksort.h"			/* Qsorts doubles	*/
#include "vsRDBproto.h"
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
long VSfindThicknessInRDB( msg, errStr, material, family, value,
					p_thkname, p_thickness, p_index )

long		*msg ;
char		*errStr,
		*material,
		*family,
		**p_thkname ;
double		value,
		*p_thickness ;
int		*p_index ; {

	long		sts ;
	char		where[VS_K_MAX_CHARS] ;
	int		rowCount ;		/* Count of rows in RDB	*/
	char		**rowList= NULL ;
	double		*rdbThkList = NULL ;	/* List of thicknesses	*/
	int		i,			/* Loop index		*/
			rdbThkCount = 0,	/* Count of thicknesses	*/
			max,			/* For sorting		*/
			min ,			/* For sorting		*/
			nameIndex ;		/* Index of thickness	*/
			
	*p_thkname = NULL ;

	/*
	 * Query for thicknesses :
	 * SELECT	thickness
	 * FROM		<family>
	 * WHERE	n_itemrev = '<material>'
	 */
	sprintf( where, "%s='%s'", PDU_REVISION_ATTR, material ) ;

	sts = vs$RISquery(	table	= family,
				select	= "thickness",
				where	= where,
				p_count	= &rowCount,
				p_list	= &rowList ) ;

	if( !sts ) {
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_QyThkFailed,
					type	= "%s%s",
					var	= `material,family`,
					buff	= errStr ) ;
		}
		goto wrapup ;
	} else if( !rowCount ) {
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_NoThicknesses,
					type	= "%s%s",
					var	= `material,family`,
					buff	= errStr ) ;
		}
		goto wrapup ;
	}

	if( !( rdbThkList = _MALLOC( rowCount, double ) ) ) {
		*msg	= EMS_E_NoDynamicMemory ;
		goto wrapup ;
	}

	for( i = 0 ; i < rowCount ; i++ ) {
		rdbThkList[i] = atof( rowList[i] ) ;
	}
	/*
	 * Sort values ...
	 */
	if( rowCount > 1 ) {
		BSrc rc ;
		max = rowCount - 1 ;
		min = 0 ;
		BSquicksort( &rc, &min, &max, &rowCount, rdbThkList ) ;
	}
	
	rdbThkCount = rowCount ;

	if( value <= rdbThkList[0] ) {
		*p_thickness = rdbThkList[0] ;
	} else if( value >= rdbThkList[rdbThkCount-1] ) {
		*p_thickness = rdbThkList[rdbThkCount-1] ;
	} else {
		for( i = 0 ; i < rdbThkCount - 1 ; i++ ) {
			if(    rdbThkList[i] < value
			    && value <= rdbThkList[i+1] ) {
			    		*p_thickness = rdbThkList[i+1] ;
			    		break ;
			}
		}
	}

	/*
	 * Now get thickness's name.
	 */
	nameIndex = -1 ;
	for( i = 0 ; i < rdbThkCount ; i++ ) {
		if( *p_thickness == atof( rowList[i] ) ) {
			nameIndex = i ;
			break ;
		}
	}
	VSfreeList( rowCount, rowList ) ;

	if( nameIndex == -1 ) {
		*msg	= MSFAIL ;
		goto wrapup ;
	}

	vs$extract_parts_from_RDB(	msg		= msg,
					errStr		= errStr,
					material	= material,
					family		= family,
					p_count		= &rowCount,
					p_parts		= &rowList ) ;
	if( *msg & 1 ) *msg = rowCount ? MSSUCC : MSFAIL ;
	__CheckRC( 1, *msg, "vs$extract_parts_from_RDB", wrapup ) ;

	if( p_index ) *p_index = nameIndex ;
	if( *p_thkname = VSstrdup( rowList[nameIndex] ) ) {
		*msg = MSSUCC ;
	} else {
		*msg = EMS_E_NoDynamicMemory ;
	}
	wrapup :

		_FREE( rdbThkList ) ;
		return *msg & 1 ;

}/* VSfindThicknessInRDB */
/*----------------------------------------------------------------------------*/
