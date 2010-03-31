/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfimpbnd;

#include "EMS.h"
#include "OMmacros.h"
#include "grerr.h"      /* GRNOCONNECT */

method EMsfimpbnd_init (IGRlong *msg; 
                        GRobjid surf1;
                        IGRushort grvg_props)
/*

Return values
   EMS_S_Success if all is well.

History
   mrm  06/07/91        check for previous connection between surf1 and my_id
   DLB  11/08/87        Modified for version 1.1.0
   SM   05/11/87        Modified EMgminit.
*/ 
{
  IGRlong stat_OM, stupid_index;
  IGRlong msg_loc;
  struct GRid temp_GRid;
  OM_S_CHANSELECT chan_to_comps;
 

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  chan_to_comps.type = OM_e_addr;
  chan_to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

  if(!IF_NULL_OBJID(surf1))
  {
    /* Due to locate problem a solid might get located for operations */
    /* like impose boundaries and intersect plane save side. This is */
    /* checked here flagged as an error. */

    temp_GRid.objid = my_id;
    temp_GRid.osnum = OM_Gw_current_OS;    
    stupid_index = 0; 
    stat_OM = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
                            &temp_GRid, &stupid_index),
                      targetid = surf1);

    if ((stat_OM == OM_E_ABORT) && (msg_loc == GRNOCONNECT))
    {
        IGRint sts;
        struct GRid comp;

        /* Check whether a rigid connection already exists between surf1 */
        /* and my_id.  This will be the case during a recompute. */

        sts = om$get_objid_at_index(objid = my_id,
                                    p_chanselect = &chan_to_comps,
                                    index = 0,
                                    objidaddr = &comp.objid,
                                    osnumaddr = &comp.osnum);

        if (!(sts & 1) || (comp.objid != surf1)) goto wrapup;
    }
  }

  /*
   * Set the 'dpr' properties appropriately. Then,
   * set the 'GRvg' properties using the construct-list
   * sent in. Some of these properties, need to be propogated
   * right through to the surface.
   */

  /*Set the dpr properties -DLB*/
  ME.EMSdpr->dpr_props = EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH;    
 
  /*Set the vg props -DLB*/
  ME.GRgraphics->properties =grvg_props | GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  {
   /*Set my last state's active bits off - this could be subbs so I ignore
    * UNKNOWN_MSG warning. -- DLB
    */
    IGRboolean action = FALSE;
    IGRushort mask = EMSIS_ACTIVE_STATE;

    stat_OM = om$send(msg = message EMSdpr.EMsetprops(&msg_loc, &action, 
                            &mask),
                      p_chanselect = &chan_to_comps);
    if(stat_OM != OM_W_UNKNOWN_MSG)
    {
      EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, wrapup);
      EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);
    }
    else
      stat_OM = OM_S_SUCCESS; /*fix the return code*/
  }

wrapup:
  EMWRAPUP(*msg,stat_OM,"In EMSsfimpbnd.EMsfimpbnd_init");
  return (stat_OM);
}

end implementation EMSsfimpbnd;
