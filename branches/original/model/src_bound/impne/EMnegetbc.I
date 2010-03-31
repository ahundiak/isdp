/* ###################   APOGEE COMPILED   ################## */

class implementation EMSnatedge;

#include "OMmacros.h"

method EMgetbcgeom (IGRlong *EMmsg;
                    IGRint from_spaninx;
                    IGRint num_spans;
                    IGRboolean reverse;
                    struct EMSpartedinfo *bnd;
                    struct IGRbsp_curve *bsgeom;
                    struct EMSpartolbasis *partolbasis;
                    IGRushort options)

/* *********************************************************************

History
 06/01/87 : PP : Creation
   ********************************************************************* */
{
 static IGRdouble	knots[4] = { 0.0, 0.0, 1.0, 1.0};

 IGRlong		status;
 IGRint			inx, modloc;
 IGRdouble		val,
                        *poles;

 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;


/*
 * Should the span index be greater than 0, then invalid arguments are
 * returned
 */

 EMerr_hndlr (from_spaninx > 0, *EMmsg, EMS_E_InvalidArg, wrapup);
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

  /*
   * Making use of the fact that constant in U
   * and constant in V are represented
   * by even and odd "location" respectively and the fact
   * that a "location" equal to 1 or 2 represents
   * the 1.0 isoparametric line ("location" 0 or 1
   * represents the 0.0 isoparametric line), these
   * constant values for the points can be established 
   * thusly:
   */

  /* This math should be replaced with logic. AIC */

  inx = (ME.EMSnatedge->location & 0x3) % 2;
  val = ((ME.EMSnatedge->location & 0x3) % 3 ? 1.0 : 0.0);

  poles[inx] = val;
  poles[inx+3] = val;

/*
 * the z poles are 0 since the uv curve is essentially 2d
 */

  poles[2] = 0.0;
  poles[5] = 0.0;

  /*
   * Processing from here on is to correctly return
   * the other two values in the "points" array.
   * If the entire edge is to be returned, these values
   * are 0 and 1 going into appropriate slots. Else,
   * these are values defined in the "bnd"-structure.
   */

  inx = (inx + 1) % 2;
  if (bnd)
    {
    if ((ME.EMSnatedge->location & 0x3) > 1)
      {
       poles[inx] = 1.0 - bnd->edbdry[reverse ? 1 : 0].param;
       poles[inx+3] = 1.0 - bnd->edbdry[reverse ? 0 : 1].param;
      }
    else
      {
       poles[inx] =  bnd->edbdry[reverse ? 1 : 0].param;
       poles[inx+3] = bnd->edbdry[reverse ? 0 : 1].param;
      }
    }
  else
    {
    reverse = ME.EMSedge->ed_props & EMED_REVERSED ? 
               (reverse ? FALSE : TRUE) :
               (reverse ? TRUE : FALSE);
    modloc = (ME.EMSnatedge->location & 0x3) + (reverse ? 2 : 0);
    val = (modloc % 4) / 2;
    poles[inx] =  val;
    poles[inx+3] = (val == 0.0 ? 1.0 : 0.0);
    }

 
 wrapup:
  EMWRAPUP (*EMmsg, status , "In EMSnatedge; EMgetbcgeom error");
  return (status);

}

end implementation EMSnatedge;

