/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "EMSprop.h"
#include "EMSssprops.h"
#include "EMSopt.h"

from EMSloopset import EMget_loops;

method EMset_inactive(IGRlong *EMmsg; IGRboolean *did_set_inactive)
/*
Description
    This message check to see if the surface is inactive by determining if
    all the loops are inactive.  If they are then the ssprops EMSIS_INACTIVE
    bit is set and the did_set_inactive flag is set to TRUE.  Otherwise the
    did_set_inactive flag is set to FALSE.

Notes
    This message is used for design files created before EMS 1.2.0 which had
    inactive surfaces but were only flagged as NON-LOC and NON-DISP. Any code
    which processes based on the inactive bit in the surface should first
    send this message.

History
    DLB :  04/14/89  :  Creation.
*/
{
  IGRlong OM_stat=OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;
  *did_set_inactive = FALSE;
  
  if ( !(ME.GRgraphics->properties & GRIS_LOCATABLE  ) &&
       !(ME.GRgraphics->properties & GRIS_DISPLAYABLE) &&
       !(ME.EMSsubbs->ss_props & EMSIS_INACTIVE      ) )
  {
    IGRushort *lpprops=NULL;
    IGRint            buff_size=0, count=0, inx, depth=MAXINT;
    OM_S_CHANSELECT   to_loopset;
    
    to_loopset.type = OM_e_addr;
    to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

    OM_stat = om$send(msg = message EMSloopset.EMget_loops(EMmsg,
                            EMS_OPT_ALL, &depth, NULL, &lpprops,
                            &buff_size, &count),
                      p_chanselect = &to_loopset);
    if ((1 & OM_stat & *EMmsg) && (OM_stat != OM_I_CHAN_EMPTY))
    {
      for(inx = 0; inx < count; inx ++)
      {
        if (lpprops[inx] & EMLP_ACTIVE) break;
      }        

      if (inx == count)
      {
        /*Didn't find an active one so this is an inactive surface.*/
        ME.GRgraphics->properties |= (GRIS_DISPLAYABLE | GRIS_LOCATABLE);
        ME.EMSsubbs->ss_props |= EMSIS_INACTIVE;
        *did_set_inactive = TRUE;        
      }
    }
    if (lpprops) om$dealloc(ptr = lpprops);
  }

  wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "EMSsubbs.EMset_inactive");
    return (OM_stat);
}
end implementation EMSsubbs;
