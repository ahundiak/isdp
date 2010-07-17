/*
	I/STRUCT
	This function is interfaced by macro vs$load_part_from_RDB.
*/
#include <stdio.h>
#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "gr.h"
#include "EMSmsgdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsRDBdef.h"
#include "vsRDBmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsRDBproto.h"
/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
/* ACC bug : won't accept ANSI declaration with args inside and definition
   with args outside a la K&R C when an arg has type (unsigned) short: here
   osnum causes it to choke...
 */
long VSloadPartFromRDB(	long		*msg,
			char		*errStr,
			char		*family,
			char		*material,
			char		*partName,
			OMuword		osnum,
			struct GRid	*object )
#else
long VSloadPartFromRDB( msg, errStr, family, material, partName, osnum,
			object )

long		*msg ;
char		*errStr,
		*family,
		*material,
		*partName ;
OMuword		osnum ;
struct GRid	*object ;
#endif

{

	char	objname[DI_PATH_MAX] ;

	if( errStr ) *errStr = '\0' ;

	VSmkPartCachePathName( msg, "struct", material, family, partName,
				objname ) ;
	if( !( *msg & 1 ) ) { goto wrapup ; }

	*msg = di$translate(	objname	= objname,
				osnum	= osnum,
				p_objid	= &object->objid ) ;

	if( !( *msg & 1 ) ) {
		/*
		 * Not found: create one.
		 */

		vs$loadParametricPart(	msg		= msg,
					errStr		= errStr,
					catalog		= family,
					partNum		= partName,
					revision	= material,
					pathname	= objname,
					partGRid	= object ) ;
					
	} else {
		object->osnum = osnum ;
		*msg = MSSUCC ;
	}

	wrapup :
		return *msg & 1 ;
	
} /* VSloadPartFromRDB */
/*----------------------------------------------------------------------------*/

