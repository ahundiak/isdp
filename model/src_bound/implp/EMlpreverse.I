/* ###################   APOGEE COMPILED   ################## */
/*
Notes
        This method reverses a loop. The loop reverses all its edges,
  sets its reverse bit appropriately and if closed, toggles its loop type.

History
        SM      03/09/87        Creation date
        AIC     20 July 87      Handle FRTs
        RC      12/08/87        Modified such that correct graphics data
                                object is constructed.
        RC      09/07/88        If a p-loop is reversed to c-loop,
                                mark its owner loop's graphic data 
                                out_of_date.
                                
*/

class implementation EMSloop;

# include "EMS.h"
# include "emsmacros.h"
# include "EMSfrtdef.h"
# include "EMSlogic.h"      /* IS   */
# include "OMmacros.h"

extern OMuword  OPP_EMSgradata_class_id, OPP_EMSloop_class_id;

from EMSedge import EMreverse;
from EMSgradata import EMinit, EMreset;
from EMSsubbs   import EMmake_frt;

method EMreverse(IGRlong *EMmsg)
{
  IGRlong sts;
  OM_S_CHANSELECT to_edges;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;


/* Send a reverse message to all my edges
*/
  sts = om$send(msg = message EMSedge.EMreverse(EMmsg),
                p_chanselect = &to_edges);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

/* Set my reverse bit appropriately.
*/
  if(ME.EMSloop->lp_props & EMLP_REVERSED) 
        ME.EMSloop->lp_props &= ~EMLP_REVERSED;
  else ME.EMSloop->lp_props |= EMLP_REVERSED;

/* If I am closed then toggle my loop type
*/
  if(! (ME.EMSloop->lp_props & EMLP_OPEN))
  {
    OM_S_CHANSELECT     to_helpers, to_outter;
    GRobjid              owner_id = NULL_OBJID;

    sts = EMmake_chanselect (EMSrequester_to_helpers, &to_helpers);
    if (!(1 & sts)) goto wrapup;

    if(ME.EMSloop->lp_props & EMLP_PLOOP)
    {
      /*
       * Ploop to a Cloop
       */
      ME.EMSloop->lp_props &= ~EMLP_PLOOP;
      sts = om$send(msg = message Root.delete(1),
                    p_chanselect = &to_helpers);
      if(! (1 & sts)) goto wrapup;
           
      /*
       * set EMS_O_OUTOFDATE of my owners P-loop's FRT.
       */

      to_outter.type = OM_e_addr;
      to_outter.u_sel.addr = &ME.EMSloop->to_outter;

      sts = om$send (msg = message EMSboundary.EMget_objid (EMmsg, 
                      &owner_id),
                     p_chanselect = &to_outter);
      if (!(1& sts & *EMmsg)) goto wrapup;

      if (!IF_EQ_OBJID(owner_id, NULL_OBJID))
      {
        OMuword       owner_classid;

        sts = om$get_classid (objid = owner_id, 
                              p_classid = &owner_classid);
        if (!(1&sts)) goto wrapup;
    
        sts = om$is_ancestry_valid (subclassid = owner_classid,
                            superclassid = OPP_EMSloop_class_id);
        if (!(1&sts)) goto wrapup;

        if (sts == OM_S_SUCCESS)
        {
          sts = om$send (msg = message EMSgradata.EMreset(EMmsg,
                          EMS_O_OUTOFDATE),
                         senderid = owner_id, p_chanselect = &to_helpers);
          if (!(1 & sts & *EMmsg)) goto wrapup;
        }

      } /* if (!IF_EQ_OBJID(owner_id, NULL_OBJID)) */
     
    }
    else
    {
      GRobjid   surf_id, frt_id;

      /*
       * Cloop to a Ploop
       */
      ME.EMSloop->lp_props |= EMLP_PLOOP;
      surf_id = NULL_OBJID;
      sts = om$send(msg = message EMSloop.EMgetsurface_info
                    (EMmsg, &surf_id, NULL), targetid = my_id);
      EMerr_hndlr(!(1&*EMmsg&sts),sts,OM_E_ABORT,wrapup);
      if(surf_id != NULL_OBJID)
      {
        sts = om$send (msg = message EMSsubbs.EMmake_frt(EMmsg, my_id),
                       targetid = surf_id);
        EMerr_hndlr(!(1&*EMmsg&sts),sts,OM_E_ABORT,wrapup);
      }
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSloop.EMreverse")
  return(sts);
}

end implementation EMSloop;
