/*

  HISTORY

    Sudha  06/16/93     Modified for BSprototype ansification


  DESCRIPTION
    
    This function extracts the Bezier curve that contains the pole being
    input.

  ARGUMENTS

    The input curve can be specified in two ways:
    1) mattyp, mat and incrv_id can be specified, if the curve is
       known as an object.
    2) If the geometry of the curve is already knownm, this may be
       specified.
    The irrelevant arguments in either case can be NULL.

    The space for the output curve can be input or be allowed to be malloced
    by the function. This is checked by this function by looking at *outcrv.
    If the contents are NULL then this function mallocs the memory using
    BSalloccv (to be freed by the caller vai BSfreecv), else the curve
    output buffer is assumed to be pointing to correct memory.
*/

class implementation GRsubbc;

#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "maptpspro.h"
#include "bsalloccv.h"

#define X 0
#define Y 1
#define Z 2

IGRlong EMextrbez (msg, opts, mattyp, mat,
                   pole,
                   incrv, incrv_id,
                   outcrv)
IGRlong *msg;
IGRushort opts;
IGRshort *mattyp;
IGRmatrix mat;
IGRpoint pole;
struct IGRbsp_curve *incrv;
struct GRid *incrv_id;
struct IGRbsp_curve **outcrv;
{
  IGRboolean stat_func;
  IGRint i, j, poleinx, start_pl, end_pl, start_kt, end_kt, np, nk;
  IGRlong msg_loc, ptnum, stat_OM;
  IGRpoint *temp_poles, point;
  struct IGRpointset pointset;
  struct IGRbsp_curve *crv;
  extern IGRlong EMgetabsg();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  temp_poles = NULL;

  EMerr_hndlr (!incrv && (!mattyp || !mat || !incrv_id), *msg,
   EMS_E_InvalidArg, ret_end);

  /*
   * Get this curves abstract geometry, if not already passed
   * in.
   */

  if (!incrv)
    {
    EMgetabsg (&msg_loc, mattyp, mat, incrv_id->osnum, incrv_id->objid,
     &incrv);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Get the pole index of the closest pole to the input pole. This is
   * the pole around which the Bezier curve is extracted.
   */

  pointset.num_points = incrv->num_poles;
  pointset.points = incrv->poles;
  if (incrv->rational)
    {
    temp_poles = (IGRpoint *) alloca (incrv->num_poles * sizeof (IGRpoint));
    EMerr_hndlr (!temp_poles, *msg, EMS_E_NoStackMemory, ret_end);
    OM_BLOCK_MOVE (incrv->poles, temp_poles, incrv->num_poles *
     sizeof (IGRpoint));

    for (i=0; i<incrv->num_poles; i++)
      for (j=X; j<=Z; j++)
        temp_poles[i][j] /= incrv->weights[i];
    pointset.points = (IGRdouble *) temp_poles;
    }
  stat_func = MAptpsproj (&msg_loc, pole, &pointset, point, &ptnum);
  EMerr_hndlr(!stat_func || EMSerror(msg_loc), *msg, EMS_E_MAerror, ret_end);
  poleinx = ptnum - 1;

  /*
   * Get the pole and the knot extents for the Bezier portion of
   * the curve that is affected by the input pole.
   */

  start_pl = poleinx - (incrv->order - 1);
  if (start_pl < 0)
    start_pl = 0;
  start_kt = start_pl;

  end_pl = poleinx + (incrv->order - 1);
  if (end_pl > incrv->num_poles - 1)
    end_pl = incrv->num_poles - 1;
  end_kt = end_pl + incrv->order;

  np = end_pl - start_pl + 1;
  nk = np + incrv->order;

  /*
   * Allocate space for the out Bezier curve, if needed and 
   * fill it in.
   */

  if (!*outcrv)
    {
    BSalloccv (incrv->order, np, incrv->rational, 0, outcrv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoDynamicMemory, ret_end);
    }
  crv = *outcrv;

  /* 	Alex Carr - Changed this to be incrv
	crv->order = crv->order;
  	crv->periodic = crv->periodic;
  	crv->non_uniform = crv->non_uniform;
  	crv->planar = crv->planar;
  */

  crv->order = incrv->order;
  crv->periodic = incrv->periodic;
  crv->non_uniform = incrv->non_uniform;
  crv->planar = incrv->planar;
  crv->phy_closed = (np == incrv->num_poles) ? incrv->phy_closed : FALSE;

  OM_BLOCK_MOVE (&incrv->poles[start_pl*3], crv->poles,
   np * sizeof (IGRpoint));
  crv->num_poles = np;

  OM_BLOCK_MOVE (&incrv->knots[start_kt], crv->knots, nk * sizeof (IGRdouble));
  crv->num_knots = nk;

  crv->rational = incrv->rational;
  if (crv->rational)
    OM_BLOCK_MOVE (&incrv->weights[start_pl], crv->weights,
     np * sizeof (IGRdouble));
  else 
    crv->weights = NULL;

ret_end:
   EMWRAPUP (*msg, stat_OM, "EMextrbex.I");
   return (stat_OM);
}

end implementation GRsubbc;
