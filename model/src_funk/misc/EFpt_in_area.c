/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */

/*
  HISTORY

    Sudha  07/09/93  :  Modified for BSprototypes anisfication
    SCW    02/13/97  :  Changed emsmacros inclusion to emsmacros_c

*/

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMerrordef.h"
#include "emserr.h"
#include <math.h>
#include "emsmacros_c.h"
#include "EMSerrordef.h"
#include "bsmdistptsf.h"
#include "bsdistptpt.h"

#define TOL 0.05

EFget_point_in_area (EMmsg, closed_curve, surface, point1, point2,
                     point_in_area)
 
IGRlong *EMmsg;
IGRboolean  closed_curve;
IGRpoint point1, point2;
IGRdouble *point_in_area;
struct IGRbsp_surface *surface;

{
 IGRlong                stat_OM, msg;
 IGRint                 i;
 IGRpoint               base_point, extended_pt;
 IGRdouble              dist, tot_dist, saf_factor;
 IGRdouble              area_pt[2], uv_point[2];
 IGRdouble              bas_tol;
 IGRboolean             stat;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);

 tot_dist = BSdistptpt(&msg, point1, point2);

 saf_factor = tot_dist;

 if (closed_curve) saf_factor = 1000 * bas_tol;

 /* get point at a distance of saf_factor -- external to the line */

 for (i=0; i<3; i++)
  extended_pt[i] = (point1[i] * (saf_factor + tot_dist) -
                    saf_factor * point2[i]) / tot_dist;

 stat = BSmdistptsf (&msg, surface, extended_pt, &point_in_area[0],
                     &point_in_area[1], base_point, &dist);
 EMerr_hndlr (! stat || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 /* all this for seam edges */

 if (surface->u_phy_closed || surface->v_phy_closed)
  {
   if ((point_in_area[0] <= TOL) || (point_in_area[1] <= TOL) ||
       (point_in_area[0] >= (1 - TOL)) || (point_in_area[1] >= (1 - TOL)))
    {
     area_pt[0] = point_in_area[0];
     area_pt[1] = point_in_area[1];
   
     stat = BSmdistptsf(&msg, surface, point1, &uv_point[0], &uv_point[1],
                        base_point, &dist);
     EMerr_hndlr (! stat || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     if ((uv_point[0] <= TOL) && (area_pt[0] >= (1-TOL)))
          point_in_area[0] = 0.0;
     if ((uv_point[1] <= TOL) && (area_pt[1] >= (1-TOL)))
          point_in_area[1] = 0.0;
     if ((uv_point[0] >= (1-TOL)) && (area_pt[0] <= TOL))
          point_in_area[0] = 1.0;
     if ((uv_point[1] >= (1-TOL)) && (area_pt[1] <= TOL))
          point_in_area[1] = 1.0;
    }
  }

 wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EFget_point_in_area"); 
  return;
 
} 
