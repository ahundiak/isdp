/* $Id */

/* I/Vds
 *
 *
 * File:        vdequip/buf/VDPEqBufferi.I
 *
 * Description:
 *      Implementation of the following methods for VDPenabObj
 *
 * Dependencies:
 *
 * History:
 *
 *      10/31/95        MSM        Creation
 *
 */

class implementation VDPEqBuffer;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDPdef.h"
#include "VDPEqpBuf.h"

method VDPsetEquipList( IGRlong *msg )
{
    IGRlong		status = OM_S_SUCCESS;
    struct VDPpre_ld_eqp	*EqpList;
    IGRchar             PlacementCtx[VDPNAME_LEN];
    IGRchar             ContextId[VDPOBID_LEN];
    IGRint		nbEqp=0,i;

    SetProc (VDPEqBuffer.VDPsetEquipList ); Begin

    *msg = MSSUCC;

    /* Get the Placement Context */
    status = VDPGetPlacementContext( msg, PlacementCtx, ContextId );

    /* Query the database for Placement List */

    UI_status ("Querying the PME server for Placement List .." );
    status = VDPgetPlacementList ( msg, ContextId, VDP_EQUIP, &nbEqp, &EqpList );
    __CheckRC( status, *msg, "VDPgetPlacementList", wrapup );

    __DBGpr_int ( "Number of PLEqps:", nbEqp );
    status = om$vla_set_dimension ( varray = me->VDPpreLdEqp, size = nbEqp );

    CheckRC ( status, 1 );

    memcpy ( me->VDPpreLdEqp, EqpList, nbEqp * sizeof(struct VDPpre_ld_eqp));

    for ( i = 0; i < nbEqp; i++ )
	me->VDPpreLdEqp[i].PlacedFlag= 'N';

wrapup:
    _FREE( EqpList );
    End
    return status;
}

method VDPgetEquipList( IGRlong *msg; IGRint *nbEqp; struct VDPpre_ld_eqp **EqpList )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc (VDPEqBuffer.VDPgetEquipList ); Begin

    *msg = MSSUCC;

    *nbEqp = om$dimension_of ( varray = me->VDPpreLdEqp );
    __DBGpr_int ( "Number of PLEqps:", *nbEqp );

    if ( *nbEqp )
    {
        *EqpList = _MALLOC ( *nbEqp, struct VDPpre_ld_eqp );
    	if ( ! *EqpList )
    	{
	    UI_status ("Error in dynamic allocation of memory" );
	    goto wrapup;
    	}
    }

    memcpy ( *EqpList, me->VDPpreLdEqp, *nbEqp * sizeof(struct VDPpre_ld_eqp));

wrapup:
    End
    return status;
}

method  VDPrsrvEquipment( IGRlong *msg; IGRchar  *PMobid )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		i,nbEqp;

    SetProc (VDPEqBuffer.VDPrsrvEquipment ); Begin

    *msg = MSSUCC;

    nbEqp = om$dimension_of ( varray = me->VDPpreLdEqp );
    __DBGpr_int ( "Number of PLEqps:", nbEqp );

    for ( i=0; i < nbEqp; i++ )
    {
	if(!strcmp(PMobid, me->VDPpreLdEqp[i].PMobid))
	{
	    me->VDPpreLdEqp[i].PlacedFlag = 'Y';
	    break;
	}
    }

wrapup:
    End
    return status;
}

method VDPIsEqpmntReserved( IGRlong *msg; IGRint row_nb; IGRint flag )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc (VDPEqBuffer.VDPIsEqpmntReserved ); Begin

    *msg = MSSUCC;

    End
    return status;
}

end implementation VDPEqBuffer;
