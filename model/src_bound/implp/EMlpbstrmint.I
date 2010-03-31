/* ###################   APOGEE COMPILED   ################## */

/* 
   History

	Sudha	06/04/93	modified to include BSprototype header files

*/

class implementation EMSloop;

#include "EMS.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSerrordef.h"
#include "bserr.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "bsbx2.h"


from EMSedge import EMedbstrimint;

method EMlpbstrimint (IGRlong *EMmsg;
                      struct IGRbsp_curve *incurve;
                      IGRdouble *incurve_range;
                      struct EMSpartolbasis *partol_basis;
                      IGRint tree_depth; IGRushort options;
                      IGRint *num_inters;
                      struct EMSsfintedpar **myinters;
                      struct EMSpypoint **polyinters)
 
/* ********************************************************************

   This method trims an incoming bspline geometry against a loop and
   also loops nested in this loop if any.

   Currently, all this method does is to pass on the message to the edges.

   Note:
     Mind you this routine accepts a 3d range of the bspline consistent with
     the fact that the uv bspline that it is getting is three dimensional with
     the z coordinate being 0.

     This method could have been optimized as far as processing of natural
     loops go.  I will come back and do the same when I get time.

   ******************************************************************** */

{
  BSrc			rc;
  GRobjid		dumid;
  IGRboolean		bssts;
  IGRlong		status;
  OM_S_CHANSELECT       chan_to_edges, chan_to_inner;
  IGRdouble		range[6];
  IGRdouble 		bs2drng[4];
  IGRdouble		*inrange;

  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  EMerr_hndlr (tree_depth <= 0, *EMmsg, EMS_E_InvalidArg, wrapup);

  if (!partol_basis->is_valid)
  {
   status = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg,
                           &dumid, partol_basis),
                     targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }

  chan_to_edges.type = OM_e_addr;
  chan_to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  if (!incurve_range)
  {
    inrange = range;

    if (incurve->rational)
    {
      bssts = BSbx2 (&rc, &incurve->num_poles, (IGRpoint *)incurve->poles, incurve->weights,
                     &inrange[0], &inrange[3]);
      EMerr_hndlr (!bssts, *EMmsg, EMS_E_Fail, wrapup);
    }
    else
    {
      bssts = BSbx2 (&rc, &incurve->num_poles, (IGRpoint *)incurve->poles, NULL,
                     &inrange[0], &inrange[3]);
      EMerr_hndlr (!bssts, *EMmsg, EMS_E_Fail, wrapup);
    }
  }
  else
   inrange = incurve_range;
   
/*
 * Again conversion from 3d to 2d
 */

   OM_BLOCK_MOVE (&inrange[0], &bs2drng[0], 2 * sizeof(IGRdouble));
   OM_BLOCK_MOVE (&inrange[3], &bs2drng[2], 2 * sizeof(IGRdouble));

  if (! EM2dbxbxint (bs2drng, ME.EMSloop->range))
  {
   goto wrapup;
  }

  status = om$send (msg = message EMSedge.EMedbstrimint (EMmsg,
                          incurve, incurve_range, partol_basis, NULL, options,
                          num_inters, myinters, polyinters),
                    p_chanselect = &chan_to_edges);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  
/*
 * Send to inner loops
 */

  tree_depth--;
  if (tree_depth)
  {
   chan_to_inner.type = OM_e_addr;
   chan_to_inner.u_sel.addr = &ME.EMSloop->to_inner;

   status = om$send (msg = message EMSloop.EMlpbstrimint (EMmsg,
                           incurve, incurve_range, partol_basis, tree_depth,
                           options, num_inters, myinters, polyinters),
                     p_chanselect = &chan_to_inner);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }

wrapup:
  EMWRAPUP (*EMmsg, status, "In EMSloop: EMlpbstrimint error");
  return (status);
}

end implementation EMSloop;
