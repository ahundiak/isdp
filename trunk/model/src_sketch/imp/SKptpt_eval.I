class implementation SKptpt;

#include <math.h>

extern GRclassid OPP_SKhvptpt_class_id;

from SKvariable import SKgetvar;

#define EPSILONN 0.0000000001
#define X	0
#define Y	1

/*

Name
  SKevaluate

Abstract
  SKevaluate override for a point-to-point constraint.
  
Synopsis

Description
    This method is used to find a missing x or y value for a point that
    is constrained by a point_to_point distance.  It can also be
    used to compute the value of pseudovar associated with the
    distance (generally happens for arcs).  

Return Value

Notes

Index

Keywords
  constraint, evaluate

History
    HB  :           : Creation.
    RA  :  1/12/92  : Fixed a bug when the value of the pseudovar was
                      being returned incorrectly.
    RA  :  1/24/92  : Fixed a bug when a horizontal or vertical constraint
                      was used to compute an unknown.
    RA  :  1/28/92  : Complete rewrite of the part when the line is
                      inclined to use the current values from solvedvars.
  09/02/93 : Rajiv Agrawal : Use the sign of the previous distance to decide between 2 
                             solutions.
  10/19/93 : Rajiv Agrawal : Big bug fixed in the code when the constraint 
                             itself was being solved.
  01/20/94 : Satya : Use the sign as well as value to determine if an SKptpt constraint
                     needs to be re-solved.  (TR119415803)

 */

method SKevaluate (IGRlong *msg; IGRushort opts;
                   struct SKsolvevars *tosolvevar;
                   struct SKsolvevars **solvedvars;
                   struct SKsolvevars **nosolution_vars)
{
  int                 nb_sol, solve_x, old_sign, new_sign;
  long                msg_loc, stat_OM;
  double              x, y, p1x, p1y, p2x, p2y, x1, x2, point [2][3], new_value;
  double              dist, diff_value, distol;
  GRobjid             objids [2];
  GRclassid	      myclassid;
  GRobjid             var, p1, p2;
  struct GRid         my_grid;
  struct SKsolvevars  *varnode_known_x, *varnode_known_y, *varnode;
  extern void         SKaddvarlist();
  extern IGRboolean   SKvarlistinx();
  extern void         SKgettol();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  om$send ( msg = message SKptpt.SKgetptptinfo ( msg, *solvedvars, &dist, objids ), 
            targetid = my_id );

  if (ME.SKconstraint->props & SK_HALFVALUE)
    dist /= 2.0;

  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (msg, &my_grid, &dist, GRIO_DISTANCE, TRUE);
    EMerr_hndlr (EMSerror (*msg), *msg, EMS_E_Fail, ret_end);
  }

  /*
   * If I am the unknown, then my defining variables would already be known.
   * Just extract them from the solvedvars list and compute my value and
   * add myself to the known list.
   */
  if (tosolvevar->varobj == my_id)
  {
    if (SKvarlistinx(*solvedvars, objids[0], VAR_X, &varnode, NULL))
      p1x = varnode->var[0];
    else
      {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
    if (SKvarlistinx(*solvedvars, objids[0], VAR_Y, &varnode, NULL))
      p1y = varnode->var[1];
    else
      {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
    if (SKvarlistinx(*solvedvars, objids[1], VAR_X, &varnode, NULL))
      p2x = varnode->var[0];
    else
      {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
    if (SKvarlistinx(*solvedvars, objids[1], VAR_Y, &varnode, NULL))
      p2y = varnode->var[1];
    else
      {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
    dist = sqrt((p2x-p1x)*(p2x-p1x)+(p2y-p1y)*(p2y-p1y));
    SKaddvarlist ( msg, NULL, solvedvars, VAR_PSEUDO_VAL, my_id, my_id, 
                   my_id, &dist, NULL );
    goto ret_end;
  }
  

  /*
   * Check if the point to point constraint is actually a horizontal 
   * or vertical constraint (stacked/string linear dimension).
   */
  om$get_classid ( object = me, p_classid = &myclassid );
  if (om$is_ancestry_valid ( subclassid = myclassid,
                             superclassid = OPP_SKhvptpt_class_id) == OM_S_SUCCESS)
  {
    if (me->props & SK_HORIZONTAL)
    { 
      if (SKvarlistinx ( *solvedvars, objids[0], 
                         VAR_X, &varnode_known_x, NULL ))
      {
         x = varnode_known_x->var [0] + dist;
         var = objids[1];
      }
      else
         if (SKvarlistinx ( *solvedvars, objids[1], 
                            VAR_X, &varnode_known_x, NULL ))
         {
            x = varnode_known_x->var [0] - dist;
            var = objids[0];
         }
      else
         EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end );

      SKaddvarlist ( msg, NULL, solvedvars, VAR_X, var, my_id, my_id, &x, NULL );
    }
    else
    {
      if (SKvarlistinx ( *solvedvars, objids[0], 
                         VAR_Y, &varnode_known_y, NULL ))
      {
         y = varnode_known_y->var [1] + dist;
         var = objids[1];
      }
      else
         if (SKvarlistinx ( *solvedvars, objids[1], 
                            VAR_Y, &varnode_known_y, NULL ))
         {
            y = varnode_known_y->var [1] - dist;
            var = objids[0];
         }
      else
         EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end );

      SKaddvarlist ( msg, NULL, solvedvars, VAR_Y, var, my_id, my_id, &y, NULL );
    }
  }
  else
  {
    solve_x = tosolvevar->props & VAR_X;

    /* make p1 the unknown object id */

    if (tosolvevar->varobj == objids[0]) 
    {
       p1 = objids[0];
       p2 = objids[1];
    }
    else
    {
       p1 = objids[1];
       p2 = objids[0];
    }      

    om$send ( msg = message SKvariable.SKgetvar 
                    ( msg, NULL, NULL, NULL, point[0] ),
              targetid = p1 );
    om$send ( msg = message SKvariable.SKgetvar 
                    ( msg, NULL, NULL, NULL, point[1] ),
              targetid = p2 ); 

    if (SKvarlistinx ( *solvedvars, p2, VAR_X, &varnode_known_x, NULL ))
      p2x = varnode_known_x->var[0];
    else
      { EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end ); }
    if (SKvarlistinx ( *solvedvars, p2, VAR_Y, &varnode_known_y, NULL ))
      p2y = varnode_known_y->var[1];
    else
      { EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end ); }
    
    if (solve_x) 
    {
       if (SKvarlistinx ( *solvedvars, p1, VAR_Y, &varnode_known_y, NULL )) 
       {
         p1y = varnode_known_y->var[1];
         p1x = point[0][X];
         old_sign = (p1x > point[1][X]) ? 1 : -1;
         new_sign = (p1x > p2x ) ? 1 : -1; 
       }
       else
         {EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end );}
    }
    else
    {
       if (SKvarlistinx ( *solvedvars, p1, VAR_X, &varnode_known_x, NULL ))
       {
         p1x = varnode_known_x->var[0];
         p1y = point[0][Y];
         old_sign = (p1y > point[1][Y]) ? 1 : -1;
         new_sign = (p1y > p2y ) ? 1 : -1; 
       }
       else
         {EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end );}
    }
    
    /*
     * Skip the solution process if we are already at the solution.
     */
    
    diff_value = dist - sqrt((p2x-p1x)*(p2x-p1x) + (p2y-p1y)*(p2y-p1y));
    SKgettol (&distol, NULL);
    if ( fabs(diff_value) < distol && (new_sign == old_sign))
    {
      SKaddvarlist ( &msg_loc, NULL, solvedvars, solve_x ? VAR_X : VAR_Y, 
                     tosolvevar->varobj, my_id, my_id, &point[0][solve_x ? X : Y], NULL );
      EMerr_hndlr ( EMSerror ( msg_loc ), *msg, EMS_E_Fail, ret_end );
      goto ret_end;
    }

    if (solve_x)
      /* p1x is unknown */
      nb_sol = SKsolve_second_degree ( 1.0, -2.0 * p2x, 
                                       -(dist * dist - p2x * p2x - p1y * p1y -
                                         p2y * p2y + 2.0 * p1y * p2y), 
                                       &x1, &x2 );
    else
      /* p1y is unknown */
      nb_sol = SKsolve_second_degree ( 1.0, -2.0 * p2y, 
                                       -(dist * dist - p2x * p2x - p1x * p1x -
                                         p2y * p2y + 2.0 * p1x * p2x), 
                                       &x1, &x2 );

    if (nb_sol == 1) 
       new_value = x1;
    else if (nb_sol == 2)
    {
       /* 
        * if 2 solutions, choose the one that preserves the direction from the
        * previous point (the one that is known).
        */
       if (solve_x)
         new_sign = (x1 > p2x ) ? 1 : -1;
       else
         new_sign = (x1 > p2y ) ? 1 : -1;
       new_value = (old_sign == new_sign) ? x1 : x2;
    }
    else
    {
      new_value = solve_x ? point[0][X] : point[0][Y];
      SKaddvarlist ( &msg_loc, NULL, nosolution_vars, solve_x ? VAR_X : VAR_Y,
                     tosolvevar->varobj, my_id, my_id, &new_value, NULL );
      *msg = EMS_I_NoSolution;
    }

    /* add the new value to the list of known variables */
    SKaddvarlist ( &msg_loc, NULL, solvedvars, solve_x ? VAR_X : VAR_Y, 
                   p1, my_id, my_id, &new_value, NULL );
    EMerr_hndlr ( EMSerror ( msg_loc ), *msg, EMS_E_Fail, ret_end );
  }

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKptpt.SKevaluate" );
  return stat_OM;
}


int SKsolve_second_degree ( a, b, c, px1, px2 )
                            double a, b, c	/* The coefficients	IN  */;
                            double *px1, *px2	/* The solutions	OUT */;
/*
   This routine computes the solution of a*x*x + b*x + c where x is the
   unknown.  Handles the case when a=0 (line equation).
*/
{
  double rho;
  
  if ((fabs ( a ) < EPSILONN) && (fabs ( b ) < EPSILONN))
    return 0;
  else if ((fabs ( a ) < EPSILONN) && (fabs ( b ) > EPSILONN))
  {
      *px1 = -c / b;
      
      return 1;
  }
  else
  {  
     rho = b*b - 4*a*c;
     if (fabs(rho) < EPSILONN) 
     {
        *px1 = -0.5*b/a;
        return 1;
     }
     else if (rho > 0)
     {
        double tmp = sqrt ( rho );
        
        *px1 = -(b - tmp) / ( 2.0 * a );
        *px2 = -(b + tmp) / ( 2.0 * a );
        
        return 2;
     }
     else
        return 0;
  }
}

end implementation SKptpt;

