/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdpzone/imp/VDPZoneObji.I
 *
 * Description:
 *	Implementation of overridden methods
 *
 * Dependencies:
 *
 * History:
 *      
 *
 * -------------------------------------------------------------------------
 */

class implementation VDPZoneObj;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "OMmacros.h"
#include "OMprimitives.h"

#include "emsdef.h"
#include "EMSutlmacros.h"

#include "nddef.h"
#include "ndmacros.h"

#include "asbox.h"

extern  struct GRid   NULL_GRID;

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDplace from NDnode

  Abstract


  Arguments
        struct GRas     *assoc_list     I       associative information
        struct GRmd_env *md_env         I       module env
        char            *go_cnst_lis    I       full construction for the
                                                corresponding graphic object

 ---------------------------------------------------------------------------
-mo*/

method NDplace(	struct GRas	*asso_lis;
		struct GRmd_env	*mod_env;
		char		*go_cnst_lis )
{
    IGRlong		status = OM_S_SUCCESS, msg = MSSUCC;
    OMuint		count;
    struct GRid		*parent,
			my_grid, ZoneMgr;
    struct GRmd_env	parent_go_env;
    IGRlong		index, flag;


    SetProc( VDPZoneObj.NDplace ) ; Begin

    count = asso_lis->num_parents;
    parent = asso_lis->parents;

    __DBGpr_obj ( "Parent ", *parent );

    status = _VD_SEND_MY( NDnode.NDconnect ( asso_lis->num_parents,
					     asso_lis->parents,
					     NULL_GRID,
					     ND_NEW ));
    __CheckRC ( status, 1, "NDnode.NDconnect", wrapup );

    ZoneMgr.objid = NULL_OBJID;
    status = VDPGetZoneListId( &msg, &ZoneMgr );
    __CheckRC ( status, 1, "VDPGetZoneListId", wrapup );

    flag = 1;
    index = OM_K_MAXINT;
    status = _VD_SEND_MY ( GRconnector.GRflexconn ( &msg, &flag,
						&ZoneMgr, &index, &index ));
    __CheckRC ( status, msg, "GRconnector.GRflexconn", wrapup );


wrapup :
    End

    return OM_S_SUCCESS;
}

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDcompute_node from NDnode

  Abstract
        Do nothing.  No graphical components

  Arguments
        IGRlong         *msg            O       return code
        IGRint          cn_type         I       reserved
        IGRint          count           I       number of roots
        struct GRid     *list           I       list of roots
        struct GRmd_env *md_env         I       module env

 ---------------------------------------------------------------------------
-mo*/

method  NDcompute_node ( IGRlong         *msg;
                         IGRint          cn_type;
                         int             count;
                         struct GRid     *list;
                         struct GRmd_env *mod_env )
{
    SetProc( VDPZoneObj.NDcompute_node ) ; Begin

    *msg = MSSUCC;

    End
    return OM_S_SUCCESS;
}

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDmove_to_root from NDnode

  Abstract
        When any of the parents is deleted, this message is received.
        Get the new list of parents. If one or more, put myself in the
        wait_batch, so that the dependent row object will recompute.  Else
        send VDparentSetEmpty message to the row object.

  Arguments
        IGRlong         *msg            O       return code
        struct GRid     *src_grid       O       GRid of the created object
        struct GRmd_env *md_env         I       module env
 ---------------------------------------------------------------------------
-mo*/

method NDmove_to_root(	IGRlong		*msg;
			struct GRid	*src_grid;
			struct GRmd_env	*md_env )
{

    SetProc( VDPZoneObj.NDmove_to_root ) ; Begin

    *msg = MSSUCC;

    End
    return OM_S_SUCCESS;
}

/*+me
 -----------------------------------------------------------------------------
  Public Message  VDPSetInstance

  Abstract
    This method sets the instance of the Zone

  Argument
    IGRlong		*msg		0
    struct VDPzone	ZoneInfo	I

  Status/Return Code
    status == OM_S_SUCCESS if success;
 -----------------------------------------------------------------------------
-me*/

method VDPSetInstance( IGRlong		*msg;
			struct VDPzone	ZoneInfo )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDPZoneObj.VDSetInstance ) ; Begin

    *msg = MSSUCC;

    me->ZoneCtx.Name[0] = '\0';
    me->ZoneType = ZoneInfo.ZoneType;
    me->ZoneCtx  = ZoneInfo.ZoneCtx;

    __DBGpr_str ( "Zone Name", me->ZoneCtx.Name );

    End
    return status;

}

/*+me
 -----------------------------------------------------------------------------
  Public Message  VDPGetInstance

  Abstract
    This method gets the instance of the Zone

  Argument
    IGRlong		*msg		0
    struct VDPzone	*ZoneInfo	0

  Status/Return Code
    status == OM_S_SUCCESS if success;
 -----------------------------------------------------------------------------
-me*/

method VDPGetInstance( IGRlong		*msg;
			struct VDPzone	*ZoneInfo )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDPZoneObj.VDPGetInstance ) ; Begin

    *msg = MSSUCC;

    ZoneInfo->ZoneType = me->ZoneType;
    ZoneInfo->ZoneCtx  = me->ZoneCtx;
    ZoneInfo->ZoneId.objid = my_id;
    ZoneInfo->ZoneId.osnum = OM_Gw_current_OS;

    End
    return status;
}

end implementation VDPZoneObj;

