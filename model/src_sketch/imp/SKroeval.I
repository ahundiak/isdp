/*

Name
  SKevaluate

Abstract
  Finds the missing coordinate using the angle relation.
  
Synopsis

Description
    This method is used to find a missing x or y value for a point that
    is constrained by an angle.  Both 3-point and 4-point angles are
    considered.  If the x or y value of the midpoint of a 3-point 
    angle is being computed, we need to use a special geometric
    construction.

Return Value

Notes
   In case of a 3-pt angle, when the common point has the unknown x or y, we
   fit a circle and intersect it with the known coordinate.
   
   In case of four points, p0, p1, p2 and p3, we orient ourselves such 
   that p3 contains the unknown (x or y coordinate).
     
                                     . p3
                                    /
                                   /
                                  /  
                                 / 
                              p2.       angle (0-180)

                                  p0 .---------. p1
  
   To compute for the unknown, we rotate the vector p0-p1 by the angle and
   equate the slopes.

Index

Keywords

History
  ???????  : HB  : Creation.
  1/12/92  : RA  : Added code for 3-point angles when the midpoint
                   is unknown.
  8/20/92  : RA  : Handle 3-point collinear special case.
  07/02/93 : Sudha : Modified for BSprototypes ansification
  09/27/93 : Rajiv Agrawal : Fixed some logic bugs in case of 3-pt general angle.
  11/15/93 : Rajiv Agrawal : Complete rewrite of the general 4-pt angle case.  No more
                             solving of a quadratic equation.  Simple rotation does
                             the trick.
  12/28/93 : Rajiv Agrawal : Added a case for CW rotation for 3-pt SK_SUPPLEMENT type 
                             angles (TR119305759).
 */
class implementation SKrelornt;

#include <math.h>
#include <values.h>
#include "bserr.h"
#include "bsparameters.h"
#include "maang2vc.h"

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
  IGRboolean 	     solution_found;
  int                solve_x, nb_sol; 
  long               msg_loc, stat_OM, mask;
  double             b, c, sol, sol1, sol2, x1, y1, angle, cosang, sinang;
  double 	     p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, point [3];
  double             ang[3], difmin;
  IGRvector          vec1, vec2;
  struct SKsolvevars *tmp;
  struct GRid	     my_grid;
  GRobjid            ptobjs [2][2], p0, p1, p2, p3;
  IGRdouble          lentol;
  extern void        SKaddvarlist ();
  extern IGRboolean  SKvarlistinx ();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);

  solve_x = tosolvevar->props & VAR_X;
  mask = solve_x ? VAR_X : VAR_Y;

  stat_OM = om$send ( msg = message SKrelornt.SKgetrelornt ( &msg_loc,
                            *solvedvars, &angle, ptobjs ), 
                      targetid = my_id );
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase, ret_end );

  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &angle, GRIO_ANGLE, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  if (ME.SKconstraint->props & SK_SUPPLEMENT)
    angle = 180.0 - angle;

  if (angle < 0)
    angle += 180.0;

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

  /*
   * Special case handling ... angle defined by 3 points and one of
   * coordinates of the common point is unknown (call it p0).
   */
  if (tosolvevar->varobj == ptobjs[0][0] && 
      tosolvevar->varobj == ptobjs[1][0] ) 
  {
      p0 = ptobjs[0][0];
      p1 = ptobjs[0][1];
      p2 = ptobjs[1][1];

      om$send( msg = message SKvariable.SKgetvar
                     (&msg_loc, NULL, NULL, NULL, point), 
               targetid = p0);

      if (SKvarlistinx ( *solvedvars, p1, VAR_X, &tmp, NULL ))
        p1x = tmp->var [X];
      else
        {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
      if (SKvarlistinx ( *solvedvars, p1, VAR_Y, &tmp, NULL ))
        p1y = tmp->var [Y];
      else
        {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
      if (SKvarlistinx ( *solvedvars, p2, VAR_X, &tmp, NULL ))
        p2x = tmp->var [X];
      else
        {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
      if (SKvarlistinx ( *solvedvars, p2, VAR_Y, &tmp, NULL ))
        p2y = tmp->var [Y];
      else
        {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
      if (SKvarlistinx ( *solvedvars, p0, solve_x ? VAR_Y : VAR_X, &tmp, NULL ))
      {
        if (solve_x) 
        {
           p0y = tmp->var [Y];
           p0x = point[X];
        }
        else
        {
           p0x = tmp->var [X];
           p0y = point[Y];
        }
      }
      else
        {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
      
      /*
       * Check if we already at the solution ... if so skip ..
       */
      vec1[0] = p1x - p0x; vec1[1] = p1y - p0y; vec1[2] = 0;
      vec2[0] = p2x - p0x; vec2[1] = p2y - p0y; vec2[2] = 0;
      MAang2vc(&msg_loc, vec1, vec2, ang);
      ang[0] = ang[0]*180./M_PI;
      if (fabs(ang[0] - angle) <= EMS_ZEROANGLE_DEG)
      {
        SKaddvarlist ( &msg_loc, NULL, solvedvars, solve_x ? VAR_X : VAR_Y, 
                       tosolvevar->varobj, my_id, my_id, &point[solve_x ? X : Y], NULL );
        EMerr_hndlr ( EMSerror ( msg_loc ), *msg, EMS_E_Fail, ret_end );
        goto ret_end;
      } 

      /* 
         special handling for 90 deg angles ... occur very often due
         to arcs
      */
      if (is_normal) 
      {
         int done = FALSE;

         /* check for horizontal and vertical cases */
         if (solve_x) 
         {
            if (fabs(p1y - p0y) < lentol)
            {
               p0x = p2x;
	       done = TRUE;
            }
            else if (fabs(p2y - p0y) < lentol)
            {
               p0x = p1x;
	       done = TRUE;
            }
         } 
         else 
         {
            if (fabs(p1x - p0x) < lentol)
            {
               p0y = p2y;
	       done = TRUE;
            }
            else if (fabs(p2x - p0x) < lentol)
            {
               p0y = p1y;
	       done = TRUE;
            }
         }

         if (done) 
         {
            SKaddvarlist(&msg_loc, NULL, solvedvars, mask, p0, my_id, my_id,
                         solve_x ? &p0x : &p0y, NULL);
            goto ret_end;
         }
           
         /* the vectors are inclined */
         if (solve_x) 
         {
            b = -(p1x+p3x);
            c = p1x*p2x + (p1y-p0y)*(p2y-p0y);
         } 
         else 
         {
            b = -(p1y+p3y);
            c = p1y*p2y + (p1x-p0x)*(p2x-p0x);
         }

         nb_sol = SKsolve_second_degree(1., b, c, &sol1, &sol2);

         if (nb_sol == 0) 
         {
            sol = solve_x ? point[0] : point[1];
            *msg = EMS_I_NoSolution;
         }
         else if (nb_sol == 1) 
            sol = sol1;
         else
         {
            double diff1, diff2;

            /* figure out which solution is better */
            if (solve_x)
            {
               diff1 = fabs(sol1-point[0]);
               diff2 = fabs(sol2-point[0]);
            }
            else
            {
               diff1 = fabs(sol1-point[1]);
               diff2 = fabs(sol2-point[1]);
            }
            sol = diff1 < diff2 ? sol1 : sol2;
         }
         SKaddvarlist(&msg_loc, NULL, solvedvars, mask, p0, my_id, my_id,
                      &sol, NULL);
         goto ret_end;
      }
      else if (is_collinear)
      {
        /*
         * Special case handling for 180 degree angles since the general
         * case becomes singular.
         */
        if (solve_x)
        {
          if (fabs(p2y - p1y) < lentol)
            p0x = p1x;
          else
            p0x = p1x - (p1y - p0y)*(p2x - p1x)/(p2y - p1y);
        }
        else
        {
          if (fabs(p2x - p1x) < lentol)
            p0y = p1y;
          else
            p0y = p1y - (p1x - p0x)*(p2y - p1y)/(p2x - p1x);
        }
        SKaddvarlist(&msg_loc, NULL, solvedvars, mask, p0, my_id, my_id,
                     solve_x ? &p0x : &p0y, NULL);
        goto ret_end;
      }
      else
      {
         /* 
          * General angle with 3 points.   Algorithm developed by Udaya Gunasena.
          * 1) Fit a circle passing thru points p1 and p2 s.t. the angle subtended
          *    by the chord p1-p2 angle at the center = 2*angle.
          * 2) Intersect the circle with the known coordinate point (p0x or p0y)
          */
         int       k;
         double    theta, beta, m2, cosgam, singam, radicl,
                   center[2][2], root[4];

         if (angle < 90.0) 
            theta = angle;
         else
            theta = 180.0 - angle;

         /*
          * Locate the center of the circle along the perpendicular 
          * bisector of the segment p1-p2.  There will be two such centers.
          */
         beta = 0.5*sqrt((p2x-p1x)*(p2x-p1x) + (p2y-p1y)*(p2y-p1y))/
                tan(theta*M_PI/180.0);

         if (fabs(p1y-p2y) < lentol)
         {
            center[0][X] = center[1][X] = 0.5*(p1x+p2x);
            center[0][Y] = 0.5*(p1y+p2y) + beta;
            center[1][Y] = 0.5*(p1y+p2y) - beta;
         }
         else
         {
            m2 = (p1x-p2x)/(p2y-p1y);
            cosgam = sqrt(1.0/(1+m2*m2));
            singam = m2*cosgam;
            if (m2 < 0.0)
            {
               cosgam = -cosgam;
               singam = -singam;
            }
            center[0][X] = 0.5*(p1x+p2x) + beta*cosgam;
            center[0][Y] = 0.5*(p1y+p2y) + beta*singam;
            center[1][X] = 0.5*(p1x+p2x) - beta*cosgam;
            center[1][Y] = 0.5*(p1y+p2y) - beta*singam;
         }

         /* 
          *  intersect the two circles with the given coordinate
          */
         nb_sol = 0;
         for (k = 0; k <= 1; k++)
         {
            if (solve_x) 
            {
              radicl = (p1x - center[k][X])*(p1x - center[k][X]) +
                       (p1y - center[k][Y])*(p1y - center[k][Y]) -
                       (p0y - center[k][Y])*(p0y - center[k][Y]);
              if (radicl >= 0.0) 
              {
                 root[nb_sol++] = center[k][X] + sqrt(radicl);
                 root[nb_sol++] = center[k][X] - sqrt(radicl);
              }
            }
            else
            {
              radicl = (p1x - center[k][X])*(p1x - center[k][X]) +
                       (p1y - center[k][Y])*(p1y - center[k][Y]) -
                       (p0x - center[k][X])*(p0x - center[k][X]);
              if (radicl >= 0.0) 
              {
                 root[nb_sol++] = center[k][Y] + sqrt(radicl);
                 root[nb_sol++] = center[k][Y] - sqrt(radicl);
              }
            }
         }
         
         /* get the previous value to determine which is the best root or
            in case no solution is found
         */
         om$send ( msg = message SKvariable.SKgetvar
                       ( &msg_loc, NULL, NULL, NULL, point), 
                   targetid = p0);

         solution_found = FALSE;
         if (nb_sol > 0) 
         {
	    vec1[2] = vec2[2] = 0.0;

            difmin = MAXDOUBLE;
            for (k = 0; k < nb_sol; k++)
            {
               if (solve_x) 
               {
                  vec1[0] = p1x - root[k];
                  vec1[1] = p1y - p0y;
                  vec2[0] = p2x - root[k];
                  vec2[1] = p2y - p0y;
                  MAang2vc(&msg_loc, vec1, vec2, ang);
                  ang[0] = ang[0]*180./M_PI;
                  if ( fabs(ang[0] - angle) <= EMS_ZEROANGLE_DEG || 
                       fabs(ang[0] + angle - 360.0) <= EMS_ZEROANGLE_DEG)
                    if( fabs(point[X]-root[k]) < difmin) 
                    { 
                      p0x = root[k];
                      solution_found = TRUE;
                    }
               }
               else
               {
                  vec1[0] = p1x - p0x;
                  vec1[1] = p1y - root[k];
                  vec2[0] = p2x - p0x;
                  vec2[1] = p2y - root[k];
                  MAang2vc(&msg_loc, vec1, vec2, ang);
                  ang[0] = ang[0]*180./M_PI;
                  if ( fabs(ang[0] - angle) <= EMS_ZEROANGLE_DEG || 
                       fabs(ang[0] + angle - 360.0) <= EMS_ZEROANGLE_DEG)
                    if( fabs(point[Y]-root[k]) < difmin) 
                    {
                      p0y = root[k];
                      solution_found = TRUE;
                    }
               }
            }
            if (solution_found)
            {
              SKaddvarlist(&msg_loc, NULL, solvedvars, mask, p0, my_id, my_id,
                           solve_x ? &p0x : &p0y, NULL);
            }
         }

         if (!solution_found)
         {
            SKaddvarlist ( &msg_loc, NULL, solvedvars, mask, p0, my_id, my_id, 
                           &point [solve_x ? 0 : 1], NULL );
            SKaddvarlist ( &msg_loc, NULL, nosolution_vars, mask, p0, my_id, my_id, 
                           &point [solve_x ? 0 : 1], NULL );
            *msg = EMS_I_NoSolution;
         }
         goto ret_end;
      }
  }
  else if (tosolvevar->varobj == ptobjs [1] [1])
  {
     p0 = ptobjs [0] [0]; p1 = ptobjs [0] [1];
     p2 = ptobjs [1] [0]; p3 = ptobjs [1] [1];
  }
  else if (tosolvevar->varobj == ptobjs [1] [0])
  {
     p0 = ptobjs [0] [1]; p1 = ptobjs [0] [0];
     p2 = ptobjs [1] [1]; p3 = ptobjs [1] [0];
  }
  else if (tosolvevar->varobj == ptobjs [0] [1])
  {
     p0 = ptobjs [1] [0]; p1 = ptobjs [1] [1];
     p2 = ptobjs [0] [0]; p3 = ptobjs [0] [1];
  }
  else if (tosolvevar->varobj == ptobjs [0] [0])
  {
     p0 = ptobjs [1] [1]; p1 = ptobjs [1] [0];
     p2 = ptobjs [0] [1]; p3 = ptobjs [0] [0];
  }
  else
  {
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);
  }
  
  /*
   * Get the known coordinates.  Unknown coordinate is in p3.
   */
  om$send ( msg = message SKvariable.SKgetvar 
                  ( &msg_loc, NULL, NULL, NULL, point ), 
            targetid = p3 );  
  if (SKvarlistinx ( *solvedvars, p0, VAR_X, &tmp, NULL ))
    p0x = tmp->var [0];
  else
    {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
  if (SKvarlistinx ( *solvedvars, p0, VAR_Y, &tmp, NULL ))
    p0y = tmp->var [1];
  else
    {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
  if (SKvarlistinx ( *solvedvars, p1, VAR_X, &tmp, NULL ))
    p1x = tmp->var [0];
  else
    {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
  if (SKvarlistinx ( *solvedvars, p1, VAR_Y, &tmp, NULL ))
    p1y = tmp->var [1];
  else
    {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
  if (SKvarlistinx ( *solvedvars, p2, VAR_X, &tmp, NULL ))
    p2x = tmp->var [0];
  else
    {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
  if (SKvarlistinx ( *solvedvars, p2, VAR_Y, &tmp, NULL ))
    p2y = tmp->var [1];
  else
    {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}
  if (SKvarlistinx ( *solvedvars, p3, solve_x ? VAR_Y : VAR_X, &tmp, NULL )) 
  {
    if (solve_x) 
    {
      p3y = tmp->var [1];
      p3x = point[X];
    }
    else 
    {
      p3x = tmp->var [0];
      p3y = point[Y];
    }
  }
  else
    {EMerr_hndlr (TRUE, *msg, EMS_I_Insufficient, ret_end);}

  /*
   * Check if we already at the solution ... if so skip ..
   */
  vec1[0] = p1x - p0x; vec1[1] = p1y - p0y; vec1[2] = 0;
  vec2[0] = p3x - p2x; vec2[1] = p3y - p2y; vec2[2] = 0;
  MAang2vc(&msg_loc, vec1, vec2, ang);
  ang[0] = ang[0]*180./M_PI;
  if (fabs(ang[0] - angle) <= EMS_ZEROANGLE_DEG)
  {
    SKaddvarlist ( &msg_loc, NULL, solvedvars, solve_x ? VAR_X : VAR_Y, 
                   tosolvevar->varobj, my_id, my_id, &point[solve_x ? X : Y], NULL );
    EMerr_hndlr ( EMSerror ( msg_loc ), *msg, EMS_E_Fail, ret_end );
    goto ret_end;
  } 

  /*
   * Arbitrary angle defined by 4 points.  Rotate the known line segment (p0-p1) CCW
   * by the relative angle.  Rotate CW in the following 2 cases :
   * 
   * a) if the unknown point is in the first segment. Avoid this if SK_SUPPLEMENT bit is
   *    set, since in this case we have already made angle = 180-angle (3-pt angle cases).
   * b) if the unknown point is in the second segment of 3-pt supplement angle case.
   */
  angle = angle * M_PI/180.0;
  if ((!(ME.SKconstraint->props & SK_SUPPLEMENT) && 
       (p3 == ptobjs[0][0] || p3 == ptobjs[0][1])) ||
      (ME.SKconstraint->props & SK_SUPPLEMENT && p3 == ptobjs[1][1]))
    angle = -angle;

  sinang = sin(angle);
  cosang = cos(angle);
  
  x1 = (p1x-p0x)*cosang - (p1y-p0y)*sinang + p0x;
  y1 = (p1x-p0x)*sinang + (p1y-p0y)*cosang + p0y;

  solution_found = FALSE;
  if (solve_x)
  { 
    if (fabs (y1-p0y) > lentol) 
    {
      p3x = p2x + (p3y - p2y)*(x1 - p0x)/(y1 - p0y);
      solution_found = TRUE;
    }
  }
  else
  {
    if (fabs (x1-p0x) > lentol)
    {
      p3y = p2y + (y1 - p0y)*(p3x - p2x)/(x1 - p0x);
      solution_found = TRUE;
    }
  }
  
  /*
   * Post the new value in case of success.  
   * Post the old value in case we could not find a solution.  
   */
  if (solution_found)
  {
    SKaddvarlist(&msg_loc, NULL, solvedvars, mask, p3, my_id, my_id,
                 solve_x ? &p3x : &p3y, NULL);
  }
  else
  {
    SKaddvarlist ( &msg_loc, NULL, solvedvars, mask, p3, my_id, my_id, 
                   &point [solve_x ? 0 : 1], NULL );
    SKaddvarlist ( &msg_loc, NULL, nosolution_vars, mask, p3, my_id, my_id, 
                   &point [solve_x ? 0 : 1], NULL );
    *msg = EMS_I_NoSolution;
  }

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKrelornt.SKevaluate" );

  return stat_OM;
}

end implementation SKrelornt;
