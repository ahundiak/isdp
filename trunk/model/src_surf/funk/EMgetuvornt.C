/*
  DESCRIPTION

    Used to orient the intersection data returned by surface-surface
    intersection. This orientation ensures that the itnersection curves,
    when traversed, will have the outward normal of the "other_surface"
    either to the left or the right, depending on the option chosen.

  ASSUMPTION

    It is assumed that atleast one intersection curve (either "my" or
    "other") is a polyline and not a B-spline curve. If there is a 
    B-spline as one of the uv-data, it is assumed to be paramterized
    from 0 to 1.

  HISTORY

    SS  :  01/11/86  :  Creation
    SS  :  04/27/88  :  Modified to accept intersection data as EMSdataselects,
                        meaning that the data could even be in a B-spline
                        curve format.
    SS  :  09/11/88  :  The tolerance against which the triple-product is
                        checked is directly related to a defined-constant
                        zero-angle.
    NP  :  08/27/92  :  Modified for ANSI compliance.
*/

#include "EMS.h"
#include <math.h>
#include <values.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
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
#include "emserr.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsdef.h"

#define MY    0
#define OTHER 1

#define U 0
#define V 1

#define X 0
#define Y 1
#define Z 2


/*
 * The minimum number of points there must be in order to warrant the search
 * for a good sample-point to begin from an internal point. The first sample
 * point is taken at an index about a third of the way into the set of
 * points
 */
 
#define MINIMUM_FOR_MIDFIRST  3

static void getuvorient_atpt(), getinxpt();


void EMgetuvorient (msg, my_srf, other_srf, myuvdat, otheruvdat,
                    myxyzdat, otherxyzdat, 
                    orient_right, reverse_myuvdat, reverse_otheruvdat)
IGRlong *msg;
struct IGRbsp_surface *my_srf, *other_srf;
struct EMSdataselect *myuvdat, *otheruvdat, *myxyzdat, *otherxyzdat;
IGRboolean orient_right, *reverse_myuvdat, *reverse_otheruvdat;
{
  IGRboolean my_oriented, other_oriented;
  IGRboolean midfirst;
  IGRint i, j, inx, midinx, numxyzpts;
  IGRlong msg_loc, stat_func;
  IGRdouble myuvpt[3], otheruvpt[3];
  IGRdouble *xyzpts, zerodot_tol;
  IGRvector orntvec;
  struct IGRpolyline *xyzpy;

  *msg = EMS_S_Success;

  /*
   * Initialize working variables
   */

  zerodot_tol = cos ((90.0 - EMS_ZEROANGLE_DEG) * (M_PI / 180.0));
  my_oriented = FALSE;
  other_oriented = FALSE;
  
  if (myxyzdat->datatype == EMSdata_poly3d)
    xyzpy = myxyzdat->data.poly;
  else
    xyzpy = otherxyzdat->data.poly;    
  numxyzpts = xyzpy->num_points;
  xyzpts = xyzpy->points;

  /*
   * Picking a point on the intersection and the direction vector (xyz)
   * in which the intersection is heading at that point, one can compute
   * the orientation. Statistically, the cahnces of finding a good point
   * on the intersection lies somewhere in the middle of the intersection.
   * But if if we have a B-spline curve as part of the intersection data
   * it might be more efficient to pick the end-points as the sampling
   * points. Therefore, the order in which points are picked as sampling
   * points (in cases when the previous point was unable to orient both
   * the uv-data), is determined.
   */

  if (myuvdat->datatype == EMSdata_poly2d &&
      otheruvdat->datatype == EMSdata_poly2d &&
      numxyzpts > MINIMUM_FOR_MIDFIRST)
    {
    midfirst = TRUE;
    midinx = (numxyzpts - 2) / 3;
    }
  else
    {
    midfirst = FALSE;
    midinx = NULL;
    }

  for (inx=0; inx<numxyzpts; inx++)
    {
    /*
     * The index of the point in the pieces of data that are being
     * looked as, goes in the order = first, last, third, fourth, ...,
     * last-but-one, second. This is done so that, the first and the
     * last points are the ones that are looked at before any internal
     * points.
     */

    if (midfirst)
      i = midinx++ % numxyzpts;
    else
      i = (inx == 0 ? 0 : (inx == 1 ? numxyzpts-1 : inx-1));
    j = i*3;

    /*
     * Get both the uv-points that correspond to a point along the
     * intersection curve. The local function call provides an insulation
     * layer from the ugliness of the datatypes,
     */
  
    getinxpt (&msg_loc, myuvdat, myxyzdat, my_srf, otheruvdat, otherxyzdat,
     other_srf, i, 
     i==0 ? EMScvint_lfend : i==numxyzpts-1 ? EMScvint_rtend : EMScvint_middle,
     myuvpt, otheruvpt);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
     
    /*
     * Obtain the unit model-space vector that indicates the direction of
     * intersection curve at the point under consideration.
     */

    if (i < numxyzpts-1)
      {
      orntvec[X] = xyzpts[j+X+3] - xyzpts[j+X];
      orntvec[Y] = xyzpts[j+Y+3] - xyzpts[j+Y];
      orntvec[Z] = xyzpts[j+Z+3] - xyzpts[j+Z];
      }
    else
      {
      orntvec[X] = xyzpts[j+X] - xyzpts[j+X-3];
      orntvec[Y] = xyzpts[j+Y] - xyzpts[j+Y-3];
      orntvec[Z] = xyzpts[j+Z] - xyzpts[j+Z-3];
      }
    BSnorvec (&msg_loc, orntvec);
    if (msg_loc != BSSUCC)
      continue;

    /*
     * Call the internal function that actually finds out if the orientation
     * is correct or not on the two surfaces.
     */

    getuvorient_atpt (&msg_loc, my_srf, other_srf, myuvpt, otheruvpt,
     orntvec, orient_right, zerodot_tol, reverse_myuvdat, reverse_otheruvdat,
     &my_oriented, &other_oriented);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (my_oriented && other_oriented)
      goto ret_end;
    }

  if (! my_oriented || ! other_oriented)
    *msg = EMS_I_IntersectOrient;
  
ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, stat_func, "EMgetuvorient");
}



/*
 * This support function is really where the orientation takes
 * place. It is designed to be called from any place, but is best suited
 * for being called by the above function. For now it is made static.
 */

static void getuvorient_atpt (msg, my_srf, other_srf, myuvpt, otheruvpt,
                              intvecatpt, orient_right, zerodot_tol,
                              reverse_mydat, reverse_otherdat,
                              myoriented, otheroriented)
IGRlong *msg;
struct IGRbsp_surface *my_srf, *other_srf;
IGRdouble *myuvpt, *otheruvpt, *intvecatpt;
IGRboolean orient_right;
IGRdouble zerodot_tol;
IGRboolean *reverse_mydat, *reverse_otherdat;
IGRboolean *myoriented, *otheroriented;
{
  IGRlong msg_loc, size;
  IGRdouble points[6], dotp;
  IGRvector my_norm, mynat_norm, other_norm, othernat_norm;
  IGRvector cross_vec;
  extern IGRboolean BScrossp();
  extern IGRdouble BSdotp();
  void EMavgsfnorm();

  *msg = EMS_S_Success;
  size = 3 * sizeof (IGRdouble);

  /*
   * Obtain the natural and the outward-pointing normal
   * at the specified input point on the two surfaces.
   */

  EMavgsfnorm (&msg_loc, my_srf, myuvpt[U], myuvpt[V], points,
   mynat_norm);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NoSolution, *msg, msg_loc, ret_end);

  if (my_srf->pos_orient)
    {
    my_norm[X] = -mynat_norm[X];
    my_norm[Y] = -mynat_norm[Y];
    my_norm[Z] = -mynat_norm[Z];
    }
  else
    OM_BLOCK_MOVE (mynat_norm, my_norm, size);
   
  EMavgsfnorm (&msg_loc, other_srf, otheruvpt[U], otheruvpt[V], points,
   othernat_norm);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NoSolution, *msg, msg_loc, ret_end);

  if (other_srf->pos_orient) 
    {
    other_norm[X] = -othernat_norm[X];
    other_norm[Y] = -othernat_norm[Y];
    other_norm[Z] = -othernat_norm[Z];
    }
  else
    OM_BLOCK_MOVE (othernat_norm, other_norm, size);
    
  /* 
   * Orient the parametric data on my-surface, if such has been
   * the request.
   */
  
  if (! *myoriented)
    {
    BScrossp (&msg_loc, intvecatpt, other_norm, cross_vec);
    dotp = BSdotp (&msg_loc, cross_vec, mynat_norm);
      
    if (fabs (dotp) >= zerodot_tol)
      {
      *myoriented = TRUE;
      if ((orient_right && dotp < 0) || (!orient_right && dotp > 0))
        *reverse_mydat = TRUE;
      else
        *reverse_mydat = FALSE;
      }
    }

  /* 
   * Orient the parametric data on other-surface, if such has been
   * the request.
   */
  
  if (! *otheroriented)
    { 
    BScrossp (&msg_loc, intvecatpt, my_norm, cross_vec);
    dotp = BSdotp (&msg_loc, cross_vec, othernat_norm);
    
    if (fabs (dotp) >= zerodot_tol)
      {
      *otheroriented = TRUE;
      if ((orient_right && dotp < 0) || (!orient_right && dotp > 0))
        *reverse_otherdat = TRUE;
      else
        *reverse_otherdat = FALSE;
      }
    }

ret_end:;
}


/*
 * An internally called function that returns a specific point from the
 * uv-data pieces supplied to it. The point is returned for both spaces.
 */

static void getinxpt (msg, myuvdat, myxyzdat, my_srf, otheruvdat, otherxyzdat, 
                      other_srf, ptinx, position,
                      myuvpt, otheruvpt)
IGRlong *msg;
struct EMSdataselect *myuvdat, *myxyzdat, *otheruvdat, *otherxyzdat;
struct IGRbsp_surface *my_srf, *other_srf;
IGRint ptinx;
enum EMScvinttype position;
IGRdouble *myuvpt, *otheruvpt;
{
  IGRlong msg_loc;
  IGRboolean map, flip;
  IGRint size, inx;
  IGRdouble *xyzpt, newxyzpt[3], dist, *uvpt;
  IGRdouble minu, minv, maxu, maxv;
  struct EMSdataselect *xyzdat, *uvdat;
  struct IGRbsp_surface *sf;
  struct EMSpypoint pypoint;
  void EMmap_trim_point();
  IGRlong EMinternalpt();

  *msg = EMS_S_Success;

  flip = FALSE;
  map = FALSE;
  size = 2 * sizeof (IGRdouble);

  inx = ptinx * 2; 
  if (myuvdat->datatype == EMSdata_poly2d)
    {
    OM_BLOCK_MOVE (&myuvdat->data.poly->points[inx], myuvpt, size);
    map = !map;
    }
  if (otheruvdat->datatype == EMSdata_poly2d)
    {
    OM_BLOCK_MOVE (&otheruvdat->data.poly->points[inx], otheruvpt, size);
    map = !map;
    flip = TRUE;
    }

  if (map)
    {
    if (position == EMScvint_lfend || position == EMScvint_rtend)
      {
      EMinternalpt (&msg_loc, NULL, NULL, myuvdat, position, 1, myuvpt);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      EMinternalpt (&msg_loc, NULL, NULL, otheruvdat, position, 1, otheruvpt);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    else
      {   
      inx = 3 * ptinx;
      if (flip)
        {
        xyzdat = myxyzdat;
        uvdat = myuvdat;
        xyzpt = &otherxyzdat->data.poly->points[inx];
        sf = my_srf;
        }
      else
        {
        xyzdat = otherxyzdat;
        uvdat = otheruvdat;
        xyzpt = &myxyzdat->data.poly->points[inx];
        sf = other_srf;
        }
  
      EMmap_trim_point (&msg_loc, sf, xyzdat, uvdat, NULL, xyzpt,
       &pypoint, newxyzpt, &dist);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      OM_BLOCK_MOVE(pypoint.point, (flip ? myuvpt : otheruvpt), 
		    2 * sizeof (IGRdouble));
      }

    /*
     * The uv-points computed on B-spline uv-curve data may be slightly
     * out of bounds due to floating-point errors. So truncate values
     * to the surface bounds.
     */

    for (inx=MY; inx<=OTHER; inx++)
      {
      sf = inx == MY ? my_srf : other_srf;
      uvpt = inx == MY ? myuvpt : otheruvpt;

      minu = sf->u_knots[sf->u_order-1];
      minv = sf->v_knots[sf->v_order-1];
      maxu = sf->u_knots[sf->u_num_poles];
      maxv = sf->v_knots[sf->v_num_poles];

      if (uvpt[U] < minu)
        uvpt[U] = minu;
      else if (uvpt[U] > maxu)
        uvpt[U] = maxu;

      if (uvpt[V] < minv)
        uvpt[V] = minv;
      else if (uvpt[V] > maxv)
        uvpt[V] = maxv;
      }
    }

ret_end:; 
}

