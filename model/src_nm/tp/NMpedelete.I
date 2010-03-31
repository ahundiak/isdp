class implementation NMpartedge;

#include "EMS.h"
#include "emsmacros.h"

method delete(int defer_flag)
{
  IGRboolean		notify;
  IGRlong               OM_stat;
  OMuint                num_owners = 0;
  IGRboolean            deletable;
  OM_S_CHANSELECT       to_owners;


  OM_stat = OM_S_SUCCESS;

  to_owners.type = OM_e_addr;
  to_owners.u_sel.addr = &ME.EMSedge->to_owner;

  OM_stat = om$get_channel_count(object = me, 
                                 p_chanselect = &to_owners,
                                 count = &num_owners);
  EMomerr_hndlr(OM_stat, wrapup, "NMpartedge.delete -- count owners")

  /*
   * Determine if I am deletable.
   */

  if(num_owners == 0) deletable = TRUE;
  else if(num_owners == 1)
  {
    deletable = TRUE;
    OM_stat = om$is_objid_on_channel(object_c = me, 
                 p_chanselect = &to_owners, objid = sender_id);

    if(OM_stat == OM_W_NOTONCHAN)
    {
      OM_stat = OM_S_SUCCESS;
      deletable = FALSE;
    }
    EMomerr_hndlr(OM_stat, wrapup, "NMpartedge.delete -- check owner")

  }
  else deletable = FALSE;

  if(deletable)
  {
    OM_S_CHANSELECT      to_edge;
    IGRushort props;
    OM_S_CHANSELECT   to_common_edge;
    IGRlong	     EMmsg;

    /*
     * Delete my edge.
     */

    to_edge.type = OM_e_addr;
    to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;

    OM_stat = om$send(msg=message Root.delete(defer_flag),
                  p_chanselect=&to_edge);
    EMomerr_hndlr(OM_stat, wrapup, "NMpartedge.delete -- edge")

    props = EMED_REVERSE_CONNECT | EMED_SUBORDINATE;
    OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
				
    OM_stat = om$send(msg = message EMSedge.EMset_props
			(&EMmsg, props, EMS_O_OFF), 
			p_chanselect = &to_common_edge);
			
    /*
     * Delete myself.
     */

    if (notify = EMcheck_inhibit_postproc())
      {
      OM_stat = om$send (msg = message EMSboundary.EMpostdelete (&EMmsg,
                 NULL, NULL), targetid = my_id);
      EMerr_hndlr (EMSerror (OM_stat & EMmsg), OM_stat, OM_E_ABORT, wrapup);
      }

    OM_stat = om$send(mode = OM_e_wrt_message, 
                  msg=message Root.delete(defer_flag),
                  targetid = my_id);

    if (notify)
      EMrestore_postproc();

    EMomerr_hndlr(OM_stat, wrapup, "NMpartedge.delete -- self")

  } /* if(deletable) */

 wrapup:
  return(OM_stat);
}

end implementation NMpartedge;
