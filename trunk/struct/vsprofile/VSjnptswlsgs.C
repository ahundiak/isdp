/*
	I/STRUCT
*/

#include <stdio.h>		/* For NULL		*/
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "gr.h"
#include "igrdp.h"
#include "igrdef.h"
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "godef.h"
#include "go.h"
#include "emsdattyp.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "EMSwrmacros.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
long VSjointPtsWithLineSegs( msg, count, points, cst, lineSegs )

long			*msg ;
int			count ;
double			*points ;
struct GRvg_construct	*cst ;
struct GRid		*lineSegs ; {

	long		sts ;
	int		i,
			next ;
	IGRpoint	pts[2] ;

	if( !count ) vs$inv_arg() ;

	VSsetGRids( cst->env_info->_MD_OS, count, lineSegs ) ;

	for( i = 0 ; i < count ; i++ ) {
		VSvccpy( pts[0], points + 3 * i ) ;
		next = i == count - 1 ? 0 : i + 1 ;
		VSvccpy( pts[1], points + 3 * next ) ;

		EFplace_line_string(	NULL_OBJID,
					cst,
					2,
					&pts[0][0],
					&lineSegs[i].objid,
					msg ) ;
		if( !( *msg & 1 ) ) { sts = OM_W_ABORT ; goto wrapup ; }
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	grids	= lineSegs,
					count	= count,
					theEnv	= cst->env_info ) ;
		}
		return sts ;

} /* VSjointPtsWithLineSegs */
/*----------------------------------------------------------------------------*/

