/*
  OVERVIEW

  This file contains the APIs to evaluate the various point-values on a surface
  such as, curvature, normals, tangents, etc. The surface is specified by it's
  object-id, object-space number and the transformation matrix into world-
  coordinates -- identity if the surface lives in the master file. The points
  of interest are specified as an array of [U,V] pairs or alternately as
  a matrix of points in UV space. The latter means should be used whenever
  possible (eg: analyzing a surface for it's smoothness). It is optimized for
  performance.


  HISTORY

  SS  :  04/25/96   :  Creation
*/

#include <alloca.h>
#include <memory.h>

#include "bserr.h"
#include "bsparameters.h"
#include "madef.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

#include "PWapi/sfeval.h"
#include "PWapi/sfgeom.h"
#include "PWapi/sflp.h"
#include "PWapi/mx.h"
#include "PWapi/mkvec.h"
#include "PWapi/lenvec.h"
#include "PWapi/xyztol.h"
#include "prototypes/bssfptseval.h"
#include "prototypes/bssfarrev0.h"
#include "prototypes/bseval.h"
#include "prototypes/bssfarrevt.h"
#include "prototypes/bssfevaln.h"
#include "prototypes/bssfarrevn.h"

/*
  DESCRIPTION

  The following function evaluates the given surface at the given parametric
  points ('uv_pts') and returns the corresponding points in model-space
  ('xyz_pts'). The space for the output is allocated by the caller ('num_pts' *
  sizeof (PWpoint)).

  A second function is provided for when the UV points form a matrix. This
  function is optimized for this purpose. The evaluated points are returned
  as a one-dimensional array of points in U-major order. Space for these needs 
  to be allocated by the caller ('num_upts' * 'num_vpts' * sizeof (PWpoint)).
*/

PWresult pwGetSfPts
(
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_pts,
  PWpoint2d *uv_pts,

  PWpoint *xyz_pts
)
{
  BSrc rc=BSSUCC;
  PWresult result=PW_K_Success;
  struct IGRbsp_surface *sf;

  result = PW_GetSfBspsfStack (sfobj, os, xmattyp, xmat, sf);
  OnErrorCode (result, wrapup);

  BSsfptseval (sf, num_pts, (double *) uv_pts, (double *) xyz_pts, &rc);
  OnErrorState (rc != BSSUCC, result, SetError (PW_K_BspMath, PW_K_Error),
   wrapup);

wrapup:
  PW_WrapupId (result, "pwGetSfPts", sfobj);
  return (result);
}

PWresult pwGetSfArrayPts
(
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWpoint *xyz_pts
)
{
  BSrc rc=BSSUCC;
  PWresult result=PW_K_Success;
  struct IGRbsp_surface *sf;

  result = PW_GetSfBspsfStack (sfobj, os, xmattyp, xmat, sf);
  OnErrorCode (result, wrapup);

  BSsfarrev0 (&rc, sf, num_upts, uvals, num_vpts, vvals, (double *) xyz_pts);
  OnErrorState (rc != BSSUCC, result, SetError (PW_K_BspMath, PW_K_Error),
   wrapup);

wrapup:
  PW_WrapupId (result, "pwGetSfArrayPts", sfobj);
  return (result);
}



/*
  DESCRIPTION

  The following function evaluates the given surface at the given parametric
  points ('uv_pts') and returns the corresponding unit tangent
  vectors ('unit_utans' and 'unit_vtans') in the U-parametric direction and the
  V-parametric direction. An array of model-space points corresponding to the 
  input UV points is also returned. The space for each output array is
  allocated by the caller (vector arrays -- 'num_pts' * sizeof (PWvector) and
  the points array -- 'num_pts' * sizeof (PWpoint)). 

  The magnitude of the first partial derivatives in U and V direction, 
  respectively, are also optionally returned. Sending in a NULL for these
  arguments indicates that the user does not want this output. In case they
  are to be output, space must be allocated by the caller ('num_pts' * sizeof
  (double)).

  A second function is provided for when the UV points form a matrix. This
  function is optimized for this purpose. The evaluated tangents are returned
  as a one-dimensional array of vectors in U-major order. Space for these
  needs to be allocated by the caller ('num_upts' * 'num_vpts' * 
  sizeof (PWvector or PWpoint)). Note that this function does not return
  the magnitudes of the first derivatives. Use the regular function if 
  interested in this output.

  
  NOTES

  If the parametric point lies on a cusp, the tangent returned is always the
  one corresponding to the portion of the surface that approaches the point
  (ie, to the left of the point).
*/

PWresult pwGetSfTangents
(
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_pts,
  PWpoint2d *uv_pts,

  PWpoint *xyz_pts,
  PWvector *unit_utans,
  double *u_derivative,
  PWvector *unit_vtans,
  double *v_derivative
)
{
  int i, j;
  double uval, vval;
  PWresult result=PW_K_Success;
  BSrc rc=BSSUCC;
  PWpoint outpts[4];
  struct IGRbsp_surface *sf;

  result = PW_GetSfBspsfStack (sfobj, os, xmattyp, xmat, sf);
  OnErrorCode (result, wrapup);

  for (i=0; i<num_pts; i++)
  {
    BSsfeval (sf, uv_pts[i][U], uv_pts[i][V], 1, outpts, &rc);
    OnErrorState (rc != BSSUCC, result, SetError (PW_K_BspMath, PW_K_Error),
     wrapup);

    memcpy (xyz_pts[i], outpts[0], sizeof (PWpoint));
    uval = pwLenVec (outpts[1]);
    vval = pwLenVec (outpts[2]);
    for (j=0; j<3; j++)
    {
      unit_utans[i][j] = outpts[1][j] / uval;
      unit_vtans[i][j] = outpts[2][j] / vval;
    }
    if (u_derivative)
      u_derivative[i] = uval;
    if (v_derivative)
      v_derivative[i] = vval;
  }

wrapup:
  PW_WrapupId (result, "pwGetSfTangents", sfobj);
  return (result);
}

PWresult pwGetSfArrayTangents
(
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWpoint *xyz_pts,
  PWvector *unit_utans,
  PWvector *unit_vtans
)
{
  int i, j, row_inx, inx;
  BSrc rc=BSSUCC;
  PWresult result=PW_K_Success;
  PWpoint *outpts;
  struct IGRbsp_surface *sf;

  result = PW_GetSfBspsfStack (sfobj, os, xmattyp, xmat, sf);
  OnErrorCode (result, wrapup);

  outpts = (PWpoint *) alloca (3 * num_upts * num_vpts * sizeof (PWpoint));
  BSsfarrevt (sf, num_upts, uvals, num_vpts, vvals, 1.0, (double *) outpts,
   &rc);
  OnErrorState (rc != BSSUCC, result, SetError (PW_K_BspMath, PW_K_Error),
   wrapup);

  for (i=0; i<num_vpts; i++)
  {
    row_inx = num_upts * i;
    for (j=0; j<num_upts; j++)
    {
      inx = row_inx + j;

      memcpy (xyz_pts[inx], outpts[inx*3], sizeof (PWpoint));
      pwMakeVec (outpts[inx*3 + 1], xyz_pts[inx], unit_utans[inx]);
      pwMakeVec (outpts[inx*3 + 2], xyz_pts[inx], unit_vtans[inx]);
    }
  }

wrapup:
  PW_WrapupId (result, "pwGetSfArrayTangents", sfobj);
  return (result);
}


/*
  DESCRIPTION

  The following function evaluates the given surface at the given parametric
  points ('uv_pts') and returns the corresponding unit normal
  vectors ('unit_norms'). An array of model-space points corresponding to the 
  input UV points is also returned. The space for each output array is
  allocated by the caller (vector array -- 'num_pts' * sizeof (PWvector) and
  the points array -- 'num_pts' * sizeof (PWpoint)). 

  A second function is provided when the UV points form a matrix. This function
  is optimized for this purpose. The evaluated normals are returned as a
  one-dimensional array of vectors in U-major order. Space for these needs to
  be allocated by the caller ('num_upts' * 'num_vpts' * sizeof (PWvector or
  PWpoint)).

  
  NOTES

  If the parametric point lies on a cusp, the normal returned is always the
  one corresponding to the portion of the surface that approaches the point
  (ie, to the left of the point).

  The direction of the normal will always point in the direction of the 
  cross-product between the U-direction tangent and the V-direction tangent.
  Using the API -- PWboolean pwIsSfNormalReversed (sfobj, os) -- one can 
  determine if this direction has to be reversed in order to point the normal
  towards the volume side of the surface.

  The normal at a given point returned by this function will be identical to
  the unit-cross product between the U-tangent and the V-tangent vectors, 
  except in the case where the surface degenerates (eg: the degeneracy point
  on a surface where one of the 4 sides is collapsed giving rise to a 3-sided
  surface). At such a point the tangents may come out undefined, but the normal
  is well-defined.
*/

PWresult pwGetSfNormals
(
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_pts,
  PWpoint2d *uv_pts,

  PWpoint *xyz_pts,
  PWvector *unit_norms
)
{
  int i, dumnum;
  PWresult result=PW_K_Success;
  BSrc rc=BSSUCC;
  struct IGRbsp_surface *sf;

  result = PW_GetSfBspsfStack (sfobj, os, xmattyp, xmat, sf);
  OnErrorCode (result, wrapup);

  for (i=0; i<num_pts; i++)
  {
    BSsfevaln (sf, uv_pts[i][U], uv_pts[i][V], 1, &dumnum, 
     xyz_pts[i], (double (*)[3]) unit_norms[i], &rc);
    OnErrorState (rc != BSSUCC, result, SetError (PW_K_BspMath, PW_K_Error),
     wrapup);
  }

wrapup:
  PW_WrapupId (result, "pwGetSfNormals", sfobj);
  return (result);
}

PWresult pwGetSfArrayNormals
(
  PWobjid sfobj,
  PWosnum os,
  short xmattyp,
  PWmatrix xmat,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWpoint *xyz_pts,
  PWvector *unit_norms
)
{
  BSrc rc=BSSUCC;
  PWresult result=PW_K_Success;
  struct IGRbsp_surface *sf;

  result = PW_GetSfBspsfStack (sfobj, os, xmattyp, xmat, sf);
  OnErrorCode (result, wrapup);

  BSsfarrevn (&rc, sf, num_upts, uvals, num_vpts, vvals, (double *) xyz_pts,
   (double *) unit_norms);
  OnErrorState (rc != BSSUCC, result, SetError (PW_K_BspMath, PW_K_Error),
   wrapup);

wrapup:
  PW_WrapupId (result, "pwGetSfArrayNormals", sfobj);
  return (result);
}

/*
  DESCRIPTION

  The following function evaluates the given surface at the given parametric
  points ('uv_pts') and returns a Boolean flag indicating
  whether the point lies within the boundary of the surface or not. Point
  lying on the boundary within the current zero-length tolerance (or basis
  tolerance) is considered within the boundary. The space for the output is
  allocated by the caller ('num_pts' * sizeof (PWboolean)).

  A second function is provided, if the UV points form a matrix. This function
  is provided as a convenience to users who are interested in output related
  to a matrix of UV points. There is no optimization value to this function.
  The TRUE/FALSE flags are returned as a one-dimensional array in U-major
  order. Space for these needs to be allocated by the caller ('num_upts' * 
  'num_vpts' * sizeof (PWboolean)).
*/

PWresult pwGetSfPtsInBdry
(
  PWobjid sfobj,
  PWosnum os,
  int num_pts,
  PWpoint2d *uv_pts,

  PWboolean *is_inbdry
)
{
  int i, check_num=0, num_outer_faces=0, num_total_loops=0;
  double xyztol;
  PWresult result=PW_K_Success;
  PWobjid *outer_faces, loc_bdryid;
  PWmatrix mx;
  PWpoint *xyz_pts;
  struct IGRbsp_surface *sf;
  struct PWcvpt loc_edpt;
  enum PWptloctype loc_ptloc;

  result = PW_GetSfBspsfStack (sfobj, os, MAIDMX, pwIdMx (mx), sf);
  OnErrorCode (result, wrapup);

  xyz_pts = (PWpoint *) alloca (num_pts * sizeof (PWpoint));
  result = pwGetSfPts (sfobj, os, MAIDMX, mx, num_pts, uv_pts, xyz_pts);
  OnErrorCode (result, wrapup);

  xyztol = pwActiveXYZLenTol();

  num_outer_faces = pwNumOuterFacesOfSf (sfobj, os);

  if (num_outer_faces)
  {
    outer_faces = (PWobjid *) alloca (num_outer_faces * sizeof (PWobjid));
    check_num = pwOuterFacesOfSf (sfobj, os, outer_faces);
    OnErrorState (check_num != num_outer_faces, result, 
     SetError (PW_K_Pathway, PW_K_Error), wrapup);

    num_total_loops = pwNumLpsOfSf (sfobj, os);
    OnErrorState (num_total_loops < num_outer_faces, result, 
     SetError (PW_K_Pathway, PW_K_Error), wrapup);

    for (i=0; i<num_pts; i++)
    {
      result = SfGeomPtLocate (sf, os, xyz_pts[i], uv_pts[i], xyztol,
                num_outer_faces, outer_faces, num_total_loops,
                &loc_ptloc, &loc_bdryid, &loc_edpt);
      OnErrorCode (result, wrapup);

      if (loc_ptloc == PWptloc_onstartvtx ||
          loc_ptloc == PWptloc_onstopvtx ||
          loc_ptloc == PWptloc_onedge ||
          loc_ptloc == PWptloc_inarea)
        is_inbdry[i] = TRUE;
      else
        is_inbdry[i] = FALSE;
    }   
  }
  else
  {
    /*
     * The surface does not have a boundary. That is the entire surface
     * is considered as area. Return TRUE for the every UV point.
     */

    for (i=0; i<num_pts; i++)
      is_inbdry[i] = TRUE;
  }

wrapup:
  PW_WrapupId (result, "pwGetSfPtsInBdry", sfobj);
  return (result);
}

PWresult pwGetSfArrayPtsInBdry
(
  PWobjid sfobj,
  PWosnum os,
  int num_upts,
  double *uvals,
  int num_vpts,
  double *vvals,

  PWboolean *is_inbdry
)
{
  int i, j, inx, row_inx, num_uvpts;
  PWpoint2d *uv_pts;

  num_uvpts = num_upts * num_vpts;
  uv_pts = (PWpoint2d *) alloca (num_uvpts * sizeof (PWpoint2d));

  for (i=0; i<num_vpts; i++)
  {
    row_inx = num_upts * i;
    for (j=0; j<num_upts; j++)
    {
      inx = row_inx + j;

      uv_pts[inx][U] = uvals[j];
      uv_pts[inx][V] = vvals[i];
    }
  }

  return (pwGetSfPtsInBdry (sfobj, os, num_uvpts, uv_pts, is_inbdry));
}
