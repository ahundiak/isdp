/*

Name
  SKmakejacobian

Abstract
  Finds the jacobian row for all absolute orientation angle constraints.
  
Synopsis

Description

Return Value

Notes
  We are currently checking the class of the constraint to see if we are
  dealing with a horiz/vert constraint or a fixed angle constraint.  This should be
  changed at a later date and two separate make-jacobian methods should be written.
  
Index

Keywords
  angle

History
  08/02/93 : Rajiv Agrawal : added header and misc cleanup.  Changed the way we determine
                             whether the constraint is horiz/vert or a fixed angle. (TR11920316).

  12/10/93 : Rajiv Agrawal : Update unsolved vars based on solved vars.
  07/04/95 : Satya         : Modified the funcval and jacobian methods for
                             fixed angles placed wrt to vertical axis
                             from cos based equations to sin based equations.
                             -- Satya -- TR# 119524848
 */

class implementation SKabsornt;

#include <math.h>
#include <values.h>
#include "bsvalues.h"
#include "emsdebug.h"

#define SOLVED -1

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1
#define VAL 0

#define X1 0
#define Y1 1
#define X2 2
#define Y2 3
#define V  4

%safe
static double corrected_cosang (double ang);
static double corrected_sinang (double ang);
%endsafe

extern GRclassid OPP_SKfixang_class_id, OPP_SKhorizvert_class_id;
from SKvariable import SKgetvar;

method SKmakejacobian ( long *msg; unsigned short options;
                        struct SKsolvevars *solvedvars, *unsolvedvars;
                        double *jacobian; double *funcval )
{
  IGRboolean         is_horiz, is_verti, is_arbit, is_pseudo, unknown_angle;
  IGRboolean         adjreq, accreq;
  IGRboolean         horizontal;
  long               stat_OM, msg_loc;
  int                i, var_inx [5], varinx;
  double             angle, delx, dely, len, trigval, var[5];
  double             rad_angle, diff_value = 0.0, tol;
  double             point[2][3];
  OM_S_OBJID         pt_obj[2];
  struct GRid	     my_grid;
  GRclassid 	     myclass;
  struct SKsolvevars *varnode[5];
  extern IGRboolean  SKvarlistinx ();

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * Obtain the two points making up this constraint. Also the orientation of
   * the logical line segment that this object is constraining. If
   * no value found for the orientation, insuffucient information is
   * present for execution. So exit.
   */

  horizontal = ME.SKconstraint->props & SK_HORIZONTAL;
  stat_OM = om$send ( msg = message SKabsornt.SKgetabsornt ( &msg_loc,
                           solvedvars, &angle, pt_obj ), 
                     targetid = my_id );
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase, ret_end);

  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &angle, GRIO_ANGLE, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  om$get_classid ( objid = my_id, p_classid = &myclass );

  is_horiz = is_verti = is_arbit = is_pseudo = unknown_angle = FALSE;
  if (msg_loc == EMS_I_NotFound)
  {
    unknown_angle = TRUE;
    is_arbit = TRUE;
  }
  else
  {
    if (myclass == OPP_SKfixang_class_id)
      is_arbit = TRUE;
    else if (myclass == OPP_SKhorizvert_class_id && 
             (ME.SKconstraint->props & SK_HORIZONTAL))
      is_horiz = TRUE;
    else if (myclass == OPP_SKhorizvert_class_id)
      is_verti = TRUE;
    else
      EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);
  }

  if (options & SK_JACOB_PSEUDO_EQN)
    is_pseudo = TRUE;

  /*
   * Determine the unknown variables in this equation and obtain their indices.
   * Also, find out the current values of the involved variables (both
   * known and unknown). The value of this constraint itself may be treated
   * as a variable to solve for. Take this into account.
   */

  if (!is_pseudo && (is_horiz || is_arbit))
  {
    if (SKvarlistinx ( unsolvedvars, pt_obj[FIRST], VAR_Y, &varnode[Y1], &varinx ))
      var_inx [Y1] = varinx;
    else if (SKvarlistinx ( solvedvars, pt_obj [FIRST], VAR_Y, &varnode[Y1], &varinx ))
      var_inx [Y1] = SOLVED;
    else
     {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

    if (SKvarlistinx (unsolvedvars, pt_obj[SECOND], VAR_Y, &varnode[Y2], &varinx))
      var_inx [Y2] = varinx;
    else if (SKvarlistinx ( solvedvars, pt_obj[SECOND], VAR_Y, &varnode[Y2], &varinx ))
      var_inx [Y2] = SOLVED;
    else
     {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
  }

  if (!is_pseudo && (is_verti || is_arbit))
  {
    if (SKvarlistinx ( unsolvedvars, pt_obj[FIRST], VAR_X, &varnode[X1], &varinx ))
      var_inx [X1] = varinx;
    else if (SKvarlistinx (solvedvars, pt_obj [FIRST], VAR_X, &varnode[X1], &varinx))
      var_inx[X1] = SOLVED;
    else
     {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

    if (SKvarlistinx ( unsolvedvars, pt_obj[SECOND], VAR_X, &varnode[X2], &varinx ))
      var_inx [X2] = varinx;
    else if (SKvarlistinx ( solvedvars, pt_obj [SECOND], VAR_X, &varnode[X2], &varinx ))
      var_inx [X2] = SOLVED;
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
    
    if (is_horiz || is_arbit) 
    {
      if (var_inx[Y1] != SOLVED && var_inx[Y2] == SOLVED)
        varnode[Y1]->var[Y] = point[FIRST][Y] + (varnode[Y2]->var[Y] - point[SECOND][Y]);
      else if (var_inx[Y2] != SOLVED && var_inx[Y1] == SOLVED)
        varnode[Y2]->var[Y] = point[SECOND][Y] + (varnode[Y1]->var[Y] - point[FIRST][Y]);
    }

    if (is_verti || is_arbit) 
    {
      if (var_inx[X1] != SOLVED && var_inx[X2] == SOLVED)
        varnode[X1]->var[X] = point[FIRST][X] + (varnode[X2]->var[X] - point[SECOND][X]);
      else if (var_inx[X2] != SOLVED && var_inx[X1] == SOLVED)
        varnode[X2]->var[X] = point[SECOND][X] + (varnode[X1]->var[X] - point[FIRST][X]);
    }
  }

  if (!is_pseudo && (is_horiz || is_arbit))
  {
    var[Y1] = varnode[Y1]->var[Y];
    var[Y2] = varnode[Y2]->var[Y];
  }

  if (!is_pseudo && (is_verti || is_arbit))
  {
    var[X1] = varnode[X1]->var[X];
    var[X2] = varnode[X2]->var[X];
  }

  if ((options & SK_JACOB_PSEUDO_VAR || options & SK_JACOB_PSEUDO_EQN) &&
      SKvarlistinx ( unsolvedvars, my_id, VAR_PSEUDO_VAL, &varnode[V], &varinx ))
  {
    var_inx [V] = varinx;
    var[V] = varnode[V]->var[VAL];
  }
  else
  {
    var_inx [V] = SOLVED;
    if (!unknown_angle)
      var [V] = angle;
    else
    {
      EMerr_hndlr ( TRUE, *msg, EMS_E_InvalidArg, ret_end );
    }
  }

  /*
   * Plug in the appropriate values in the row of the Jacobian matrix
   */

  adjreq = options & SK_JACOB_ADJACENCY;
  accreq = options & SK_JACOB_ACCURACY;

  if (is_pseudo)
  {
    if ((var_inx [V] != SOLVED) && jacobian)
      jacobian [var_inx [V]] = adjreq ? TRUE : 1;

    if (funcval)
      *funcval = 0.0;

    if (accreq)
      diff_value = 0.0;
  }
  else if (is_horiz)
  {
    if (jacobian)
    {
      if (var_inx [Y1] != SOLVED)
        jacobian [var_inx [Y1]] = adjreq ? TRUE : -1;
      if (var_inx [Y2] != SOLVED)
        jacobian [var_inx [Y2]] = adjreq ? TRUE : 1;
    }

    if (funcval)
      *funcval = -(var [Y2] - var [Y1]);

    if (accreq)
      diff_value = fabs ( var [Y2] - var [Y1] );
  }
  else if (is_verti)
  {
    if (jacobian)
    {
      if (var_inx [X1] != SOLVED)
        jacobian[var_inx [X1]] = adjreq ? TRUE : -1;
      if (var_inx[X2] != SOLVED)
        jacobian[var_inx [X2]] = adjreq ? TRUE : 1;
    }
    if (funcval)
      *funcval = -(var[X2] - var[X1]);
    if (accreq)
      diff_value = fabs (var[X2] - var[X1]);
  }
  else
  {
    delx = var[X2] - var[X1];
    dely = var[Y2] - var[Y1];
    len = sqrt ( delx * delx + dely * dely );
    if(horizontal)
      trigval = cos ( angle * (M_PI / 180.0) );
    else
      trigval = sin(angle * (M_PI / 180.0) );

    if (jacobian)
    {
      if(horizontal)
      {
        if (var_inx[X1] != SOLVED)
          jacobian[var_inx[X1]] = adjreq ? TRUE : (-1 + trigval * delx / len);
        if (var_inx[Y1] != SOLVED)
          jacobian[var_inx[Y1]] = adjreq ? TRUE : (trigval * dely / len);
        if (var_inx[X2] != SOLVED)
          jacobian[var_inx[X2]] = adjreq ? TRUE : (1 - trigval * delx / len);
        if (var_inx[Y2] != SOLVED)
          jacobian[var_inx[Y2]] = adjreq ? TRUE : (-trigval * dely / len);
        if (var_inx[V] != SOLVED)
          jacobian[var_inx[V]] = adjreq ? TRUE : (-sin ( angle * 
			         (M_PI / 180.0)) * len);
      }
      else
      {

        if (var_inx[X1] != SOLVED)
          jacobian[var_inx[X1]] = adjreq ? TRUE : (trigval * delx / len);
        if (var_inx[Y1] != SOLVED)
          jacobian[var_inx[Y1]] = adjreq ? TRUE : (-1 + trigval * dely / len);
        if (var_inx[X2] != SOLVED)
          jacobian[var_inx[X2]] = adjreq ? TRUE : (-trigval * delx / len);
        if (var_inx[Y2] != SOLVED)
          jacobian[var_inx[Y2]] = adjreq ? TRUE : (1 + -trigval * dely / len);
        if (var_inx[V] != SOLVED)
          jacobian[var_inx[V]] = adjreq ? TRUE : (cos ( angle * 
				 (M_PI / 180.0) ) * len);
      }
    }
    if (funcval)
    {
      if(horizontal)
        *funcval = -(delx - trigval * len);
      else
        *funcval = -(dely - trigval * len);
    }

    if (accreq)
    {
      rad_angle = angle * (M_PI / 180.0);
      if(horizontal)
        diff_value = fabs (acos (delx / len) - corrected_cosang (rad_angle));
      else
        diff_value = fabs (asin (dely / len) - corrected_sinang (rad_angle));
    }

  }

  /*
   * If the option to check accuracy was set then obtain the relevant
   * tolerances and check.
   */

  if (accreq)
  {
    if (!is_horiz && !is_verti)
    {
      SKgettol ( NULL, &tol );
      tol = tol * (M_PI / 180.0);
    }
    else
      SKgettol ( &tol, NULL );

    if (diff_value > tol)
      *msg = EMS_I_OutOfBounds;
  }

  DEBUG_REPORT (accreq, "Absangle residual", my_id, diff_value);

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKabsornt.SKmakejacobian" );
  return stat_OM;
}

/*--------------------- STATIC FUNCTIONS ----------------------------------*/

/*
  ABSTRACT

  This function takes in a raw angle in radians and returns one that ranges
  from 0 to PI (inclusive), ie, either the first or the second quadrant.
  The cosine of the angle being returned will be identically equal to the
  cosine of the input angle
*/

static double corrected_cosang (double ang)
{
  ang = ang - ((int) (ang / (2 * M_PI))) * (2 * M_PI);
  if(ang < 0.0)
    ang = ang + (2 * M_PI);
  ang = ang > (M_PI) ? (2 * M_PI - ang) : ang;
  return (ang);
}

/*
  ABSTRACT

  This function takes in a raw angle in radians and returns one that lies
  from -PI/2 to PI/2 (inclusive), ie, either in the first or the fourth 
  quadrant. The cosine of the angle being returned will be identically equal
  to the cosine of the input angle
*/

static double corrected_sinang (double ang)
{
  ang = ang - ((int) (ang / (2 * M_PI))) * (2 * M_PI);
  if(ang < 0.0)
    ang = ang + (2 * M_PI);
  ang = ang > (M_PI / 2 ) && ang < (3 * M_PI / 2) ? (M_PI - ang) : ang;
  ang = ang >= (3 * M_PI / 2) ? (ang - (2 * M_PI)) : ang;
  return (ang);
}

end implementation SKabsornt;

