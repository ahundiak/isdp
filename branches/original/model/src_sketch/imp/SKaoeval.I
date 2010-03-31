/*

Name
  SKabsornt.SKevaluate

Abstract
  Find the missing coordinate in a absolute angle constraint.  
  
Synopsis

Description
  This method is used to find a missing x or y value for a point that
  is constrained by an absolute angle.  

Return Value

Notes

Index

Keywords

History
  01/29/93 : Rajiv Agrawal : created

 */
class implementation SKabsornt;

#include <math.h>
#include <values.h>
#include "bserr.h"
#include "bsparameters.h"

#define PARALLEL_ANGLE  0.0
#define NORMAL_ANGLE  	90.0
#define COLLINEAR_ANGLE 180.0

#define X 0
#define Y 1

from SKvariable import SKgetvar;

method SKevaluate ( long *msg; unsigned short opts;
                    struct SKsolvevars *tosolvevar;
                    struct SKsolvevars **solvedvars;
                    struct SKsolvevars **nosolution_vars)
{
  IGRboolean         is_parallel, is_normal, is_collinear, is_arbit;
  int                solve_x; 
  long               msg_loc, stat_OM, mask;
  double             angle, p1x, p1y, p2x, p2y, point [3];
  struct SKsolvevars *tmp;
  GRobjid            objids[2], p1, p2;
  struct GRid        my_grid;
  extern void        SKaddvarlist ();
  extern IGRboolean  SKvarlistinx ();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  solve_x = tosolvevar->props & VAR_X;
  mask = solve_x ? VAR_X : VAR_Y;

  stat_OM = om$send ( msg = message SKabsornt.SKgetabsornt 
                            ( &msg_loc, *solvedvars, &angle, objids ), 
                      targetid = my_id );
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase, ret_end );

  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &angle, GRIO_ANGLE, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  if (angle < 0) angle += 180;

  /* add special cases for 0 and 180 degrees also */
  is_parallel = is_normal = is_collinear = is_arbit = FALSE;
  if (fabs (angle - PARALLEL_ANGLE) <= EMS_ZEROANGLE_DEG)
    is_parallel = TRUE;
  else if (fabs (angle - NORMAL_ANGLE) <= EMS_ZEROANGLE_DEG)
    is_normal = TRUE;
  else if (fabs (angle - COLLINEAR_ANGLE) <= EMS_ZEROANGLE_DEG)
    is_collinear = TRUE;
  else
    is_arbit = TRUE;

  /* make p2 the node containing the unknown */
  if (tosolvevar->varobj == objids[0]) 
  {
     p1 = objids[1];
     p2 = objids[0];
  }
  else
  {
     p1 = objids[0];
     p2 = objids[1];
  }

  /* Get the coordinates of the known node */
  if (SKvarlistinx(*solvedvars, p1, VAR_X, &tmp, NULL))
    p1x = tmp->var[X];
  else
    { EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end ); }
  
  if (SKvarlistinx(*solvedvars, p1, VAR_Y, &tmp, NULL))
    p1y = tmp->var[Y];
  else
    { EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end ); }

  if (is_normal)
  {
      if (solve_x) 
         p2x = p1x;
      else
         *msg = EMS_I_NoSolution;
  }
  else if (is_parallel || is_collinear)
  {
      if (solve_x)
         *msg = EMS_I_NoSolution;
      else
         p2y = p1y;
  }
  else
  {
      if (solve_x)
      {
         if (SKvarlistinx(*solvedvars, p2, VAR_Y, &tmp, NULL))
           p2y = tmp->var[Y];
         else
           { EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end ); }
         p2x = p1x + (p2y-p1y)/tan(angle*PI/180.0);
      }
      else
      {
         if (SKvarlistinx(*solvedvars, p2, VAR_X, &tmp, NULL))
           p2x = tmp->var[X];
         else
           { EMerr_hndlr ( TRUE, *msg, EMS_I_Insufficient, ret_end ); }
         p2y = p1y + (p2x-p1x)*tan(angle*PI/180.0);
      }
  }
  
  if (*msg == EMS_S_Success)
     SKaddvarlist(&msg_loc, NULL, solvedvars, mask, p2, my_id, my_id,
                  solve_x ? &p2x : &p2y, NULL);
  else
  {
     om$send (msg = message SKvariable.SKgetvar(&msg_loc, NULL, NULL,
              NULL, point), targetid = p2);
     SKaddvarlist(&msg_loc, NULL, solvedvars, mask, p2, my_id, my_id,
                  &point[solve_x ? 0 : 1], NULL);
     SKaddvarlist(&msg_loc, NULL, nosolution_vars, mask, p2, my_id, my_id,
                  &point[solve_x ? 0 : 1], NULL);
  }     

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKabsornt.SKevaluate");
  return stat_OM;

}

end implementation SKabsornt;

