/* 
  DESCRIPTION

    This function maps an xyz dataselect curve (xyzcv) (3D polyline or 3D
    B-spline) onto a bspline surface (srf) and outputs a uv dataselect curve
    (uvcv). If the surface is found to be a special plane and the input curve
    is a 3-D bspline curve, a curve of EMSdata_curve3d type is returned.
    Otherwise, the mapped curve is of type EMSdata_poly2d. 

  ARGUMENTS

    options		EMS_RMED_ALNG_NATBDRY
                        See EMSbnddef.h for explanations.

    cht_tol		Chord-height tolerance to be used in stroking
			and mapping the curve.

    par_tol		Parametric tolerance to be used in trimming the
			mapped curve.

    is_sf_planar        I/O. Flag stating whether the surface is a special
                        plane or not (EMS_O_Planar or EMS_O_NonPlanar). If not
                        known, specify EMS_O_Unknown. In the latter case,
                        the function will determine this for itself and return
                        EMS_O_Planar or EMS_O_NonPlanar


  HISTORY

    ?????? ??/??/??   Creation
    Aditya 8/24/95    The function EMmapcvxyz_to_uv() has been renamed as
                      EMmapcvxyz_to_uv_mod() to include an argument
                      closest_pt. EMmapcvxyz_to_uv() was using the mid point
                      of the xyz curve(refpt) to retain a group closest to it
                      in wrapup. Now EMmapcvxyz_to_uv_mod() allows the passing
                      of a point by the caller to decide which of the mapped
                      groups is to be retained or NULL if use of mid-point
                      is good enough.
      
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
#include "EMSbnddef.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "EMSbnd.h"
#include "emserr.h"
#include "EMSwrmacros.h"

#define START 0
#define STOP  1

#define U 0
#define V 1

static IGRboolean is_okmap();

void EMmapcvxyz_to_uv (msg, options, srf, xyzcv, cht_tol, par_tol,
                  is_sf_planar, uvcv, all_points_on_srf)
IGRlong *msg;
IGRushort options;
struct IGRbsp_surface *srf;
struct EMSdataselect *xyzcv;
IGRdouble cht_tol, par_tol;
IGRshort *is_sf_planar;
struct EMSdataselect *uvcv;
IGRboolean *all_points_on_srf;
{
  void EMmapcvxyz_to_uv_mod();

  EMmapcvxyz_to_uv_mod (msg, options, srf, xyzcv, cht_tol, par_tol,
                       is_sf_planar, uvcv, all_points_on_srf, NULL);

  return;
}

void EMmapcvxyz_to_uv_mod (msg, options, srf, xyzcv, cht_tol, par_tol, 
                       is_sf_planar, uvcv, all_points_on_srf, closest_pt)
IGRlong	*msg;
IGRushort options;
struct IGRbsp_surface *srf;
struct EMSdataselect *xyzcv;
IGRdouble cht_tol, par_tol;
IGRshort *is_sf_planar;
struct EMSdataselect *uvcv;
IGRboolean *all_points_on_srf;
IGRdouble *closest_pt;
{
  IGRboolean linear_map_ok, stroked_xyz, is_degenerate[2][2];
  IGRboolean all_points_within_range, all_points_within_tolerance;
  IGRint i, j, blksize, num_pnts, num_bytes, num, num_grp = 1;
  IGRint *loc_numpts_grp = NULL;
  IGRlong msg_loc, msg_save;
  IGRdouble *xyz_pnts, *uv_pnts, old_cht;
  IGRdouble **loc_xyzpts = NULL, **loc_uvpts = NULL;
  IGRpoint refpt;
  struct IGRpolyline polyline, xyzpy, uvpy;
  struct EMSdataselect *p_uvdata, xyzdata, uvdata;
  union EMSdata	in_data;
  enum EMSdatatype out_data_type;

  *msg = EMS_S_Success;

  uv_pnts = NULL;
  polyline.points = NULL;

  stroked_xyz = FALSE;

  /*
   * Unless input, determine if a linear map is possible on the
   * input surface.
   */

  if (*is_sf_planar == EMS_O_Unknown)
    {
    linear_map_ok = FALSE;
    EFis_linear_map_ok (&msg_loc, srf, &linear_map_ok);
		
    if (linear_map_ok)
      *is_sf_planar = EMS_O_Planar;
    else
      *is_sf_planar = EMS_O_NonPlanar;
    }

  /*
   * Obtain the xyz-points that have to be mapped into the uv-space.
   * If this a higher order B-spline, then: a) if a linear map is possible,
   * then only the unweighted poles are to be mapped, b) else the input
   * curve is stroked and the stroked points mapped.
   */

  in_data = xyzcv->data;
  if (xyzcv->datatype == EMSdata_poly3d)
    {
    num_pnts = in_data.poly->num_points;
    xyz_pnts = in_data.poly->points;

    out_data_type = EMSdata_poly2d;
    }
  else if (xyzcv->datatype == EMSdata_curve3d)
    {
    if (*is_sf_planar == EMS_O_Planar)
      {
      num_pnts = in_data.curve->num_poles;
      if (in_data.curve->rational)
        {
        xyz_pnts = (IGRdouble *) alloca (num_pnts * sizeof (IGRpoint));
        OM_BLOCK_MOVE (in_data.curve->poles, xyz_pnts, 
         num_pnts * sizeof (IGRpoint));

        for (i=0; i<num_pnts; i++)
          for (j=3*i; j<3*i+3; j++)
            xyz_pnts[j] /= in_data.curve->weights[i];
	}
      else
        xyz_pnts = in_data.curve->poles;

      out_data_type = EMSdata_curve3d;
      }
     else
      {
      EFstroke_the_curve (in_data.curve, &cht_tol, &polyline, &msg_loc);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      num_pnts = polyline.num_points;
      xyz_pnts = polyline.points;

      out_data_type = EMSdata_poly2d;
      if (in_data.curve->order != 2)
        stroked_xyz = TRUE;
      }
    }
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

  /*
   * Map the points on the surface's parametric space.
   */

  uv_pnts = (IGRdouble *) om$malloc (size = num_pnts * 2 * sizeof (IGRdouble));
  EMerr_hndlr (!uv_pnts, *msg, EMS_E_NoDynamicMemory, ret_end);
	
  if (*is_sf_planar == EMS_O_Planar)
    {
    EFmap_xyz_to_uv_for_planes (&msg_loc, srf, 2 * cht_tol, par_tol,
     num_pnts, xyz_pnts,
     &all_points_within_range, &all_points_within_tolerance, FALSE, 
     uv_pnts);
    EMerr_hndlr (EMSerror (msg_loc) || 
     (options & EMS_TRIM_AGAINST_NATBDRY ? !all_points_within_range : FALSE),
     *msg, EMS_E_Fail, ret_end);

    *all_points_on_srf = all_points_within_range &&
                          all_points_within_tolerance;
    }
  else
    {
    BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, old_cht);
    BSchangepar (&msg_loc, BSTOLCHRDHT, cht_tol);
		
    BSprptsonsf (num_pnts, xyz_pnts, srf, uv_pnts, all_points_on_srf,
     &msg_save);
    BSchangepar (&msg_loc, BSTOLCHRDHT, old_cht);
    EMerr_hndlr (msg_save != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }

  /*
   * Format the output curve
   */

  if (out_data_type == EMSdata_poly2d)
    {
    if (*is_sf_planar != EMS_O_Planar)
      {
      /*
       * There is a possibility that the mapping has 
       * produced data that needs some fixing, due to the
       * crazy relationship between xyz and uv spaces. Also, do a final
       * check at the end-points of the data to see if the uv and xyz
       * ends are within tolerance. Things may go wrong because of bad
       * clipping of data as the input xyz-curve drops off the natural
       * boundary of the surface.
       */

      blksize = num_pnts * 3 * sizeof (IGRdouble);
      loc_numpts_grp = (IGRint *) om$malloc (size = sizeof (IGRint));
      loc_xyzpts = (IGRdouble **) om$malloc (size = sizeof (IGRdouble *));
      loc_xyzpts[0] = (IGRdouble *) om$malloc (size = blksize);
      loc_uvpts = (IGRdouble **) om$malloc (size = sizeof (IGRdouble *));
      EMerr_hndlr (!loc_numpts_grp || !loc_xyzpts || !loc_xyzpts[0] || 
       !loc_uvpts, *msg, EMS_E_NoDynamicMemory, freeloc);

      loc_numpts_grp[0] = num_pnts;
      OM_BLOCK_MOVE (xyz_pnts, loc_xyzpts[0], blksize);
      loc_uvpts[0] = uv_pnts;
      uv_pnts = NULL;

      if (!stroked_xyz)
        {
        /*
         * If the input xyz-data has not been stroked, run the data
         * through stroke-linestring, which checks if the line-segments
         * defined in uv-space all yield xyz-data, within chord-height
         * of the input xyz-data. If not, more points are added to make
         * the line-string more exact. This function also resolves
         * mapping to the wrong seam-edge. But when it does this it
         * might not have fully satisfied the previous criteria. In
         * this latter case, call the function again.
         */

        ems$stroke_line_string (msg = &msg_loc, surface = srf,
         partolbasis = par_tol, num_points = (IGRlong *) &loc_numpts_grp[0],
         xyz_points = &loc_xyzpts[0], uv_points = &loc_uvpts[0]);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, freeloc);

        if (srf->u_phy_closed || srf->v_phy_closed)
          {
          ems$stroke_line_string (msg = &msg_loc, surface = srf,
           partolbasis = par_tol, num_points = (IGRlong *) &loc_numpts_grp[0],
           xyz_points = &loc_xyzpts[0], uv_points = &loc_uvpts[0]);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, freeloc);
          }
        }

      EFclassify_degenerate_edges (srf, is_degenerate, &msg_loc);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, freeloc);

      EFfix_uv_on_degenerate_edges (srf, par_tol, is_degenerate,
       &loc_numpts_grp[0], &loc_uvpts[0], &loc_xyzpts[0], &msg_loc);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, freeloc);

      EFfix_the_int (NULL, options & EMS_RMED_ALNG_NATBDRY, srf, NULL,
       &num_grp, &loc_numpts_grp, &loc_xyzpts, &loc_uvpts, NULL, &msg_loc);
      EMerr_hndlr (EMSerror (msg_loc) || num_grp != 1, *msg, EMS_E_Fail,
       freeloc);

      xyzdata.datatype = EMSdata_poly3d;
      xyzdata.data.poly = &xyzpy;
      xyzpy.num_points = loc_numpts_grp[0];
      xyzpy.points = loc_xyzpts[0];
     
      uvdata.datatype = EMSdata_poly2d;
      uvdata.data.poly = &uvpy;
      uvpy.num_points = loc_numpts_grp[0];
      uvpy.points = loc_uvpts[0];

      EFmaptobnd (&msg_loc, NULL, srf, cht_tol, &xyzdata, &uvdata);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, freeloc);

      EMerr_hndlr (!is_okmap (srf, cht_tol, &xyzdata, &uvdata), *msg,
       EMS_E_Fail, freeloc);

      freeloc:
      if (loc_numpts_grp)
        {
        if (! EMSerror (*msg))
          num_pnts = loc_numpts_grp[0];
        om$dealloc (ptr = loc_numpts_grp);
        }
      if (loc_xyzpts)
        {
        for (i=0; i<num_grp; i++)
          if (loc_xyzpts[i])
            om$dealloc (ptr = loc_xyzpts[i]);
        om$dealloc (ptr = loc_xyzpts);
        }
      if (loc_uvpts)
        {
        if (! EMSerror (*msg))
          uv_pnts = loc_uvpts[0];
        else
          for (i=0; i<num_grp; i++)
            if (loc_uvpts[i])
              om$dealloc (ptr = loc_uvpts[i]);
        om$dealloc (ptr = loc_uvpts);
        }
      if (EMSerror (*msg))
        goto ret_end;
      }

    uvcv->datatype = EMSdata_poly2d;
    uvcv->data.poly = NULL;
    uvcv->data.poly = (struct IGRpolyline *) om$malloc ( size =
                       sizeof(struct IGRpolyline));
    EMerr_hndlr (!(uvcv->data.poly), *msg, EMS_E_NoDynamicMemory, ret_end);
    uvcv->data.poly->num_points = num_pnts;
    uvcv->data.poly->points = uv_pnts;
    uv_pnts = NULL;
    }
  else
    {
    struct IGRbsp_curve *crv_xyz, *crv_uv;
    IGRdouble *temp_poles, *temp_knots, *temp_weights;

    crv_uv = NULL;
    crv_xyz = in_data.curve;

    BSalloccv (crv_xyz->order, crv_xyz->num_poles, crv_xyz->rational,
     0, &crv_uv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoDynamicMemory, ret_end);

    temp_poles = crv_uv->poles;
    temp_knots = crv_uv->knots;
    temp_weights = crv_uv->weights;
    *crv_uv = *crv_xyz;

    for (j=0; j<crv_uv->num_poles; j++)
      {
      temp_poles[3*j] = uv_pnts[2*j];
      temp_poles[3*j+1] = uv_pnts[2*j+1];
      temp_poles[3*j+2] = 0;
      }
    crv_uv->poles = temp_poles;

    num_bytes = crv_uv->num_knots * sizeof (IGRdouble);
    OM_BLOCK_MOVE (crv_xyz->knots, temp_knots, num_bytes);
    crv_uv->knots = temp_knots;

    if (crv_xyz->rational)
      {
      num_bytes = crv_uv->num_poles * sizeof(IGRdouble);
      OM_BLOCK_MOVE (crv_xyz->weights, temp_weights, num_bytes);
	
      for (i=0; i<crv_uv->num_poles; i++)
        for (j=3*i; j<3*i+2; j++) 
          crv_uv->poles[j] *= crv_xyz->weights[i];
      crv_uv->weights = temp_weights;
      }

    uvcv->datatype = EMSdata_curve3d;
    uvcv->data.curve = crv_uv;
    }

ret_end:
   if (uv_pnts)
     om$dealloc (ptr = uv_pnts);
   if (polyline.points)
     om$dealloc (ptr = polyline.points);
  
   /*
    * If there has been a failure for whatever reason, make another attempt
    * at succeeding by following a different path.
    * If closest_pt is not passed in, get the mid-point of xyzcv and retain
    * the mapped group that is closest to it.
    */

   if (EMSerror (*msg))
   {
     if( !closest_pt)
     {
       EMinternalpt (&msg_loc, NULL, NULL, xyzcv, EMScvint_middle, 1, refpt);
       if (!EMSerror (msg_loc))
             *msg = EMS_S_Success;
     }
     else
     {
       memcpy(refpt, closest_pt, 3*sizeof(IGRdouble));
     }
     p_uvdata = uvcv;
     EMpjcvnsrf (&msg_loc, NULL, srf, xyzcv, cht_tol, refpt, &num, &p_uvdata,
      NULL);
     if (!EMSerror (msg_loc))
           *msg = EMS_S_Success;
   }

   return;
}


static IGRboolean is_okmap (srf, cht, xyzdata, uvdata)
struct IGRbsp_surface *srf;
IGRdouble cht;
struct EMSdataselect *xyzdata, *uvdata;
{
  IGRboolean is_ok;
  IGRshort i, mattyp;
  IGRlong msg_loc;
  IGRpoint xyz_endpts[2], uv_endpts[2], uv_xyz_endpts[2];
  IGRmatrix mat;

  is_ok = TRUE;

  EMidmatrix (&msg_loc, &mattyp, mat);
  EMgetendpts_xyz (&msg_loc, &mattyp, mat, xyzdata, FALSE, 1, 
   xyz_endpts[START], xyz_endpts[STOP]);

  EMgetendpts_uv (&msg_loc, uvdata, FALSE, 1, 
   uv_endpts[START], uv_endpts[STOP]);

  for (i=START; i<=STOP; i++)
    {
    BSsfeval (srf, uv_endpts[i][U], uv_endpts[i][V], 0, uv_xyz_endpts[i],
     &msg_loc);
 
    if (!EMis_geomequal_3dpt (xyz_endpts[i], uv_xyz_endpts[i], cht))
      { 
      is_ok = FALSE;
      break;
      }
    }

  return (is_ok);
}
