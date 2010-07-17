/*
	I/STRUCT
*/
#include <stdio.h>
#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "igrtypedef.h"
#include "DImacros.h"
/*----------------------------------------------------------------------------*/
long VSmkPartCachePathName( msg, topdir, material, family, partName,
			    cacheName )

long	*msg ;
char	*topdir,
	*material,
	*family,
	*partName,
	*cacheName ; {

	*msg	= DIstmcpy(	cacheName,
				topdir,
				material,
				family,
				partName,
				NULL ) ;

	return *msg & 1 ;

} /* VSmkPartCachePathName */
/*----------------------------------------------------------------------------*/

