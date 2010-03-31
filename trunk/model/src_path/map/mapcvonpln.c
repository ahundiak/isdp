/*
  OVERVIEW

  This file contains all the functions which transform the points from 
  model-space to parametric space and vice-versa for rectangular planar
  surfaces. Also available is a function which checks whether the planar
  surface is rectangular one or not. 

  NOTES

  If the surface is not a rectangular planar surface, the functions in 
  this file should not be used.  

  HISTORY

  Sanjay       10/02/95      Creation

*/

/* Includes */
#include <stdio.h>
#include <math.h>             /* System */
#include <alloca.h>
#include <memory.h>

#include "igrtypedef.h"
#include "igr.h"        
#include "bs.h"               /* GRNUC */
#include "bsparameters.h"
#include "bsgeom_cvsf.h"

#include "PWminimum.h"
#include "PWgmdata.h"         /* Pathway */
#include "PWerror.h"

/* Prototypes */
 
#include "bscvtgeomcv.h"
#include "bscv_copy.h"        /* BS */

#include "PWapi/mapcvonpln.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/crossp.h"     /* Pathway */
#include "PWapi/normvec.h"
#include "PWapi/partol.h"

/* Static Functions */

static PWresult LinearMapXyzCvToUvOfPlane
(
  struct PWcvdata *p_xyzcv,
  struct IGRbsp_surface *p_plane,
  PWboolean clipuv,
  double xyztol,

  struct PWcvdata *p_uvcv
);

static void TransformPts
(
  int num_pts,
  PWpoint *p_pts,
  double *p_wts,
  PWpoint origin,
  double rotmat[3][3],
  PWboolean forward,

  PWpoint *p_outpts
);

static PWresult TransMatrix
(
  PWpoint p1,
  PWpoint p2,
  PWpoint p3,
  PWpoint p4,
  
  double lentol,

  double rotmat[3][3]
);

/* -------------------------------- API Listing ----------------------------- */

/*
  ABSTRACT

  Returns TRUE if the given planar surface is a rectangular one i.e. opposite
  sides are of equal length, otherwise FALSE.

  NOTES

  This function must be called before calling the following functions in this
  file, as the following functions work only in case of rectangular planar 
  surfaces.
 
  HISTORY

  Sanjay       10/02/95      Creation

*/

PWboolean pwIsLinearMapOkOnPlane
(
  struct IGRbsp_surface *p_sfgeom,
  double lentol
)
{
  if (!p_sfgeom->planar || p_sfgeom->rational || 
      p_sfgeom->u_num_poles != 2 || p_sfgeom->v_num_poles != 2 ||
      p_sfgeom->u_order != 2 || p_sfgeom->v_order != 2) 
    return FALSE;

  if (fabs (pwDistPtPt (&p_sfgeom->poles[0], &p_sfgeom->poles[3]) -
       pwDistPtPt (&p_sfgeom->poles[6], &p_sfgeom->poles[9])) > lentol)
    return FALSE;

  if (fabs (pwDistPtPt (&p_sfgeom->poles[0], &p_sfgeom->poles[6]) -
       pwDistPtPt (&p_sfgeom->poles[3], &p_sfgeom->poles[9])) > lentol)
    return FALSE;

  return TRUE;
}

/*
  ABSTRACT

  Maps a model-space curve to the parametric-space of the rectangular planar
  surface.

  DESCRIPTION

  Maps the given model-space curve to the parametric-space of the rectangular
  planar surface. A rectangular planar surface is one whose opposite sides are
  of equal length. Before calling this function one should call the "pwIsLine-
  arMapOkForPlane" function to determine whether the surface is rectangular or
  not. 

  ARGUMENTS

  p_xyzcv    - I : Model-space curve on the surface.
  p_plane    - I : Rectangular surface geometry.
  xyztol     - I : Model-space tolerance.

  p_uvcv     - O : Parametric-space curve.

  NOTES

  All the memory for the output must be allocated by the caller. It requires
  the same memory as the input curve requires.

  KEYWORDS

  Internal API, Rectangular Plane.
 
  HISTORY

  Sanjay       10/02/95      Creation

*/

PWresult pwLinearMapXyzCvToUvOfPlane
(
  struct PWcvdata *p_xyzcv,
  struct IGRbsp_surface *p_plane,
  double xyztol,
  
  struct PWcvdata *p_uvcv
)
{
  PWboolean clipuv=FALSE;

  clipuv = (p_xyzcv->datatype == PWcvdata_bspcv ||
            p_xyzcv->datatype == PWcvdata_gmbspcv) ? FALSE : TRUE;
  
  return LinearMapXyzCvToUvOfPlane (p_xyzcv, p_plane, clipuv, xyztol, p_uvcv); 
}
 
PWresult pwLinearMapXyzCvToUvOfInfPlane
(
  struct PWcvdata *p_xyzcv,
  struct IGRbsp_surface *p_plane,
  double xyztol,

  struct PWcvdata *p_uvcv
)
{
  return LinearMapXyzCvToUvOfPlane (p_xyzcv, p_plane, FALSE, xyztol, p_uvcv); 
}
 
static PWresult LinearMapXyzCvToUvOfPlane
(
  struct PWcvdata *p_xyzcv,
  struct IGRbsp_surface *p_plane,
  PWboolean clipuv,
  double xyztol,

  struct PWcvdata *p_uvcv
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean forward=TRUE; 
  enum PWcvdatatype cvtype=PWcvdata_null;
  struct IGRbsp_curve *p_cv=NULL;

  int num_pts=0, i=0, num_plnpts=0, knt=0;
  PWpoint *p_pts=NULL, *p_tmppts=NULL, plnpts[4];
  PWpoint2d *p_uvpts=NULL;
  double *p_wts=NULL, lentol=0, uvtol=0;

  int bot_left=0, bot_right=0, top_left=0, top_right=0;
  double *p1=NULL, *p2=NULL, *p3=NULL, *p4=NULL; 
  double u_min=0, v_min=0, u_max=0, v_max=0, rotmat[3][3];
  double u_ratio=0, v_ratio=0, shift=0, u_diff=0, v_diff=0, u=0, v=0;

  u_min = p_plane->u_knots [p_plane->u_order-1];
  v_min = p_plane->v_knots [p_plane->v_order-1];
  u_max = p_plane->u_knots [p_plane->u_num_poles];
  v_max = p_plane->v_knots [p_plane->v_num_poles];

  BSEXTRACTPAR (&BSmsg, BSTOLLENVEC, lentol);
  uvtol = pwGetParTolSf (p_plane, xyztol);

  cvtype = p_xyzcv->datatype;

  if (cvtype == PWcvdata_bspcv || cvtype == PWcvdata_gmbspcv)
  {
    p_cv = (cvtype == PWcvdata_bspcv) ? p_xyzcv->data.p_bspcv : 
                                        p_xyzcv->data.p_gmbspcv->bspcv ;
    num_pts = p_cv->num_poles;
    p_pts = (PWpoint *) p_cv->poles;
    p_wts = p_cv->rational ? p_cv->weights : NULL;
  }
  else if (cvtype == PWcvdata_py)
  {
    num_pts = p_xyzcv->data.py.num_pts;
    p_pts = p_xyzcv->data.py.p_pts;
    p_wts = NULL;
  }
  else if (cvtype == PWcvdata_pt)
  {
    num_pts = 1;
    p_pts = &p_xyzcv->data.pt;
    p_wts = NULL;
  }
  else 
  {
    OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                  wrapup);
  }

  bot_left  = 0; bot_right = (p_plane->u_num_poles - 1) * 3;
  top_left  = p_plane->u_num_poles * (p_plane->v_num_poles - 1) * 3; 
  top_right = bot_right + top_left;

  p1 = &p_plane->poles[bot_left];
  p2 = &p_plane->poles[bot_right];
  p3 = &p_plane->poles[top_right];
  p4 = &p_plane->poles[top_left];

  /*
   * get the rotational matrix.
   */
  PWsts = TransMatrix (p1, p2, p3, p4, lentol, rotmat);
  OnErrorCode (PWsts, wrapup);

  /*
   * transform the plane points to a new co-ordinate system.
   */
  for (i=X; i<=Z; i++)
  {
    plnpts [0][i] = p1[i];
    plnpts [1][i] = p2[i];
    plnpts [2][i] = p4[i];
  }
 
  num_plnpts = 3;

  TransformPts (num_plnpts, plnpts, NULL, p1, rotmat, forward, plnpts);
  OnErrorState (plnpts[2][Y] <= lentol || plnpts[1][X] <= lentol, PWsts,
                SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  p_tmppts = (PWpoint *) alloca (num_pts * sizeof (PWpoint));
  OnErrorState (!p_tmppts, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                wrapup);
  memcpy (p_tmppts, p_pts, num_pts * sizeof (PWpoint));

  TransformPts (num_pts, p_pts, p_wts, p1, rotmat, forward, p_tmppts);

  u_diff = u_max - u_min;
  v_diff = v_max - v_min;
  u_ratio = u_diff / plnpts[1][X];
  v_ratio = v_diff / plnpts[2][Y];
  shift = plnpts[2][X] / plnpts[2][Y];

  p_uvpts = (PWpoint2d *) alloca (num_pts * sizeof (PWpoint2d));
  OnErrorState (!p_tmppts, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                wrapup);

  for (knt=0; knt<num_pts; knt++)
  {
    /*
     * Compute V Coordinate.
     */

    v = p_tmppts[knt][Y] * v_ratio;
    if (fabs (v - v_diff) < uvtol) v = v_diff;
    if (fabs (v) < uvtol) v = 0.0;
    p_uvpts[knt][V] = v + v_min;

    if (fabs (v_min - p_uvpts[knt][V]) < lentol)
      p_uvpts[knt][V] = v_min;
    else if (p_uvpts[knt][V] < v_min)
    {
      if (clipuv) p_uvpts[knt][V] = v_min;
    }
    else if (fabs (p_uvpts[knt][V] - v_max) < lentol)
      p_uvpts[knt][V] = v_max;
    else if (p_uvpts[knt][V] > v_max)
    {
      if (clipuv) p_uvpts[knt][V] = v_max;
    }
    
    /*
     * Compute U Coordinate.
     */

    u = (p_tmppts[knt][X] - shift * p_tmppts[knt][Y]) * u_ratio; 
    if (fabs (u - u_diff) < uvtol) u = u_diff;
    if (fabs (u) < uvtol) u = 0.0;
    p_uvpts[knt][U] = u + u_min;

    if (fabs (p_uvpts[knt][U] - u_min) < lentol)
      p_uvpts[knt][U] = u_min;
    else if (p_uvpts[knt][U] < u_min)
    {
      if (clipuv) p_uvpts[knt][U] = u_min;
    }
    else if (fabs (p_uvpts[knt][U] - u_max) < lentol)
      p_uvpts[knt][U] = u_max;
    else if (p_uvpts[knt][U] > u_max)
    {
      if (clipuv) p_uvpts[knt][U] = u_max;
    }
  }

  if (cvtype == PWcvdata_gmbspcv)
  {
    p_uvcv->datatype = PWcvdata_gmbspcv;

    BScv_copy (&BSmsg, p_cv, p_uvcv->data.p_gmbspcv->bspcv);
    for (i=0; i<num_pts; i++)
    {
      memcpy (&p_uvcv->data.p_gmbspcv->bspcv->poles[i*3], &p_uvpts[i][0], 
              sizeof (PWpoint2d));
      p_uvcv->data.p_gmbspcv->bspcv->poles[i*3+2] = 0.0;
    }

    p_uvcv->data.p_gmbspcv->type = p_cv->order == 3 ? BSCIRC_ARC :  
                                                      BSGEN_BSP_CV;
    BScvtgeomcv (p_uvcv->data.p_gmbspcv, p_uvcv->data.p_gmbspcv, &BSmsg); 
    OnErrorState ((BSmsg != BSUNMATCHEDTYPES) && BSERROR (BSmsg), PWsts,
                  SetError (PW_K_Pathway, PW_K_Internal), wrapup);
    
  }
  else if (cvtype == PWcvdata_bspcv)
  {
    p_uvcv->datatype = PWcvdata_bspcv;

    BScv_copy (&BSmsg, p_cv, p_uvcv->data.p_bspcv);
    for (i=0; i<num_pts; i++)
    {
      memcpy (&p_uvcv->data.p_bspcv->poles[i*3], &p_uvpts[i][0], 
              sizeof (PWpoint2d));
      p_uvcv->data.p_bspcv->poles[i*3+2] = 0.0;
    }
  }
  else if (cvtype == PWcvdata_py)
  {
    p_uvcv->datatype = PWcvdata_py2d;

    p_uvcv->data.py2d.num_pts = num_pts;
    memcpy (p_uvcv->data.py2d.p_pts, p_uvpts, num_pts * sizeof (PWpoint2d));
  }
  else 
  {
    p_uvcv->datatype = PWcvdata_pt2d;
    memcpy (p_uvcv->data.pt2d, &p_uvpts[0][0], sizeof (PWpoint2d));
  }

wrapup :

  PW_Wrapup (PWsts, "pwLinearMapXyzCvToUvOfPlane");
  return PWsts;
}

/*
  ABSTRACT

  Maps a parametric-space curve to the model-space of the rectangular planar
  surface.

  DESCRIPTION

  Maps the given parametric-space curve to the model-space of the rectangular
  planar surface. A rectangular planar surface is one whose opposite sides are
  of equal length. Before calling this function one should call the "pwIsLine-
  arMapOkForPlane" function to determine whether the surface is rectangular or
  not. 

  ARGUMENTS

  p_uvcv     - I : Parametric-space curve on the surface.
  p_plane    - I : Rectangular surface geometry.
  xyztol     - I : Model-space tolerance.

  p_xyzcv    - O : Model-space curve.

  NOTES

  All the memory for the output must be allocated by the caller. It requires
  the same memory as the input curve requires.

  KEYWORDS

  Internal API, Rectangular Plane.
 
  HISTORY

  Sanjay       10/02/95      Creation

*/

PWresult pwLinearMapUvCvToXyzOfPlane
(
  struct PWcvdata *p_uvcv,
  struct IGRbsp_surface *p_plane,
  double xyztol,

  struct PWcvdata *p_xyzcv
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean forward=TRUE;
  enum PWcvdatatype cvtype=PWcvdata_null;
  struct IGRbsp_curve *p_cv=NULL;

  int num_pts=0, i=0, num_plnpts=0, knt=0;
  PWpoint *p_pts=NULL, plnpts[4];
  PWpoint2d *p_uvpts=NULL;
  double *p_wts=NULL, lentol=0, uvtol=0;

  int bot_left=0, bot_right=0, top_left=0, top_right=0;
  double *p1=NULL, *p2=NULL, *p3=NULL, *p4=NULL;
  double u_min=0, v_min=0, u_max=0, v_max=0, rotmat[3][3];
  double u_ratio=0, v_ratio=0, shift=0, u_diff=0, v_diff=0;

  u_min = p_plane->u_knots [p_plane->u_order-1];
  v_min = p_plane->v_knots [p_plane->v_order-1];
  u_max = p_plane->u_knots [p_plane->u_num_poles];
  v_max = p_plane->v_knots [p_plane->v_num_poles];

  BSEXTRACTPAR (&BSmsg, BSTOLLENVEC, lentol);
  uvtol = pwGetParTolSf (p_plane, xyztol);

  cvtype = p_uvcv->datatype;

  if (cvtype == PWcvdata_bspcv || cvtype == PWcvdata_gmbspcv)
  {
    p_cv = (cvtype == PWcvdata_bspcv) ? p_uvcv->data.p_bspcv : 
                                        p_uvcv->data.p_gmbspcv->bspcv ;
    num_pts = p_cv->num_poles;

    p_uvpts = (PWpoint2d *) alloca (num_pts * sizeof (PWpoint2d));
    OnErrorState (!p_uvpts, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                  wrapup);

    for (knt=0; knt<num_pts; knt++)
      memcpy (&p_uvpts[knt][0], &p_cv->poles[knt*3], sizeof (PWpoint2d));

    p_wts = p_cv->rational ? p_cv->weights : NULL;
    p_pts = (PWpoint *) ((cvtype == PWcvdata_bspcv) ? 
              p_xyzcv->data.p_bspcv->poles :
              p_xyzcv->data.p_gmbspcv->bspcv->poles);

    if (cvtype == PWcvdata_bspcv)
      BScv_copy (&BSmsg, p_cv, p_xyzcv->data.p_bspcv);
    else
      BScv_copy (&BSmsg, p_cv, p_xyzcv->data.p_gmbspcv->bspcv);
  }
  else if (cvtype == PWcvdata_py2d)
  {
    num_pts = p_uvcv->data.py2d.num_pts;
    p_uvpts = p_uvcv->data.py2d.p_pts;
    p_wts = NULL;
    p_pts = p_xyzcv->data.py.p_pts;
  }
  else if (cvtype == PWcvdata_pt2d)
  {
    num_pts = 1;
    p_uvpts = (PWpoint2d *) p_uvcv->data.pt2d;
    p_wts = NULL;
    p_pts = (PWpoint *) p_xyzcv->data.pt;
  }
  else 
  {
    OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                  wrapup);
  }

  bot_left  = 0; bot_right = (p_plane->u_num_poles - 1) * 3;
  top_left  = p_plane->u_num_poles * (p_plane->v_num_poles - 1) * 3; 
  top_right = bot_right + top_left;

  p1 = &p_plane->poles[bot_left];
  p2 = &p_plane->poles[bot_right];
  p3 = &p_plane->poles[top_right];
  p4 = &p_plane->poles[top_left];

  /*
   * get the rotational matrix.
   */
  PWsts = TransMatrix (p1, p2, p3, p4, xyztol, rotmat);
  OnErrorCode (PWsts, wrapup);

  /*
   * transform the plane points to a new co-ordinate system.
   */
  for (i=X; i<=Z; i++)
  {
    plnpts [0][i] = p1[i];
    plnpts [1][i] = p2[i];
    plnpts [2][i] = p4[i];
  }

  /*
   * Transform the plane points by keeping p1 as origin.
   */ 
  num_plnpts = 3;
  forward = TRUE;

  TransformPts (num_plnpts, plnpts, NULL, p1, rotmat, forward, plnpts);
  OnErrorState (plnpts[2][Y] <= lentol || plnpts[1][X] <= lentol, PWsts,
                SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  u_diff = u_max - u_min;
  v_diff = v_max - v_min;
  u_ratio = plnpts[1][X] / u_diff;
  v_ratio = plnpts[2][Y] / v_diff;
  shift = plnpts[2][X] / plnpts[2][Y];

  for (knt=0; knt<num_pts; knt++)
  {
    p_pts[knt][Y] = (p_uvpts[knt][V] - v_min) * v_ratio;
    p_pts[knt][X] = (p_uvpts[knt][U] - u_min) * u_ratio + p_pts[knt][Y] * shift;    p_pts[knt][Z] = 0;
  }

  forward = FALSE;
  TransformPts (num_pts, p_pts, p_wts, p1, rotmat, forward, p_pts);

  if (cvtype == PWcvdata_gmbspcv)
  {
    p_xyzcv->datatype = PWcvdata_gmbspcv;
    p_xyzcv->data.p_gmbspcv->type = p_cv->order == 3 ? BSCIRC_ARC : 
                                                       BSGEN_BSP_CV;
    BScvtgeomcv (p_xyzcv->data.p_gmbspcv, p_xyzcv->data.p_gmbspcv, &BSmsg); 
    OnErrorState ((BSmsg != BSUNMATCHEDTYPES) && BSERROR (BSmsg), PWsts,
                  SetError (PW_K_Pathway, PW_K_Internal), wrapup);
  }
  else if (cvtype == PWcvdata_bspcv)
  {
    p_xyzcv->datatype = PWcvdata_bspcv;
  }
  else if (cvtype == PWcvdata_py2d)
  {
    p_xyzcv->datatype = PWcvdata_py;
    p_xyzcv->data.py.num_pts = num_pts;
  }
  else 
  {
    p_xyzcv->datatype = PWcvdata_pt;
  }

wrapup :

  PW_Wrapup (PWsts, "pwLinearMapXyzCvToUvOfPlane");
  return PWsts;
}

/* ------------------------ Static Function Listing ------------------------- */

/*
  ABSTRACT

  Transforms the input points given the origin and the rotation matrix. If
  forward is TRUE then the input points will be moved to the origin first 
  and rotation matrix will be applied on it and if it is FALSE, then the
  rotation matrix will be applied first and then they will be moved to the
  origin.

  NOTES

  All the memory for the output must be allocated by the caller.  

*/

static void TransformPts
(
  int num_pts,
  PWpoint *p_pts, 
  double *p_wts,
  PWpoint origin,
  double rotmat[3][3],

  PWboolean forward,

  PWpoint *p_outpts
)
{
  int knt=0, dir=0, i=0, j=0;
  PWpoint tmppt;

  if (p_pts != p_outpts)
    memcpy (p_outpts, p_pts, num_pts * sizeof (PWpoint));

  for (knt=0; p_wts && knt<num_pts; knt++)
  {
    for (dir=X; dir<=Z; dir++)
      p_outpts[knt][dir] /= p_wts[knt];
  }

  if (forward)
  {
    for (knt=0; knt<num_pts; knt++)
    {
      for (dir=X; dir<=Z; dir++)
        p_outpts [knt][dir] -= origin[dir];
    }

    for (knt=0; knt<num_pts; knt++)
    {
      for (i=0; i<3; i++)
      {
        tmppt[i] = 0;
        for (j=0; j<3; j++)
          tmppt[i] += (p_outpts[knt][j] * rotmat[i][j]);
      }
      memcpy (p_outpts[knt], tmppt, sizeof (PWpoint));
    }
  }

  else

  {
    for (knt=0; knt<num_pts; knt++)
    {
      for (i=0; i<3; i++)
      {
        tmppt[i] = 0;
        for (j=0; j<3; j++)
          tmppt[i] += (p_outpts[knt][j] * rotmat[j][i]);
      }
      memcpy (p_outpts[knt], tmppt, sizeof (PWpoint));
    }

    for (knt=0; knt<num_pts; knt++)
    {
      for (dir=X; dir<=Z; dir++)
        p_outpts [knt][dir] += origin[dir];
    }
  }

  for (knt=0; p_wts && knt<num_pts; knt++)
  {
    for (dir=X; dir<=Z; dir++)
      p_outpts[knt][dir] *= p_wts[knt];
  }
}

static PWresult TransMatrix
(
  PWpoint p1,
  PWpoint p2,
  PWpoint p3,
  PWpoint p4,
  
  double lentol,

  double rotmat[3][3]
)
{
  PWresult PWsts=PW_K_Success;
  int i=0;
  double width=0, height=0, sqlentol=0;

  sqlentol = lentol * lentol;

  for (i=X; i<=Z; i++)
  {
    rotmat [0][i] = p2[i] - p1[i];
    rotmat [1][i] = p3[i] - p1[i];

    width  += (rotmat[0][i] * rotmat[0][i]);
    height += (rotmat[1][i] * rotmat[1][i]);
  }

  if (fabs (width) < sqlentol)
  {
    width = 0;

    for (i=X; i<=Z; i++)
    {
      rotmat [0][i] = p4[i] - p1[i];
      width  += (rotmat[0][i] * rotmat[0][i]);
    }

    OnErrorState (fabs (width) < sqlentol, PWsts, SetError (PW_K_Pathway, 
                  PW_K_InvalidArg), wrapup);  
  }

  if (fabs (height) < sqlentol)
  {
    height = 0;

    for (i=X; i<=Z; i++)
    {
      rotmat [1][i] = p4[i] - p1[i];
      height += (rotmat[1][i] * rotmat[1][i]);
    }

    OnErrorState (fabs (height) < sqlentol, PWsts, SetError (PW_K_Pathway,
                  PW_K_InvalidArg), wrapup);
  }

  pwCross (rotmat[0], rotmat[1], rotmat[2]);
  pwNormVec (rotmat[2], rotmat[2]);
  pwCross (rotmat[2], rotmat[0], rotmat[1]);
  pwNormVec (rotmat[0], rotmat[0]);
  pwNormVec (rotmat[1], rotmat[1]);

wrapup : 

  PW_Wrapup (PWsts, "TransMatrix");
  return PWsts;
}
