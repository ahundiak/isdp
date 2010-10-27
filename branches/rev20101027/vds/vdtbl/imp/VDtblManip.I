/* $Id: VDtblManip.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDtblInit.I
 *
 * Description:
 *	Implementation of the following methods  for VDdrwTbl :
 *		VDaddHeaders
 *		VDremoveHeaders
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTbl;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

/*+me
 ---------------------------------------------------------------------------
  Public Message VDaddHeaders

  Abstract
        This method adds the header objects as its component. The connection
        is flexible.

  Arguments
        IGRlong         *msg       O     Return code
        IGRint          nbHdrs     I     Nb of table headers
        struct GRid     *list      I     List of header objects

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/
method  VDaddHeaders(   IGRlong         *msg;
                        IGRint          nbHdrs;
                        struct GRid     *list )
{
    IGRint		i;
    IGRlong             status = OM_S_SUCCESS,
			index = OM_K_MAXINT,
			flag = 1;
    struct GRid		ownerId;

    SetProc( VDdrwTbl.VDaddHeaders ); Begin

    *msg = MSSUCC;

    __DBGpr_int( "Input nbHdrs", nbHdrs );

    ownerId.objid = my_id;
    ownerId.osnum = OM_Gw_current_OS;

    /* connect the header objects */

    for( i = 0 ; i < nbHdrs ; i++ )
    {
        status =
        _VD_SEND_OBJ( list[i], GRconnector.GRflexconn(	msg,
							&flag,
							&ownerId,
							&index,
							&index ) );
        CheckRC( status, *msg );
    }

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDremoveHeaders

  Abstract
        This method disconnects the header objects from its component
        channel.

  Arguments
        IGRlong         *msg       O     Return code
        IGRint          nbHdrs     I     Nb of table headers
        struct GRid     *list      I     List of header objects

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDremoveHeaders(   IGRlong         *msg;
                           IGRint          nbHdrs;
                           struct GRid     *list )
{
    IGRint              i;
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         ownerId;

    SetProc( VDdrwTbl.VDremoveHeaders ); Begin

    *msg = MSSUCC;

    __DBGpr_int( "Input nbHdrs", nbHdrs );

    ownerId.objid = my_id;
    ownerId.osnum = OM_Gw_current_OS;

    /* disconnect the header objects */

    for( i = 0 ; i < nbHdrs ; i++ )
    {
        status =
        _VD_SEND_OBJ( list[i], GRconnector.GRdisconn(  msg,
                                                       &ownerId ) );
        CheckRC( status, *msg );
    }

    End
    return status;
}

end implementation VDdrwTbl;

