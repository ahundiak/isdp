
/*
	I/STRUCT
*/
class implementation EMSsurface ;

#include <stdio.h>
#include <stdlib.h>
#include "vd_ve.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
long VSdrwObjectToWireFrame( msg, objId, objEnv, cst, wfCount, wfList )

long			*msg ;
struct GRid		*objId ;
struct GRmd_env 	*objEnv ;
struct GRvg_construct	*cst ;
int			*wfCount ;
struct GRid		*wfList[] ; {

	/*
	 * This functions returns the wireframes of a surface.
	 */

	long			sts ;		/* OM return code.	      */
	int			i, j, cnt ;
	struct	VDve_elem_buf	vBuf ,
				hBuf ; 

	SetProc( VSdrwObjectToWireFrame ); Begin

	VD_veInitElemBuf( &vBuf );
	VD_veInitElemBuf( &hBuf );

	__DBGpr_obj( "Object", *objId ) ;

	*wfCount = 0 ;

        /*
         * Process the object independent.
         */

        sts = VD_drwCstConstIndividual( msg, objId, objEnv, NULL, NULL,
                                        &vBuf, &hBuf );
        __CheckRC( sts, *msg, "VD_drwCstConstIndividual", wrapup ) ;

	cnt = vBuf.count + hBuf.count ;

	if( ! cnt ) goto wrapup ;

	if( !( *wfList = _MALLOC( cnt, struct GRid ) ) ) vs$mem_fail() ;

 	for( i=0 ; i<vBuf.count ; i++ )	{
		(*wfList)[i] = vBuf.obj_info_p[i].obj_id;
	}
	for( j=0 ; j<hBuf.count ; j++ ) {
		(*wfList)[i++] = hBuf.obj_info_p[j]._grid ;
	}
	*wfCount = cnt;
	
	__DBGpr_objlist( "Wireframes", *wfCount, *wfList ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *wfList ) ;
			*wfList  = NULL ;
			*wfCount = 0 ;

		}
		VD_veFreeElemBuf( &vBuf );
		VD_veFreeElemBuf( &hBuf );
		

		End
		return sts ;

} /* VSdrwObjectToWireFrame */
/*----------------------------------------------------------------------------*/

end implementation EMSsurface ;
