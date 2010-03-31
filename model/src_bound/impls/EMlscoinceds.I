/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method finds all the parts contained in this boundary element (in
    this case, the loopset) which are coincident with the given reference edge.
    The "parts" are always edges or pieces thereof. Each coincident part is
    represented by the two bounding points of the part. These points are
    computed for the reference-edge and also for the coincident edge.

  BUGS

    This method does not sense a coincident region whose end-points are not
    in the set of points formed by the end-points of the reference edge
    and all the end-points of the edges in the loopset.

  HISTORY

    SS  :  12/29/88  :  Creation
*/

class implementation EMSloopset;

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSedge import EMgetrange, EMgetbcgeom;

method EMcoincedges (IGRlong *msg; GRobjid ref_edge; 
                     struct EMSpartedinfo *ref_partinfo;
                     IGRdouble *ref_range; struct IGRbsp_curve *ref_geom;
                     struct EMSpartolbasis *partolbasis;
                     IGRint *num_coinc;
                     struct EMSpypoint **pts_on_ref;
                     struct EMSsfintedpar **pts_on_coinc)
{
  IGRlong stat_OM, msg_loc;
  IGRdouble ref_range_loc[4], uvlentol;
  struct IGRbsp_curve cv_loc;
  OM_S_CHANSELECT chan_to_loops;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  cv_loc.poles = NULL;
  cv_loc.knots = NULL;
  cv_loc.weights = NULL;

  /*
   * Obtain the parametric-tolerance, reference edge range (incremented) and
   * the reference edge geometry, if they have not been supplied.
   */

  if (!partolbasis->is_valid)
    {
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
               NULL, partolbasis), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);
    partolbasis->is_valid = TRUE;
    }
  EFextract_par (BSTOLLENVEC, partolbasis->tol, &uvlentol, &msg_loc);

  if (! ref_range)
    {
    stat_OM = om$send (msg = message EMSedge.EMgetrange (&msg_loc, 
               ref_range_loc, ref_partinfo), targetid = ref_edge);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

    ref_range = ref_range_loc;

    EM2dbxinc (ref_range, uvlentol);
    }

  if (!ref_geom)
    {
    stat_OM = om$send (msg = message EMSedge.EMgetbcgeom (&msg_loc, 0, MAXINT,
               FALSE, ref_partinfo, &cv_loc, NULL, NULL), targetid = ref_edge);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

    ref_geom = &cv_loc;
    }

  /*
   * Broadcast the message down to the loops
   */

  stat_OM = EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = message EMSboundary.EMcoincedges (&msg_loc,
             ref_edge, ref_partinfo, ref_range, ref_geom, partolbasis,
             num_coinc, pts_on_ref, pts_on_coinc),
             p_chanselect = &chan_to_loops);

ret_end:
  if (cv_loc.poles)
    om$dealloc (ptr = cv_loc.poles);
  if (cv_loc.knots)
    om$dealloc (ptr = cv_loc.knots);
  if (cv_loc.weights)
    om$dealloc (ptr = cv_loc.weights);

  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMcoincedges");
  return (stat_OM);
}

end implementation EMSloopset;

