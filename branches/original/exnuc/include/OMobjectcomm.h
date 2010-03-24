/*
-------------------------------------------------------------------------------

	Name:			OMobjectcomm.h
	Author:			Chuck Puckett
	Creation Date:		16-aug-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	This include file does a series of includes that should take care
	of all OM object communication symbol definitions and variable
	references.

	Revision History:

cgp001	14-oct-1985	made includes check before including to speed up
			compile. Made flags "defined". Bit fields on struct
			to avoid compiler woes.

cgp002	26-oct-1985	add some new externs for (relation) maps.

cgp003	11-nov-1985	Object Space additions. 

-------------------------------------------------------------------------------
*/

#ifndef	OM_D_OBJECTCOMM
#define	OM_D_OBJECTCOMM	1
#ifndef OM_D_MACROS
#include 	"OMmacros.h"
#endif
#ifndef	OM_D_MINIMUM
#include 	"OMminimum.h"
#endif
#ifndef OM_D_PRIMITIVES
#include        "OMprimitives.h"
#endif
#ifndef	OM_D_SPECIFY
#include 	"OMspecify.h"
#endif
#ifndef	OM_D_ERRORDEF
#include 	"OMerrordef.h"
#endif


#endif
