/* 
  DESCRIPTION

    This function maps an xyz dataselect curve (xyzcv) (3D polyline or 3D
    B-spline) onto a bspline surface (srf). The output can be more than
    one projected curve or can be restricted to one that is closest to an
    input reference point (refpt). If refpt is NULL then all the projected
    pieces are returned. The output is in the form of uv-dataselects (uvcvs)
    and/or xyz-dataselects (pjxyzcvs).
      
  OPTIONS

    options		- None supported.
    refpt		- If NULL, all proj curves returned. Else, the one
                          closest to refpt returned. In this case, the
                          space for a single slot in pjxyzcvs and/or the uvcvs
                          dataselect array is expected. That is, *pjxyzcvs 
                          and/or *uvcvs must be pointing to a valid dataselect
                          structure.
    pjxyzcvs		- If NULL, this output ignored.
    uvcvs		- If NULL, this output ignored.

  RETURN CODE

    EMS_I_Clipped	- If refpt is given and was used to remove some curves
			  from the output group.
    
  BUGS

    Today the special situation of maintaining a B-spline uv-curve in the
    case of rectangular planes is not done within here. Also, the xyz input
    cannot be a GRcurve object.
*/

#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emserr.h"

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif

void EMpjcvnsrf (msg, options, srf, xyzcv, chttol, refpt,
                 num_outcvs, uvcvs, pjxyzcvs)
IGRlong *msg;
IGRushort options;
struct IGRbsp_surface *srf;
struct EMSdataselect *xyzcv;
IGRdouble chttol;
IGRdouble *refpt;
IGRint *num_outcvs;
struct EMSdataselect **uvcvs;
struct EMSdataselect **pjxyzcvs;
{
  IGRboolean alloncv;
  IGRint i, inx, inxlim, mininx=0, blksize, num_grps, *num_pts_grp;
  IGRlong msg_loc;
  IGRdouble (**uvpts)[2], (**xyzpts)[3], mindist, dist;
  struct IGRpolyline py;
  struct IGRbsp_curve *cv, lcv;
  struct EMSpypoint pypt;
 
  *msg = EMS_S_Success;

  lcv.poles = NULL;
  lcv.knots = NULL;
  num_pts_grp = NULL;
  uvpts = NULL;
  xyzpts = NULL;

  /*
   * Obtain the xyz B-spline curve
   */

  if (xyzcv->datatype == EMSdata_curve3d)
    cv = xyzcv->data.curve;
  else if (xyzcv->datatype == EMSdata_poly3d)
    {
    EMcnvtpybsn (&msg_loc, 3, xyzcv->data.poly, &lcv);
    cv = &lcv;
    }
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_NotSupported, ret_end);}

  /*
   * Project the B-spline curve onto the surface
   */

  BSpjcvnrsf (cv, srf, chttol, &num_grps, &num_pts_grp, &uvpts, &xyzpts,
   &alloncv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC || !num_grps, *msg, EMS_E_Fail, ret_end);

  /*
   * Discard any degenerate group (group consisting of a single point).
   */

  EFcompress_groups (&num_grps, &num_pts_grp, &xyzpts, &uvpts, NULL, &msg_loc);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * If multiple curves result and the option to pick one closest to
   * a give point is to be excercised, figure out the closest group
   * to the ref point. 
   */

  if (refpt && num_grps > 1)
    {
    mindist = MAXDOUBLE;
    for (i=0; i<num_grps; i++)
      {
      py.num_points = num_pts_grp[i];
      py.points = (IGRdouble *) xyzpts[i];
      EMcnvtpypts (&msg_loc, &py, 3, 1, refpt, chttol, &pypt, &dist);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
      if (dist < mindist)
        {
        mindist = dist;
        mininx = i;
        }
      }
    *msg = EMS_I_Clipped;
    *num_outcvs = 1;
    }
  else
    *num_outcvs = num_grps;

  /*
   * Format the uv-data
   */

  if (uvcvs)
    {
    if (!refpt)
      {
      blksize = num_grps * sizeof (struct EMSdataselect);
      *uvcvs = (struct EMSdataselect *) om$malloc (size = blksize);
      EMerr_hndlr (!*uvcvs, *msg, EMS_E_NoDynamicMemory, ret_end);
      }

    inxlim = refpt ? 1 : num_grps;
    for (i=0; i<inxlim; i++)
      {
      (*uvcvs)[i].datatype = EMSdata_poly2d;
      (*uvcvs)[i].data.poly = (struct IGRpolyline *) om$malloc (size =
                               sizeof(struct IGRpolyline));
      EMerr_hndlr (!((*uvcvs)[i].data.poly), *msg, EMS_E_NoDynamicMemory, 
       ret_end);

      inx = refpt && num_grps > 1 ? mininx : i;
      (*uvcvs)[i].data.poly->num_points = num_pts_grp[inx];
      (*uvcvs)[i].data.poly->points = (IGRdouble *) uvpts[inx];
      uvpts[inx] = NULL;
      }
    }

  /*
   * Format the xyz-data
   */

  if (pjxyzcvs)
    {
    if (!refpt)
      {
      blksize = num_grps * sizeof (struct EMSdataselect);
      *pjxyzcvs = (struct EMSdataselect *) om$malloc (size = blksize);
      EMerr_hndlr (!*pjxyzcvs, *msg, EMS_E_NoDynamicMemory, ret_end);
      }
    inxlim = refpt ? 1 : num_grps;
    for (i=0; i<inxlim; i++)
      {
      (*pjxyzcvs)[i].datatype = EMSdata_poly3d;
      (*pjxyzcvs)[i].data.poly = (struct IGRpolyline *) om$malloc (size =
                                  sizeof(struct IGRpolyline));
      EMerr_hndlr (!((*pjxyzcvs)[i].data.poly), *msg, EMS_E_NoDynamicMemory, 
       ret_end);

      inx = refpt  ? mininx : i;
      (*pjxyzcvs)[i].data.poly->num_points = num_pts_grp[inx];
      (*pjxyzcvs)[i].data.poly->points = (IGRdouble *) xyzpts[inx];
      xyzpts[inx] = NULL;
      }
    }

ret_end:
  if (lcv.poles)
    om$dealloc (ptr = lcv.poles);
  if (lcv.knots)
    om$dealloc (ptr = lcv.knots);
  if (num_pts_grp)
    om$dealloc (ptr = num_pts_grp);
  if (uvpts)
    {
    for (i=0; i<num_grps; i++)
      if (uvpts[i])
        om$dealloc (ptr = uvpts[i]);
    om$dealloc (ptr = uvpts);
    }
  if (xyzpts)
    {
    for (i=0; i<num_grps; i++)
      if (xyzpts[i])
        om$dealloc (ptr = xyzpts[i]);
    om$dealloc (ptr = xyzpts);
    }
 return;
}
