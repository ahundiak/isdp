/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include "OMminimum.h"
#include "bserr.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "emsedgedef.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "marptsxfo.h"
#include "maidmx.h"
#include "mabctoar.h"
#include "maarexten.h"
#include "bsptlnplan.h"
#include "bspl_of_cv.h"

#define PLANE 3
#define POINT 1
#define LINE 2

EFpl_of_cv (EMmsg, curve, curve_type, plane)
IGRlong *EMmsg;
struct IGRbsp_curve *curve;
IGRuchar curve_type;
struct IGRbsp_surface *plane;

/* *************************************************************************

Description
 This routine returns the encompassing plane when given the bspline
geometry of the curve and its curve type. In cases of conics, it gets
a better plane as compared to the one that could be obtained by taking the
range box of the curve.

Input
 curve : bspline geometry of the curve.
 curve_type : curve_type. See emsedgedef.h for the various curve types.
 
Output
 plane : geometry of the plane. The memory needs to be preallocated.
 EMmsg : completion status

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_InvalidArg: If the curve is non planar or if the curve happens
                   to be a degenerate case of being a line or a point.
 EMS_E_MAerror : If there was a error in MA routines.
 EMS_E_BSerror : If there was an error in calling a bs routine.
 EMS_E_Fail: A catch all error

History
 07/06/93 :Sudha Modified for BSprototypes ansification
 01/18/89 : PP : Make additional check to handle the case arising from 
                 intersection of a plane with cylinder etc wherein a
                 2-d line string claims to be of type conic .
                 Eventually we would have to fit the curve to whatever it says
                 it is.
 09/17/88 : PP : Creation

 *************************************************************************** */
{
 IGRlong emsts,masts;
 struct IGRarc arc;
 BSrc   rc;
 IGRboolean planar;
 static knots[4] = {0, 0, 1 , 1};
 IGRmatrix save_mat;
 IGRmatrix idmx;
 IGRpoint min, max;
 IGRvector nvec;
 IGRshort i;
 IGRlong total_poles;
 IGRboolean bssts;
 IGRboolean conic = FALSE;
 IGRint code;

 emsts = 1;
 *EMmsg = EMS_S_Success;

 BSptlnplan(curve->num_poles, curve->rational, (IGRpoint *)curve->poles, 
            curve->weights, &code, nvec, &rc);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

 if (code != PLANE) 
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 switch (curve_type)
 {
  case EMcircular_arc:
  case EMcircle:
  case EMelliptical_arc:
  case EMellipse:
  {
   conic = TRUE;
   if (curve->order == 2) conic = FALSE;
   break;
  }

  default:
   conic = FALSE;
  break;
 }

/*
 * Fill in the plane structure
 */

if (conic)
{
 plane->u_num_poles = 2;
 plane->v_num_poles = 2;
 plane->u_order = 2;
 plane->v_order = 2;
 plane->u_periodic = FALSE;
 plane->v_periodic = FALSE;
 plane->u_phy_closed = FALSE;
 plane->v_phy_closed = FALSE;
 plane->u_num_knots = 4;
 plane->v_num_knots = 4;
 plane->rational = FALSE;
 plane->weights = NULL;
 plane->num_boundaries = 0;
 plane->bdrys= NULL;
 plane->u_non_uniform = FALSE;
 plane->v_non_uniform = FALSE;
 plane->planar = 1;

 for (i=0;i<4; i++)
 {
  plane->u_knots[i] = knots[i];
  plane->v_knots[i] = knots[i];
 }
}


if (conic)
{
 MAidmx(&masts, idmx);
 EMerr_hndlr(!(1&masts), *EMmsg, EMS_E_MAerror, wrapup);

 MAbctoar(&masts, curve, &arc);
 EMerr_hndlr(!(1&masts), *EMmsg, EMS_E_MAerror, wrapup);

 for (i=0;i<16;i++)
 {
  save_mat[i] = arc.rot_matrix[i];
  arc.rot_matrix[i] = idmx[i];
 }

/*
 * Store the translation components
 */


 for (i=0;i<3; i++)
 {
  save_mat[4*(i+1) - 1] = arc.origin[i];
  arc.origin[i] = 0.0;
 }

 MAarextents(&masts, &arc, min, max);
 EMerr_hndlr(!(1&masts), *EMmsg, EMS_E_MAerror, wrapup);


for (i=0;i<3;i++)
{
 plane->poles[i] = min[i];
 plane->poles[i+9] = max[i];
}

 plane->poles[3] = max[0];
 plane->poles[4] = min[1];
 plane->poles[5] = min[2];
 plane->poles[6] = min[0];
 plane->poles[7] = max[1];
 plane->poles[8] = min[2];

 total_poles = 4;

 MArptsxform(EMmsg, &total_poles, &plane->rational, plane->weights,
             save_mat, plane->poles, plane->poles);
 EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_MAerror, wrapup);
}
else
{
   BSpl_of_cv( EMmsg, curve, plane );
   if( *(EMmsg) == BSSUCC ) *(EMmsg) = EMS_S_Success;
   else
      {
        if( *(EMmsg) == BSINARG )
             *(EMmsg) = EMS_E_InvalidArg;
        else *(EMmsg) = EMS_E_BSerror;
        goto wrapup;
      }
 
}
wrapup:
 return;
}
