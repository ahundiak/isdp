class implementation EMSloop;
/*
History
        DLB 7/27/92 Increased MAX_CALLINX to 200.
        DLB & BL Fixed recusrsive call to EMpointinsideloop atleast_dist
                 was being passed as a ptr to a ptr.
*/


#include "EMS.h"
%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsinterdef.h"

#define U 0
#define V 1

#define U_MIN 0
#define V_MIN 1
#define U_MAX 2
#define V_MAX 3

#define MYCLOOPS_DEPTH 2

#define SAFETY_FACTOR 10

#define MAX_CALLINX 200

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSloop_class_id;

IGRlong EMptsinsidelp (msg, lpdata, lprange, numpts, pts, options,
                       lentol, callinx, atleast_dists)
IGRlong *msg;
struct EMSdataselect *lpdata;
IGRdouble *lprange;
IGRint numpts;
IGRdouble *pts;
IGRushort options;
IGRdouble lentol;
IGRint *callinx;
IGRdouble *atleast_dists;
{
  IGRboolean stat_func, vertical;
  IGRint num_inters, subinx;
  IGRlong stat_OM, msg_loc;
  IGRdouble lnrange[4], line[4], *pt1, *pt2;
  IGRdouble safetol, fraction;
  GRclassid classid;
  struct GRid *lpid;
  struct IGRpolyline poly;
  struct EMSpypoint *polyinters;
  struct EMSpartolbasis partolb;
  extern  void  EMpypoint_free();
  void EMsortpypts();
  extern void BSpt_in_plg();
  extern IGRboolean EM2dpycutint();
  extern IGRdouble EMsubdivval();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  polyinters = NULL;
 
  EMerr_hndlr (numpts <= 0, *msg, EMS_E_InvalidArg, ret_end);
  EMerr_hndlr (*callinx > MAX_CALLINX, *msg, EMS_E_OutOfBounds, ret_end);

  safetol = lentol * SAFETY_FACTOR;
  
  /*
   * Obtain the ray/line w.r.t. the range box which will be used
   * to compute the point inside.
   */

  vertical = *callinx % 2;
  subinx = *callinx / 2;
  fraction = EMsubdivval (0.5, subinx);
  if (vertical)
    {
    line[U] = lprange[U_MIN] + fraction * (lprange[U_MAX] - lprange[U_MIN]);
    line[V] = lprange[V_MIN] - safetol;
    line[U+2] = line[U];
    line[V+2] = lprange[V_MAX] + safetol;
    }
  else
    {
    line[U] = lprange[U_MIN] - safetol;
    line[V] = lprange[V_MIN] + fraction * (lprange[V_MAX] - lprange[V_MIN]);
    line[U+2] = lprange[U_MAX] + safetol;
    line[V+2] = line[V];
    }

  poly.num_points = 2;
  poly.points = line;
  OM_BLOCK_MOVE (line, lnrange, 4 * sizeof (IGRdouble));  
  EM2dbxinc (lnrange, lentol);

  /*
   * Intersect the line obtained above with the
   * input loop.
   */

  num_inters = 0;
  if (lpdata->datatype == EMSdata_object)
    {
    lpid = lpdata->data.object;
    stat_OM = om$get_classid (objid = lpid->objid, osnum = lpid->osnum, 
               p_classid = &classid);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$is_ancestry_valid (subclassid = classid,
               superclassid = OPP_EMSloop_class_id);
    EMomerr_exit (stat_OM, ret_end);
 
    if (stat_OM == OM_S_SUCCESS)
      {
      partolb.tol = lentol;
      partolb.is_valid = TRUE;
      stat_OM = om$send (msg = message EMSloop.EMlppytrimint (&msg_loc,
                 &poly, lnrange, &partolb, MYCLOOPS_DEPTH, EMS_INTER_CUTTING,
                 &num_inters, NULL, &polyinters), targetid = lpid->objid,
                 targetos = lpid->osnum, senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
      }
    else
      EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
    }
  else if (lpdata->datatype == EMSdata_poly2d)
    {
    stat_func = EM2dpycutint (&msg_loc, lpdata->data.poly->num_points,
                 lpdata->data.poly->points, NULL, lprange, 2, line, lnrange,
                 EMS_INTER_CUTTING | EMS_INTER_ONEOFTWO, lentol,
                 NULL, NULL, NULL_OBJID, NULL,
                 &num_inters, NULL, &polyinters);
    EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * If there was an intersection and the number of intersections are
   * even, an inside point can be computed. Else, call this function
   * again recursively, until this condition is met or the maximum 
   * number of iterations limit is reached.
   */

  if (num_inters && !(num_inters % 2))
    {
    EMsortpypts (&msg_loc, &polyinters, 2, FALSE, &lentol);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    pt1 = polyinters->point;
    pt2 = polyinters->next->point;
    pts[U] = pt1[U] + 0.5 * (pt2[U] - pt1[U]);
    pts[V] = pt1[V] + 0.5 * (pt2[V] - pt1[V]);
    if (atleast_dists)
      {
      if (polyinters->props & EMS_PYPT_HOLEAREA ||
          polyinters->props & EMS_PYPT_AREAHOLE)
        *atleast_dists = sqrt (EM2ddistptpts (pt1, pts));
      else
        *atleast_dists = -1.0;
      }
  
    if (--numpts)
      {
      (*callinx)++;
      stat_OM = EMptsinsidelp (&msg_loc, lpdata, lprange, numpts, &pts[2],
                 options, lentol, callinx, 
                 atleast_dists ? atleast_dists : NULL);  /*rem &atleast.*/
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      }
    }
  else
    {
    (*callinx)++;
    stat_OM = EMptsinsidelp (msg, lpdata, lprange, numpts, pts, options,
               lentol, callinx, atleast_dists);
    }

ret_end:
  if (polyinters)
    EMpypoint_free (polyinters, MAXINT);
  if (*msg != EMS_E_OutOfBounds)
    {EMWRAPUP (*msg, stat_OM, "EMptinsidelp");}
  else
    stat_OM = OM_E_ABORT;
  return (stat_OM);
}

end implementation EMSloop;
