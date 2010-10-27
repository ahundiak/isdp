/* $Id: VDdrw_gMat.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func / VDdrw_gMat.I
 *
 * Description:
 *	Function :  VD_drwtb_getMatrixFrom2Points
 *
 *
 * Dependencies:
 *
 * History:
 *
 *	04/14/95	R. Manem	Creation
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

from GRgencs		import	GRcvt_to_wld_coords;

extern IGRboolean MAtrlmx();
extern IGRboolean MAtypemx();

/*+fe
 -------------------------------------------------------------------------
  Function VD_drwtb_getMatrixFrom2Points

  Macro Name
        None

  Abstract
	Function generates a transformation matrix given two points.

  Arguments

	IGRlong		*msg	    	O	return code
	IGRdouble	*fromPoint	I	From point
	IGRdouble	*toPoint	I	To point
	struct GRid	*csId		I	Local coordinate system
	IGRshort	*matType     	O	Transformation matrix type
	IGRmatrix	tMatrix     	O	Transformation matrix
	
  Notes/Remarks
	The points fromPoint and toPoint are with reference to the local
	coordinate system.  If csId is NULL, then the points are assumed to
	be with respect to the base coordinate system

  Returns
	OM_S_SUCCESS	= if success
	OM_E_ABORT	= if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VD_drwtb_getMatrixFrom2Points(	IGRlong		*msg,
					IGRdouble	*fromPoint,
					IGRdouble	*toPoint,
					struct GRid	*csId,
					IGRshort	*matType,
					IGRmatrix	tMatrix )
{
    IGRint		i;
    IGRchar		rect = 0;
    IGRdouble		cvtFromPnt[3],
			cvtToPnt[3],
			delta[3];
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VD_drwtb_getMatrixFrom2Points ); Begin

    *msg = MSSUCC;

    /* if cs is specified, convert input points to base coordinates */

    if( csId )
    {
        status =
        _VD_SEND_OBJN( *csId, GRgencs.GRcvt_to_wld_coords(	msg,
								&rect,
								1,
								fromPoint,
								cvtFromPnt ) );
        CheckRC( status, *msg );
						
        status =
        _VD_SEND_OBJN( *csId, GRgencs.GRcvt_to_wld_coords(	msg,
								&rect,
								1,
								toPoint,
								cvtToPnt ) );
        CheckRC( status, *msg );
    }
    else
    {
        for( i = 0 ; i < 3 ; i++ )
        {
            cvtFromPnt[i] = fromPoint[i];
            cvtToPnt[i]   = toPoint[i];
        }
    }
						
    __DBGpr_vec( "cvtFromPnt", cvtFromPnt );
    __DBGpr_vec( "cvtToPnt", cvtToPnt );

    delta[0] = cvtToPnt[0] - cvtFromPnt[0];
    delta[1] = cvtToPnt[1] - cvtFromPnt[1];
    delta[2] = cvtToPnt[2] - cvtFromPnt[2];

    __DBGpr_vec( "delta", delta );
    
    /* get transformation matrix */

    MAtrlmx( msg, delta, tMatrix );
    CheckRC( 1, *msg );

    MAtypemx( msg, tMatrix, matType );
    CheckRC( 1, *msg );

    End
    return status;
}

end implementation Root;
