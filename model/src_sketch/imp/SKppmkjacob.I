class implementation SKptpt;

#include <math.h>
#include "emsdebug.h"

#define SOLVED -1

#define FIRST  0
#define SECOND 1

#define X   0
#define Y   1
#define VAL 0

#define X1 0
#define Y1 1
#define X2 2
#define Y2 3
#define V  4

from SKvariable import SKgetvar;

/*

Name
  SKmakejacobian

Abstract
  Build a jacobian row for a point-to-point distance constraint.
  
Synopsis

Description

Return Value

Notes

Index

Keywords
  constraint

History
  10/19/93 : Rajiv Agrawal : cleanup and added a doc. header
  12/10/93 : Rajiv Agrawal : Update unsolved vars based on solved vars.

 */
method SKmakejacobian (IGRlong *msg; IGRushort options;
                       struct SKsolvevars *solvedvars, *unsolvedvars;
                       IGRdouble *jacobian; IGRdouble *funcval)
{
  IGRboolean            is_ptpt, is_vpt, is_hpt, is_pseudo, unknown_value, 
                        adjreq, accreq;
  long                  stat_OM, msg_loc;
  int                   i, var_inx[5], varinx;
  double                diff_value=0.0, value, distol, var[5], delx, dely;
  double 		point[2][3];
  GRclassid             myclassid;
  GRobjid               pt_obj[2];
  struct GRid           my_grid;
  struct SKsolvevars    *varnode[5];
  extern IGRboolean     SKvarlistinx();
  
  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * Obtain the two points making up this constraint. Pt1 is on the left
   * and Pt2 is on the right. Obtain the type of the dimensional constraint
   * that I am. Also obtain the value of my dimension. It may have been
   * computed externally (found in solvedvars) or may be obtained from my
   * instance data.
   */

  stat_OM = om$send (msg = message SKptpt.SKgetptptinfo (&msg_loc, solvedvars,
                           &value, pt_obj), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase, ret_end);

  if (msg_loc == EMS_I_NotFound)
    unknown_value = TRUE;
  else
    unknown_value = FALSE;

  is_hpt = is_vpt = is_ptpt = is_pseudo = FALSE;
  om$get_classid (object = me, p_classid = &myclassid);
  if (myclassid == OPP_SKptpt_class_id) 
    is_ptpt = TRUE;
  else if (ME.SKconstraint->props & SK_HORIZONTAL)
    is_hpt = TRUE;
  else
    is_vpt = TRUE;

  if (options & SK_JACOB_PSEUDO_EQN)
    is_pseudo = TRUE;

 /*
  * Determine the unknown variables in this equation and obtain their indices.
  * Also, find out the current values of the involved variables (both
  * known and unknown). The value of this constraint itself may be treated
  * as a variable to solve for. Take this into account.
  */

  if (!is_pseudo && (is_hpt || is_ptpt))
  {
    if (SKvarlistinx (unsolvedvars, pt_obj[FIRST], VAR_X, &varnode[X1], &varinx))
      var_inx[X1] = varinx;
    else if (SKvarlistinx (solvedvars, pt_obj[FIRST], VAR_X, &varnode[X1], &varinx))
      var_inx[X1] = SOLVED;
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

    if (SKvarlistinx (unsolvedvars, pt_obj[SECOND], VAR_X, &varnode[X2], &varinx))
      var_inx[X2] = varinx;
    else if (SKvarlistinx (solvedvars, pt_obj[SECOND], VAR_X, &varnode[X2], &varinx)) 
      var_inx[X2] = SOLVED;
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
  }

  if (!is_pseudo && (is_vpt || is_ptpt))
  {
    if (SKvarlistinx (unsolvedvars, pt_obj[FIRST], VAR_Y, &varnode[Y1], &varinx))
      var_inx[Y1] = varinx;
    else if (SKvarlistinx (solvedvars, pt_obj[FIRST], VAR_Y, &varnode[Y1], &varinx)) 
      var_inx[Y1] = SOLVED;
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

    if (SKvarlistinx (unsolvedvars, pt_obj[SECOND], VAR_Y, &varnode[Y2], &varinx))
      var_inx[Y2] = varinx;
    else if (SKvarlistinx (solvedvars, pt_obj[SECOND], VAR_Y, &varnode[Y2], &varinx)) 
      var_inx[Y2] = SOLVED;
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
  }

  /*
   * If we want to take a better guess at the solution, we can see if any
   * of the connected variables are known.  Based on their change, we can
   * update the unsolvedvars value.
   */
  if (!is_pseudo && options & SK_JACOB_UPDATE_GUESS)
  {
    for (i=FIRST; i<=SECOND; i++)
    {
      stat_OM = om$send ( msg = message SKvariable.SKgetvar 
                                (&msg_loc, NULL, NULL, NULL, point[i]),
                          targetid = pt_obj[i]);
    }
    
    if (is_hpt || is_ptpt) 
    {
      if (var_inx[X1] != SOLVED && var_inx[X2] == SOLVED)
        varnode[X1]->var[X] = point[FIRST][X] + (varnode[X2]->var[X] - point[SECOND][X]);
      else if (var_inx[X2] != SOLVED && var_inx[X1] == SOLVED)
        varnode[X2]->var[X] = point[SECOND][X] + (varnode[X1]->var[X] - point[FIRST][X]);
    }
    if (is_vpt || is_ptpt) 
    {
      if (var_inx[Y1] != SOLVED && var_inx[Y2] == SOLVED)
        varnode[Y1]->var[Y] = point[FIRST][Y] + (varnode[Y2]->var[Y] - point[SECOND][Y]);
      else if (var_inx[Y2] != SOLVED && var_inx[Y1] == SOLVED)
        varnode[Y2]->var[Y] = point[SECOND][Y] + (varnode[Y1]->var[Y] - point[FIRST][Y]);
    }
  }

  if (!is_pseudo && (is_hpt || is_ptpt))
  {
    var[X1] = varnode[X1]->var[X];
    var[X2] = varnode[X2]->var[X];
  }
  
  if (!is_pseudo && (is_vpt || is_ptpt))
  {
    var[Y1] = varnode[Y1]->var[Y];
    var[Y2] = varnode[Y2]->var[Y];
  }

  if ((options & SK_JACOB_PSEUDO_VAR || options & SK_JACOB_PSEUDO_EQN) &&
       SKvarlistinx (unsolvedvars, my_id, VAR_PSEUDO_VAL, &varnode[V], &varinx))
  {
    var_inx[V] = varinx;
    var[V] = varnode[V]->var[VAL];
  }
  else
  {
    var_inx[V] = SOLVED;
    if (!unknown_value)
      var[V] = value;
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
  }

  if (ME.SKconstraint->props & SK_HALFVALUE)
    var[V] /= 2.0;

  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &var[V], GRIO_DISTANCE, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  /*
   * Plug in the appropriate values in the row of the Jacobian matrix
   */
 
  adjreq = options & SK_JACOB_ADJACENCY;
  accreq = options & SK_JACOB_ACCURACY;
  
  if (is_pseudo)
  {
    if (jacobian)
    {
      if (var_inx[V] != SOLVED)
        jacobian[var_inx[V]] = adjreq ? TRUE : 1;
    }
 
    if (funcval)
      *funcval = 0.0;
 
    if (accreq)
      diff_value = 0.0;
  }
  else if (is_hpt)
  {
    if (jacobian)
    {
      if (var_inx[X1] != SOLVED)
        jacobian[var_inx[X1]] = adjreq ? TRUE : -1;
      if (var_inx[X2] != SOLVED)
        jacobian[var_inx[X2]] = adjreq ? TRUE : 1;
      if (var_inx[V] != SOLVED)
        jacobian[var_inx[V]] = adjreq ? TRUE : -1;
    }
 
    if (funcval)
      *funcval = -(var[X2] - var[X1] - var[V]);
 
    if (accreq)
      diff_value = fabs (fabs (var[X2] - var[X1]) - var[V]);
  }
  else if (is_vpt)
  {
    if (jacobian)
    {
      if (var_inx[Y1] != SOLVED)
        jacobian[var_inx[Y1]] = adjreq ? TRUE : -1;
      if (var_inx[Y2] != SOLVED)
        jacobian[var_inx[Y2]] = adjreq ? TRUE : 1;
      if (var_inx[V] != SOLVED)
        jacobian[var_inx[V]] = adjreq ? TRUE : -1;
    }
 
    if (funcval)
      *funcval = -(var[Y2] - var[Y1] - var[V]);
 
    if (accreq)
      diff_value = fabs (fabs (var[Y2] - var[Y1]) - var[V]);
  }
  else
  {
    delx = var[X2] - var[X1];
    dely = var[Y2] - var[Y1];
 
    if (jacobian)
    {
      if (var_inx[X1] != SOLVED)
        jacobian[var_inx[X1]] = adjreq ? TRUE : (-2.0 * delx);
      if (var_inx[Y1] != SOLVED)
        jacobian[var_inx[Y1]] = adjreq ? TRUE : (-2.0 * dely);
      if (var_inx[X2] != SOLVED)
        jacobian[var_inx[X2]] = adjreq ? TRUE : (2.0 * delx);
      if (var_inx[Y2] != SOLVED)
        jacobian[var_inx[Y2]] = adjreq ? TRUE : (2.0 * dely);
      if (var_inx[V] != SOLVED)
        jacobian[var_inx[V]] = adjreq ? TRUE : (-2.0 * var[V]);
    }
 
    if (funcval)
      *funcval = -(delx * delx + dely * dely - var[V] * var[V]);
 
    if (accreq)
      diff_value = fabs (sqrt (delx * delx + dely * dely) - fabs(var[V]));
  }

  /*
   * If the option to check accuracy was set then obtain the relevant
   * tolerances and check.
   */

  if (accreq)
  {
    SKgettol (&distol, NULL);
    if (diff_value > distol)
      *msg = EMS_I_OutOfBounds;
  }

  DEBUG_REPORT (accreq, "Pt-Pt residual", my_id, diff_value);

ret_end:
 EMWRAPUP(*msg, stat_OM, "SKptpt.SKmakejacobian");
 return (stat_OM);
}

end implementation SKptpt;

