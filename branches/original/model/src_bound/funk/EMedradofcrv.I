/*
  DESCRIPTION

    This function takes in a point on the XYZ-geometry of the edge
    and returns the radius of curvature at that point. Using the options
    EMS_O_Start or EMS_O_Stop the radius of curvature at the start and stop
    ends may be obtained without the 'point' being specified. If EMS_O_Internal
    is specified then a point somewhere in the middle is used to determine
    the curvature. So, only if the options is NULL is the point ever looked
    at.

  NOTES

    Today, this function gives a very gross approximation of the curvature
    if the dominant edge's xyz-geometry is an approximate, order-2 curve.
    We should incorporate something more sophisticated at some later time.

  HISTORY

    SS  :  10/20/93  :  Creation
*/

class implementation EMSedge;

#include "OMmacros.h"
#include "bserr.h"

#define FIT_ORDER 3

IGRdouble EMedradofcrv (msg, opts, mattyp, mat, edge, os, point)
IGRlong *msg; 
IGRushort opts; 
IGRshort *mattyp; 
IGRmatrix mat;
GRobjid edge;
GRspacenum os;
IGRdouble *point;
{
  IGRboolean dumb, reverse;
  IGRushort ed_props;
  IGRuint has_common_edge;
  IGRlong msg_loc, stat;
  IGRdouble radofcrv, param, dumd;
  IGRpoint dumpt;
  GRobjid use_edge;
  struct GRmdenv_info mdenv_info;
  struct IGRbsp_curve cv, *fitcv, *meascv;
  OM_S_CHANSELECT chan_to_common;
  OM_S_OBJECT_LINKAGE list;

  *msg = EMS_S_Success;
  radofcrv = 0.0;
  cv.poles = cv.knots = cv.weights = NULL;
  fitcv = NULL;

  /*
   * Always try to derive the curvature from the best of the two
   * curves comprising the edge (the dominant edge).
   */

  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
  has_common_edge = 0;
  om$get_channel_objects (objid = edge, osnum = os, 
   p_chanselect = &chan_to_common, size = 1, list = &list, 
   count = &has_common_edge);
 
  ed_props = NULL;
  om$send (msg = message EMSedge.EMget_props (&msg_loc, &ed_props),
   targetid = edge, targetos = os, senderid = NULL_OBJID);
  if (ed_props & EMED_SUBORDINATE)
    {
    EMerr_hndlr (!has_common_edge, *msg, EMS_E_InvalidCase, ret_end);

    use_edge = list.S_objid;
    reverse = ed_props & EMED_REVERSE_CONNECT;
    }
  else
    {
    use_edge = edge;
    reverse = FALSE;
    }

  mdenv_info.matrix_type = *mattyp;
  if (*mattyp != MAIDMX)
    OM_BLOCK_MOVE (mat, mdenv_info.matrix, sizeof (IGRmatrix));
  om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc, &mdenv_info,
   NULL, NULL, 0, MAXINT, reverse, NULL, &cv), targetid = use_edge,
   targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Fit the curve if this is an approximate curve. 
   */

  if (cv.order == 2 && cv.num_poles > 2)
    {
    BSalloccv (FIT_ORDER, (cv.num_poles + FIT_ORDER - 1), FALSE, 0, &fitcv,
     &msg_loc);
    EMerr_hndlr (!fitcv, *msg, EMS_E_NoDynamicMemory, ret_end);

    BSdirfitcv (cv.num_poles, cv.poles, FIT_ORDER, FALSE, FALSE, FALSE, 
     NULL, NULL, fitcv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    meascv = fitcv;
    }
  else
    meascv = &cv;

  /* 
   * Determine the radius of curvature at specified parameter
   */

  if (opts & EMS_O_Start)
    param = 0.0;
  else if (opts & EMS_O_Stop)
    param = 1.0;
  else if (opts & EMS_O_Internal)
    param = 0.5;
  else
    {
    BSmdstptcv (meascv, point, &param, dumpt, &dumd, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }

  BSrdcencrcv (&msg_loc, meascv, &param, &dumb, &dumd, &dumd,
   &dumd, &radofcrv, dumpt, dumpt);
  if (msg_loc == BSDGENRAT)
    radofcrv = MAXDOUBLE;
  else
    {EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);}
  
ret_end:
  if (cv.poles)
    om$dealloc (ptr = cv.poles);
  if (cv.knots)
    om$dealloc (ptr = cv.knots);
  if (cv.weights)
    om$dealloc (ptr = cv.weights);

  if (fitcv)
    BSfreecv (&msg_loc, fitcv);

  stat = TRUE;
  EMWRAPUP (*msg, stat, "EMedradofcrv");
  return (radofcrv);
}

end implementation EMSedge;
