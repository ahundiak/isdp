class implementation SKaxisptpt;

#include <math.h>

from SKvariable import SKgetvar;

#define X 0
#define Y 1

/*

Name
  SKevaluate

Abstract
  SKevaluate override for a point-to-point distance along meas axis constraint.
  
Synopsis

Description
  This method is used to find a missing x or y value for a point that
  is constrained by a point_to_point distance along a measurement axis. 

Return Value

Notes

Index

Keywords

History
  06/11/92 : Rajiv Agrawal : created

 */

method SKevaluate (IGRlong *msg; unsigned short opts;
                   struct SKsolvevars *tosolvevar;
                   struct SKsolvevars **solvedvars;
                   struct SKsolvevars **nosolution_vars)
{
  long                msg_loc, stat_OM;
  int		      i, j, nb_sol, solve_x;
  GRobjid             objids [4];
  struct GRid         my_grid;
  double              dist, diff_value, distol;
  double	      var[4][2];
  double 	      dx1, dx2, dy1, dy2, a, b, c, sol1, sol2, new_value, 
                      point[3];
  struct SKsolvevars  *varnode;
  extern void         SKaddvarlist();
  extern IGRboolean   SKvarlistinx();
  extern void         SKgettol();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send ( msg = message SKaxisptpt.SKgetptptinfo 
                            ( &msg_loc, *solvedvars, &dist, objids ), 
                      targetid = my_id );
  EMerr_hndlr ( EMSerror(stat_OM & msg_loc), *msg, EMS_E_InvalidCase, ret_end);

  if (ME.SKconstraint->props & SK_HALFVALUE)
    dist /= 2.0;

  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &dist, GRIO_DISTANCE, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  solve_x = tosolvevar->props & VAR_X;
  /*
   * Get the current value of the unknown point.
   */
  stat_OM = om$send ( msg = message SKvariable.SKgetvar (&msg_loc, NULL, NULL, 
                      NULL, point ), targetid = tosolvevar->varobj );
  EMerr_hndlr ( EMSerror(stat_OM & msg_loc), *msg, EMS_E_InvalidCase, ret_end);

  /*
   * Get all the known values from the solvedvars.
   */
  for (i=0; i<4; i++)
  {
    if (tosolvevar->varobj != objids[i])
    {
      for (j=X; j<=Y; j++)
      {
        if (SKvarlistinx ( *solvedvars, objids[i], 
                           (j==X ? VAR_X : VAR_Y), &varnode, NULL ))
          var[i][j] = varnode->var[j];
        else
          EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end );
      }
    }
    else
    {
      if (solve_x)
      {
        if (SKvarlistinx ( *solvedvars, objids[i], VAR_Y, &varnode, NULL )) 
        {
          var[i][Y] = varnode->var[Y];
          var[i][X] = point[X];
        }
        else
          EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end );
      }
      else
      {
        if (SKvarlistinx ( *solvedvars, objids[i], VAR_X, &varnode, NULL )) 
        {
          var[i][X] = varnode->var[X];
          var[i][Y] = point[Y];
        }
        else
          EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end );
      } 
    }
  }
  
  /*
   * Check if we are already at the solution ... if so, skip the rest
   */
  dx1 = var[1][X] - var[0][X];
  dy1 = var[1][Y] - var[0][Y];
  dx2 = var[3][X] - var[2][X];
  dy2 = var[3][Y] - var[2][Y];
  if (me->props & SK_HORIZONTAL)
    diff_value = dx1*dx2 + dy1*dy2 - dist*sqrt(dx2*dx2 + dy2*dy2);
  else
    diff_value = dx1*dx1*dy2*dy2 + dy1*dy1*dx2*dx2 - 2*dx1*dx2*dy1*dy2 -
                 dist*dist*(dx2*dx2 + dy2*dy2);
  
  SKgettol (&distol, NULL);
  if (fabs(diff_value) < distol)
  {
    SKaddvarlist ( &msg_loc, NULL, solvedvars, solve_x ? VAR_X : VAR_Y, 
                   tosolvevar->varobj, my_id, my_id, &point[solve_x ? X : Y], NULL );
    EMerr_hndlr ( EMSerror ( msg_loc ), *msg, EMS_E_Fail, ret_end );
    goto ret_end;
  }
  
  /*
   * Do the computation depending on whether the constraint is horizontal
   * or vertical i.e. along the axis or perpendicular to it.  There are
   * sixteen cases to be taken care of.  8 due to the x,y coordinates,
   * times 2 because of horiz/vert business.  We get 8 different quadratic
   * equations.
   */
  
  if ( tosolvevar->varobj == objids[0] || tosolvevar->varobj == objids[1])
  {
    if (solve_x)
    {
      if (me->props & SK_HORIZONTAL)
      {
        a = dx2*dx2;
        b = 2*dx2*dy1*dy2;
        c = dy1*dy1*dy2*dy2 - dist*dist*(dx2*dx2 + dy2*dy2);
      }
      else
      {
        a = dy2*dy2;
        b = -2*dx2*dy1*dy2;
        c = dy1*dy1*dx2*dx2 - dist*dist*(dx2*dx2 + dy2*dy2);
      }
    }
    else
    { 
      if (me->props & SK_HORIZONTAL)
      {
        a = dy2*dy2;
        b = 2*dx1*dx2*dy2;
        c = dx1*dx1*dx2*dx2 - dist*dist*(dx2*dx2 + dy2*dy2);
      }
      else
      {
        a = dx2*dx2;
        b = -2*dx1*dx2*dy2;
        c = dx1*dx1*dy2*dy2 - dist*dist*(dx2*dx2 + dy2*dy2);
      }
    }
  }
  else
  {
    /*
     * the unknown is one of var[2] or var[3] (axis points).
     */
    if (solve_x)
    {
      if (me->props & SK_HORIZONTAL)
      {
        a = dx1*dx1 - dist*dist;
        b = 2*dx1*dy1*dy2;
        c = (dy1*dy1 - dist*dist)*dy2*dy2;
      }
      else
      {
        a = dy1*dy1 - dist*dist;
        b = -2*dx1*dy1*dy2;
        c = (dx1*dx1 - dist*dist)*dy2*dy2;
      }
    }
    else
    {
      if (me->props & SK_HORIZONTAL)
      {
        a = dy1*dy1 - dist*dist;
        b = 2*dx1*dx2*dy1;
        c = (dx1*dx1 - dist*dist)*dx2*dx2;
      }
      else
      {
        a = dx1*dx1 - dist*dist;
        b = -2*dx1*dx2*dy1;
        c = (dy1*dy1 - dist*dist)*dx2*dx2;
      }
    }
  }


  /*
   * Solve the quadratic and assign the correct solution to the missing
   * variable.  In case of two solutions, determine the solution closest
   * to the previous value.  Note that sol1 and sol2 are only the dx
   * (or dy) values.  The comparisons have to be made with the actual new
   * value.
   */
  nb_sol = SKsolve_second_degree ( a, b, c, &sol1, &sol2);
  if (nb_sol == 1 || nb_sol == 2)
  {
    if (nb_sol == 1)
      sol2 = sol1;

    if (tosolvevar->varobj == objids[0])
    {
      sol1 = var[1][solve_x ? X : Y] - sol1;
      sol2 = var[1][solve_x ? X : Y] - sol2;      
    }
    else if (tosolvevar->varobj == objids[1])
    {
      sol1 = var[0][solve_x ? X : Y] + sol1;
      sol2 = var[0][solve_x ? X : Y] + sol2;      
    }
    else if (tosolvevar->varobj == objids[2])
    {
      sol1 = var[3][solve_x ? X : Y] - sol1;
      sol2 = var[3][solve_x ? X : Y] - sol2;
    }
    else if (tosolvevar->varobj == objids[3])
    {
      sol1 = var[2][solve_x ? X : Y] + sol1;
      sol2 = var[2][solve_x ? X : Y] + sol2;
    }
    new_value = ( fabs(sol1 - point[solve_x ? X : Y]) < 
                  fabs(sol2 - point[solve_x ? X : Y]) ?
                  sol1 : sol2 );
  } 
  else
  {
    new_value = point[solve_x ? X : Y];
    SKaddvarlist ( &msg_loc, NULL, nosolution_vars, solve_x ? VAR_X : VAR_Y,
                   tosolvevar->varobj, my_id, my_id, &new_value, NULL );
    *msg = EMS_I_NoSolution;
  }

  /* 
   * Add the new value to the list of known variables
   */
  SKaddvarlist ( &msg_loc, NULL, solvedvars, solve_x ? VAR_X : VAR_Y, 
                 tosolvevar->varobj, my_id, my_id, &new_value, NULL );
  EMerr_hndlr ( EMSerror ( msg_loc ), *msg, EMS_E_Fail, ret_end );

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKaxisptpt.SKevaluate" );
  return stat_OM;
}

end implementation SKaxisptpt;
