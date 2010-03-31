class implementation SKaxisptpt;

#include <math.h>
#include "emsdebug.h"

#define SOLVED -1

#define X   0
#define Y   1

#define ORIGIN  0
#define MEASURE 1
#define AXIS_1  2
#define AXIS_2  3

/*

Name
  SKmakejacobian

Abstract

Synopsis

Description
    This method is used to handle the Jacobian calls for the point_to_point 
    distance along a measurement axis constraint.

Return Value

Notes
  A measurement axis point-to-point distance is made up of 4 objects as follows:
    pt_obj[0] = P1 = Origin pt (ORIGIN).
    pt_obj[1] = P2 = Measure pt (MEASURE).
    pt_obj[2] = P3 = Axis definition pt (AXIS_1)
    pt_obj[3] = P4 = Axis definition pt (AXIS_2).

  The distance could be along the measurement axis (SK_HORIZONTAL) or perpendicular
  to it.  The distance is determined by taking the dot product of the measurement
  vector (P1->P2) with the normalized axis vector (||P3->P4||).

  x1 = P2x - P1x; y1 = P2y - P1y;
  x2 = P4x - P3x; y2 = P4y - P3y;
  
  Dh = (x1*x2 + y1*y2)/sqrt(x2*x2 + y2*y2)     (Distance along the axis)
  Dv = x1*x1 + y1*y1 - Dh*Dh                   (Distance normal to the axis)
  
  Based on the above equations (by squaring and simplifying), we get the following
  equations for the defining functions:
         2    2     2       2  2     2  2
  fh = Dh  (x2  + y2 ) - [x1 x2  + y1 y2  + 2*x1*x2*y1*y2] = 0

         2    2     2       2  2     2  2
  fv = Dv  (x2  + y2 ) - [x1 y2  + y1 x2  - 2*x1*x2*y1*y2] = 0 
  
  The jacobian entries can be derived by differentiating the above equations accordingly.
  
  SPECIAL CASES:
    In a 3-pt case where AXIS-2 point is same as the ORIGIN, we need to take care to
    add the components of the jacobians from ORIGIN and AXIS-2.
    
    In a 2-pt case the measurement vector and axis vector are same, this constraint 
    becomes the same as a regular SKptpt constraint.
  
Index

Keywords
  jacobian, constraint, measurement axis
  
History
  06/08/92 : Rajiv Agrawal : created
  07/16/92 : Rajiv Agrawal : Removed the dependence on parent SKptpt and 
                      started handling the case of parallel constraint internally
                      (is_ptpt = TRUE when meas axis is same as the origin and 
                       measure points).
  12/02/92 : Rajiv Agrawal : Corrected the jacobian values in the 3-pt case where the 
                      AXIS_2 object is same as the ORIGIN.
  12/16/93 : Rajiv Agrawal : Added code for SK_HALFVALUE handling and added notes 
                             explaining the jacobian computation.
 */


method SKmakejacobian (IGRlong *msg; unsigned short options;
                       struct SKsolvevars *solvedvars, *unsolvedvars;
                       IGRdouble *jacobian; IGRdouble *funcval)
{
  IGRboolean 		is_vpt, is_hpt, is_ptpt, adjreq, accreq;
  int 			stat_OM, i, j, var_inx[4][2], varinx;
  long			msg_loc;
  double 		diff_value=0.0, value, distol, var[4][2];
  double 		dx1, dy1, dx2, dy2;
  GRobjid 		pt_obj[4];
  struct GRid           my_grid;
  struct SKsolvevars 	*varnode;
  extern IGRboolean 	SKvarlistinx();
  extern void           SKgettol();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the four points making up this constraint. Pt1 is the ORIGIN 
   * and Pt2 is the MEASURE pt.  Pt3 and Pt4 define the measurement axis.
   * In a 3-pt case, Pt4 will be same as Pt1.
   */

  stat_OM = om$send (msg = message SKaxisptpt.SKgetptptinfo 
                           (&msg_loc, solvedvars, &value, pt_obj), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase, ret_end);

  if (ME.SKconstraint->props & SK_HALFVALUE)
    value /= 2.0;

  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &value, GRIO_DISTANCE, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  is_hpt = is_vpt = is_ptpt = FALSE;
  if (ME.SKconstraint->props & SK_HORIZONTAL)
    is_hpt = TRUE;
  else
    is_vpt = TRUE;

  /*
   * If the measurement axis points are the same as the ORIGIN and MEASURE
   * points, just treat it like a single parallel constraint.
   */
  if ((pt_obj[AXIS_1] == pt_obj[ORIGIN] && pt_obj[AXIS_2] == pt_obj[MEASURE] ) ||
      (pt_obj[AXIS_2] == pt_obj[ORIGIN] && pt_obj[AXIS_1] == pt_obj[MEASURE] ))
  {
    is_ptpt = TRUE;
    is_hpt = FALSE;
    is_vpt = FALSE;
  }
 
 /*
  * Determine the unknown variables in this equation and obtain their indices.
  * Also, find out the current values of the involved variables (both
  * known and unknown).  varinx is the index in the list of solved or
  * unsolved variables.  var_inx is a local copy that stores varinx or SOLVED
  * depending on whether the variable is unsolved or solved, respectively.
  */

 for (i=ORIGIN; i<=AXIS_2; i++)
 {
   for (j=X; j<=Y; j++)
   {
     if (SKvarlistinx (unsolvedvars, pt_obj[i], j == X ? VAR_X : VAR_Y,
                       &varnode, &varinx))
     {
       var_inx[i][j] = varinx;
       var[i][j] = varnode->var[j];
     }
     else
     {
       var_inx[i][j] = SOLVED;
       if (SKvarlistinx (solvedvars, pt_obj[i], j == X ? VAR_X : VAR_Y,
                         &varnode, &varinx))
       {
         var[i][j] = varnode->var[j];
       }
       else
       {
         EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
       }
     }
   }
 }

 /*
  * Plug in the appropriate values in the row of the Jacobian matrix
  */

 adjreq = options & SK_JACOB_ADJACENCY;
 accreq = options & SK_JACOB_ACCURACY;
 
 dx1 = var[MEASURE][X] - var[ORIGIN][X];
 dy1 = var[MEASURE][Y] - var[ORIGIN][Y];
 dx2 = var[AXIS_2][X] - var[AXIS_1][X];
 dy2 = var[AXIS_2][Y] - var[AXIS_1][Y];
 
 if (is_hpt)
 {
   if (jacobian)
   {
     if (var_inx[ORIGIN][X] != SOLVED)
       jacobian[var_inx[ORIGIN][X]] = adjreq ? TRUE : 
           (2*dx1*dx2*dx2 + 2*dx2*dy1*dy2);
     if (var_inx[MEASURE][X] != SOLVED)
       jacobian[var_inx[MEASURE][X]] = adjreq ? TRUE :
           (-2*dx1*dx2*dx2 - 2*dx2*dy1*dy2);
     if (var_inx[ORIGIN][Y] != SOLVED)
       jacobian[var_inx[ORIGIN][Y]] = adjreq ? TRUE :
           (2*dy1*dy2*dy2 + 2*dx1*dx2*dy2);
     if (var_inx[MEASURE][Y] != SOLVED)
       jacobian[var_inx[MEASURE][Y]] = adjreq ? TRUE :
           (-2*dy1*dy2*dy2 - 2*dx1*dx2*dy2);
     if (var_inx[AXIS_1][X] != SOLVED)
       jacobian[var_inx[AXIS_1][X]] = adjreq ? TRUE :
           (-2*value*value*dx2 + 2*dx1*dx1*dx2 + 2*dx1*dy1*dy2);
     if (var_inx[AXIS_2][X] != SOLVED)
     {
       if (var_inx[AXIS_2][X] != var_inx[ORIGIN][X]) 
         jacobian[var_inx[AXIS_2][X]] = adjreq ? TRUE :
             (2*value*value*dx2 - 2*dx1*dx1*dx2 - 2*dx1*dy1*dy2);
       else /* 3-pt case handling */
         jacobian[var_inx[AXIS_2][X]] = adjreq ? TRUE :
             (jacobian[var_inx[ORIGIN][X]] + 2*value*value*dx2 - 2*dx1*dx1*dx2 - 2*dx1*dy1*dy2);
     }
     if (var_inx[AXIS_1][Y] != SOLVED)
       jacobian[var_inx[AXIS_1][Y]] = adjreq ? TRUE :
           (-2*value*value*dy2 + 2*dy1*dy1*dy2 + 2*dx1*dx2*dy1);
     if (var_inx[AXIS_2][Y] != SOLVED)
     {
       if (var_inx[AXIS_2][Y] != var_inx[ORIGIN][Y]) 
         jacobian[var_inx[AXIS_2][Y]] = adjreq ? TRUE :
           (2*value*value*dy2 - 2*dy1*dy1*dy2 - 2*dx1*dx2*dy1);
       else /* 3-pt case handling */
         jacobian[var_inx[AXIS_2][Y]] = adjreq ? TRUE :
           (jacobian[var_inx[ORIGIN][Y]] + 2*value*value*dy2 - 2*dy1*dy1*dy2 - 2*dx1*dx2*dy1);
       
     }
   }

   if (funcval)
   {
     *funcval = dx1*dx1*dx2*dx2 + dy1*dy1*dy2*dy2 + 2*dx1*dx2*dy1*dy2 -
                value*value*(dx2*dx2 + dy2*dy2);
   }

   if (accreq)
   {
     diff_value = fabs (value - 
                        fabs ((dx1 * dx2 + dy1 * dy2) / 
                              sqrt (dx2 * dx2 + dy2 * dy2)));
   }
 }
 else if (is_vpt)
 {
   if (jacobian)
   {
     if (var_inx[ORIGIN][X] != SOLVED)
       jacobian[var_inx[ORIGIN][X]] = adjreq ? TRUE : 
           (2*dx1*dy2*dy2 - 2*dx2*dy1*dy2);
     if (var_inx[MEASURE][X] != SOLVED)
       jacobian[var_inx[MEASURE][X]] = adjreq ? TRUE :
           (-2*dx1*dy2*dy2 + 2*dx2*dy1*dy2);
     if (var_inx[ORIGIN][Y] != SOLVED)
       jacobian[var_inx[ORIGIN][Y]] = adjreq ? TRUE :
           (2*dy1*dx2*dx2 - 2*dy2*dx1*dx2);
     if (var_inx[MEASURE][Y] != SOLVED)
       jacobian[var_inx[MEASURE][Y]] = adjreq ? TRUE :
           (-2*dy1*dx2*dx2 + 2*dy2*dx1*dx2);
     if (var_inx[AXIS_1][X] != SOLVED)
       jacobian[var_inx[AXIS_1][X]] = adjreq ? TRUE :
           (-2*dx2*value*value + 2*dx2*dy1*dy1 - 2*dx1*dy1*dy2);
     if (var_inx[AXIS_2][X] != SOLVED)
     {
       if (var_inx[AXIS_2][X] != var_inx[ORIGIN][X])
         jacobian[var_inx[AXIS_2][X]] = adjreq ? TRUE :
           (2*dx2*value*value - 2*dx2*dy1*dy1 + 2*dx1*dy1*dy2);
       else /* 3-pt case handling */
         jacobian[var_inx[AXIS_2][X]] = adjreq ? TRUE :
           (jacobian[var_inx[ORIGIN][X]] + 2*dx2*value*value - 2*dx2*dy1*dy1 + 2*dx1*dy1*dy2);
     }
     if (var_inx[AXIS_1][Y] != SOLVED)
       jacobian[var_inx[AXIS_1][Y]] = adjreq ? TRUE :
           (-2*dy2*value*value + 2*dy2*dx1*dx1 - 2*dy1*dx1*dx2);
     if (var_inx[AXIS_2][Y] != SOLVED)
     {
       if (var_inx[AXIS_2][Y] != var_inx[ORIGIN][Y])
         jacobian[var_inx[AXIS_2][Y]] = adjreq ? TRUE :
           (2*dy2*value*value - 2*dy2*dx1*dx1 + 2*dy1*dx1*dx2);
       else /* 3-pt case handling */
         jacobian[var_inx[AXIS_2][Y]] = adjreq ? TRUE :
           (jacobian[var_inx[ORIGIN][Y]] + 2*dy2*value*value - 2*dy2*dx1*dx1 + 2*dy1*dx1*dx2);
     }
   }

   if (funcval)
   {
     *funcval = dx1*dx1*dy2*dy2 + dy1*dy1*dx2*dx2 - 2*dx1*dx2*dy1*dy2 -
                value*value*(dx2*dx2 + dy2*dy2);
   }

   if (accreq)
   {
     diff_value = fabs (value - 
                        fabs ((dx1 * dy2 - dx2 * dy1) / 
                              sqrt (dx2 * dx2 + dy2 * dy2)));
   }
 }
 else if (is_ptpt)
 {
   if (jacobian)
   {
     if (var_inx[ORIGIN][X] != SOLVED)
       jacobian[var_inx[ORIGIN][X]] = adjreq ? TRUE : (2*dx1);
     if (var_inx[MEASURE][X] != SOLVED)
       jacobian[var_inx[MEASURE][X]] = adjreq ? TRUE : (-2*dx1);
     if (var_inx[ORIGIN][Y] != SOLVED)
       jacobian[var_inx[ORIGIN][Y]] = adjreq ? TRUE : (2*dy1);
     if (var_inx[MEASURE][Y] != SOLVED)
       jacobian[var_inx[MEASURE][Y]] = adjreq ? TRUE : (-2*dy1);
   }
   
   if (funcval)
     *funcval = dx1*dx1 + dy1*dy1 - value*value;
   
   if (accreq) 
   {
     diff_value = fabs (value - sqrt (dx1 * dx2 + dy1 * dy2));
   }
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

  DEBUG_REPORT (accreq, "Axis Pt-Pt residual", my_id, diff_value);

ret_end:
 EMWRAPUP(*msg, stat_OM, "SKaxisptpt.SKmakejacobian");
 return (stat_OM);
}

end implementation SKaxisptpt;

