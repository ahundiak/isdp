/* ###################   APOGEE COMPILED   ################## */
class implementation EMSptedge;

#include "EMS.h"
#include "OMmacros.h"

method EMgetbcgeom (IGRlong *EMmsg;
                    IGRint from_spaninx;
                    IGRint num_spans;
                    IGRboolean reverse;
                    struct EMSpartedinfo *bnd;
                    struct IGRbsp_curve *bsgeom;
                    struct EMSpartolbasis *partolbasis;
                    IGRushort options)

{
 static IGRdouble	knots[4] = { 0.0, 0.0, 1.0, 1.0};
 IGRlong		sts;
 IGRdouble		*poles;


 
 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 bsgeom->num_poles = 2;
 bsgeom->order = 2;
 bsgeom->num_knots = 4;
 bsgeom->periodic = FALSE;
 bsgeom->non_uniform = FALSE;
 bsgeom->rational = FALSE;
 bsgeom->planar = TRUE;
 bsgeom->phy_closed = FALSE;
 bsgeom->num_boundaries = 0;

/*
 * Malloc output memory if not sent in by the user
 */

 if (!bsgeom->poles)
 {
   bsgeom->poles = (IGRdouble *) om$malloc (size = 6 * sizeof (IGRdouble));
   EMerr_hndlr (!bsgeom->poles, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);
 }
 poles = bsgeom->poles;

 if (!bsgeom->knots)
 {
   bsgeom->knots = (IGRdouble *) om$malloc (size = 4 * sizeof (IGRdouble));
   EMerr_hndlr (!bsgeom->knots, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);
 }
 
/*
 * We need not bother about the weights or the bdrys
 */

  OM_BLOCK_MOVE (knots, bsgeom->knots, 4 * sizeof(IGRdouble));
  OM_BLOCK_MOVE(ME.EMSptedge->point, poles, 2 * sizeof(IGRdouble));
  OM_BLOCK_MOVE(ME.EMSptedge->point, &poles[3], 2 * sizeof(IGRdouble));
  poles[2] = 0.0;
  poles[5] = 0.0;

 wrapup:
  EMWRAPUP (*EMmsg, sts , "In EMSptedge.EMgetbcgeom");
  return (sts);
}

end implementation EMSptedge;

