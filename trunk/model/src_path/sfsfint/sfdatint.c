/*
  ABSTRACT

  This API intersects two surfaces (e.g. quadric/quadric, quadric/plane,
  quadric/general, general/plane, or general/general). Note that this function
  does not handle plane-plane intersection.

  The flag to discard intersection curves that are less than chord-height in
  length can be set. The output returned is then guaranteed to contain curves
  of length greater than cht.

  The flag to return the best output, disregarding uv-curves can be set. This
  is typically used when the caller is not interested in trimming back the
  curves to the surface boundaries.

  NOTES

  This call is sensitive to the global tolerances -- cht and bastol. These
  should be set appropriately before making this call.

  The output of xyzcvs1 and xyzcvs2 can be identical and point to the same
  memory. The caller needs to free the memory using the API -- 
  pwSfdataIntersectFree. Also, in the case when one of the input surface
  data does not have a bounded B-spline definition (eg: plane), then the
  corresponding output will be NULL.
*/

#include <alloca.h>

#include "igrtypedef.h"
#include "igr.h"

#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "prototypes/bssfsfint.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/sfdatint.h"
#include "PWapi/gmdatamem.h"

#define ALL_POLY	 0
#define XYZ_CVS          1
#define XYZ_AND_UV_CVS   3
#define XYZ_AND_UV1_CVS  4
#define XYZ_AND_UV2_CVS  5

static void free_pts(), free_cvs();

PWresult pwSfdataIntersect
(
  struct PWsfdata *sf1,
  struct PWsfdata *sf2,
  PWboolean discard_point_intersections,
  PWboolean discard_uvcvs,
  int *num_inters,
  struct PWcvdata **xyzcvs1,
  struct PWcvdata **uvcvs1,
  struct PWcvdata **xyzcvs2,
  struct PWcvdata **uvcvs2
)
{
  short cvscode;
  int i, inx, num_grps=0, tmp_num_inters=0, num_discard_inters=0;
  int *num_ints_grp=NULL, *num_pts_int=NULL;
  int size, size_gmbspcv;
  long bsrc;
  double chttol;
  PWboolean *is_degen_inters=NULL;
  PWpoint **i_xyzpts=NULL;
  PWpoint2d **i_uvpts1=NULL, **i_uvpts2=NULL;
  PWresult result=PW_K_Success, memerr=SetError (PW_K_Pathway, PW_K_Memory);
  struct PWcvdata *p_cv;
  struct BSgeom_bsp_curve *i_xyzcvs=NULL, *i_uvcvs1=NULL, *i_uvcvs2=NULL;
  struct BSgeom_bsp_curve *p_gmbspcv;
  struct BSgeom_bsp_surf gmsf1, gmsf2;

  /*
   * Verify the input
   */

  OnErrorState (sf1->datatype == PWsfdata_plane && 
   sf2->datatype == PWsfdata_plane, result, 
   SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  /*
   * Initialize output
   */

  *num_inters = 0;
  *xyzcvs1 = NULL;
  *uvcvs1 = NULL;
  *xyzcvs2 = NULL;
  *uvcvs2 = NULL;

  /*
   * Initialize local, working variables
   */

  size_gmbspcv = sizeof (struct BSgeom_bsp_curve);

  /*
   * Math call:
   * Call the underlying math function
   */

  result = pwSfdataAsGeomBspline (sf1, &gmsf1);
  OnErrorCode (result, wrapup);

  result = pwSfdataAsGeomBspline (sf2, &gmsf2);
  OnErrorCode (result, wrapup);

  BSsfsfint (&gmsf1, &gmsf2, &num_grps, &num_ints_grp, &num_pts_int,
   &i_xyzpts, &i_uvpts1, &i_uvpts2,
   &cvscode, &i_xyzcvs, &i_uvcvs1, &i_uvcvs2, &bsrc);

  if (bsrc == BSCOINCIDENT)
  {
    result = SetInfo (PW_K_Pathway, PW_K_Coincident);
    goto wrapup;
  }
  else if (bsrc != BSSUCC)
  {
    pwDebugLine (PW_K_DebugTrace, "BSsfsfint: BS error code - %d\n", bsrc);
    result = SetError (PW_K_BspMath, PW_K_Internal);
    goto wrapup;
  }  
  else if (!num_grps)
  {
    result = SetInfo (PW_K_Pathway, PW_K_NoIntersect);
    goto wrapup;
  }

  /*
   * Degeneracy:
   * Record intersections that are degenerate within cht. If this option
   * is not set, then simply record every intersection as non-degenerate.
   */

  for (i=0; i<num_grps; i++)
    tmp_num_inters += num_ints_grp[i];

  size = tmp_num_inters * sizeof (PWboolean);
  is_degen_inters = (PWboolean *) alloca (size);
  memset (is_degen_inters, 0, size);
  if (discard_point_intersections)
  {
    BSEXTRACTPAR (&bsrc, BSTOLCHRDHT, chttol);

    for (i=0; i<tmp_num_inters; i++)
    {
      if (num_pts_int[i] == 2 && pwIsDegenPy (2, i_xyzpts[i], chttol))
      {
        is_degen_inters[i] = TRUE;
        num_discard_inters++;
      }
    }
  }

  if (num_discard_inters == tmp_num_inters)
  {
    result = SetInfo (PW_K_Pathway, PW_K_NoIntersect);
    goto wrapup;
  }
  
  /*
   * Format output:
   * Output every intersection curve (non-degenerate only, in the case when
   * this option is set). Logic is required to make sense out of the 
   * combination of curves returned by the math call.
   */

  *xyzcvs1 = (struct PWcvdata *) malloc (tmp_num_inters * sizeof 
              (struct PWcvdata));
  if (cvscode == XYZ_AND_UV1_CVS || cvscode == XYZ_AND_UV2_CVS)
    *xyzcvs2 = (struct PWcvdata *) malloc (tmp_num_inters * sizeof 
                (struct PWcvdata));
  else
    *xyzcvs2 = *xyzcvs1;

  if (sf1->datatype != PWsfdata_plane)
    *uvcvs1 = (struct PWcvdata *) malloc (tmp_num_inters * sizeof 
               (struct PWcvdata));
  else
    *uvcvs1 = NULL;
  if (sf2->datatype != PWsfdata_plane)
    *uvcvs2 = (struct PWcvdata *) malloc (tmp_num_inters * sizeof 
               (struct PWcvdata));
  else
    *uvcvs2 = NULL;

  OnErrorState (!*xyzcvs1 || !*xyzcvs2 || (!*uvcvs1 && !*uvcvs2), result,
   memerr, wrapup);

  for (i=0; i<tmp_num_inters; i++)
  {
    /*
     * If we do not output degenerate intersection curves, check the Boolean
     * flag array and skip this intersection, if found so. Else, increment the 
     * number of intersections found.
     */

    if (discard_point_intersections && is_degen_inters[i])
      continue;
    else
      (*num_inters)++;

    /*
     * Output the 'i_xyzcvs' into the correct output argument, whenever such
     * curves are available and legal to output. Otherwise, output the 
     * 'i_xyzpts' in place of the curves.
     */

    inx = (*num_inters)-1;

    p_cv = cvscode == XYZ_AND_UV2_CVS ? &(*xyzcvs2)[inx] : &(*xyzcvs1)[inx];
    if (cvscode == XYZ_AND_UV1_CVS || 
        cvscode == XYZ_AND_UV2_CVS || 
        cvscode == XYZ_AND_UV_CVS || 
        (discard_uvcvs && cvscode == XYZ_CVS))
    {
      p_cv->datatype = PWcvdata_gmbspcv;
      p_gmbspcv = (struct BSgeom_bsp_curve *) malloc (size_gmbspcv);
      OnErrorState (!p_gmbspcv, result, memerr, wrapup);

      p_cv->data.p_gmbspcv = p_gmbspcv;
      *p_gmbspcv = i_xyzcvs[i];
      i_xyzcvs[i].array1 = NULL;
      i_xyzcvs[i].bspcv = NULL;
    }
    else
    {
      p_cv->datatype = PWcvdata_py;
      p_cv->data.py.num_pts = num_pts_int[i];
      p_cv->data.py.p_pts = i_xyzpts[i];
      i_xyzpts[i] = NULL;
    }

    /*
     * If the xyz output arguments for the two surfaces has to contain 
     * different data (one a smooth curve and the other polyline), output the
     * polyline here into the correct output arg.
     */

    if (cvscode == XYZ_AND_UV1_CVS || cvscode == XYZ_AND_UV2_CVS) 
    {
      p_cv = cvscode == XYZ_AND_UV2_CVS ? &(*xyzcvs1)[inx] : &(*xyzcvs2)[inx];
      p_cv->datatype = PWcvdata_py;
      p_cv->data.py.num_pts = num_pts_int[i];
      p_cv->data.py.p_pts = i_xyzpts[i];
      i_xyzpts[i] = NULL;
    }

    /*
     * If uv-output is to be discarded then continue to the next intersection.
     */

    if (discard_uvcvs)
      continue;

    /*
     * Process the uv output for the first surface here.
     */

    p_cv = &(*uvcvs1)[inx];
    if (cvscode == XYZ_AND_UV1_CVS || cvscode == XYZ_AND_UV_CVS)
    {
      p_cv->datatype = PWcvdata_gmbspcv;
      p_gmbspcv = (struct BSgeom_bsp_curve *) malloc (size_gmbspcv);
      OnErrorState (!p_gmbspcv, result, memerr, wrapup);

      p_cv->data.p_gmbspcv = p_gmbspcv;
      *p_gmbspcv = i_uvcvs1[i];
      i_uvcvs1[i].array1 = NULL;
      i_uvcvs1[i].bspcv = NULL;
    }
    else
    {
      p_cv->datatype = PWcvdata_py2d;
      p_cv->data.py2d.num_pts = num_pts_int[i];
      p_cv->data.py2d.p_pts = (PWpoint2d *) i_uvpts1[i];
      i_uvpts1[i] = NULL;
    }

    /*
     * Process the uv output for the second surface here.
     */

    p_cv = &(*uvcvs2)[inx];
    if (cvscode == XYZ_AND_UV2_CVS || cvscode == XYZ_AND_UV_CVS)
    {
      p_cv->datatype = PWcvdata_gmbspcv;
      p_gmbspcv = (struct BSgeom_bsp_curve *) malloc (size_gmbspcv);
      OnErrorState (!p_gmbspcv, result, memerr, wrapup);

      p_cv->data.p_gmbspcv = p_gmbspcv;
      *p_gmbspcv = i_uvcvs2[i];
      i_uvcvs2[i].array1 = NULL;
      i_uvcvs2[i].bspcv = NULL;
    }
    else
    {
      p_cv->datatype = PWcvdata_py2d;
      p_cv->data.py2d.num_pts = num_pts_int[i];
      p_cv->data.py2d.p_pts = (PWpoint2d *) i_uvpts2[i];
      i_uvpts2[i] = NULL;
    }
  }

wrapup:
  if (num_ints_grp)
    free (num_ints_grp);
  if (num_pts_int)
    free (num_pts_int);
  if (i_xyzpts)
    free_pts (i_xyzpts, tmp_num_inters);
  if (i_uvpts1)
    free_pts (i_uvpts1, tmp_num_inters);
  if (i_uvpts2)
    free_pts (i_uvpts2, tmp_num_inters);
  if (i_xyzcvs)
    free_cvs (i_xyzcvs, tmp_num_inters);
  if (i_uvcvs1)
    free_cvs (i_uvcvs1, tmp_num_inters);
  if (i_uvcvs2)
    free_cvs (i_uvcvs2, tmp_num_inters);

  PW_Wrapup (result, "pwSfdataIntersect");
  return (result);
}

static void free_pts (pts, num)
IGRdouble ***pts;
int num;
{
  int i; 

  if (pts)
  {
    for (i=0; i<num; i++)
      if (pts[i])
        free (pts[i]);
    free (pts);
  }
  return;
}

static void free_cvs (cvs, num)
struct BSgeom_bsp_curve *cvs;
int num;
{
  int i;
  long msg_loc;

  if (cvs)
  {
    for (i=0; i<num; i++)
    {
      if (cvs[i].bspcv)
        BSfreecv (&msg_loc, cvs[i].bspcv);
      if (cvs[i].array1)
        free (cvs[i].array1);
    }
    free (cvs);
  }
  return;
}


/*
  ABSTRACT

  This function is to be used by the caller to free the memory of the output
  generated by pwSfdataIntersect.
*/

void pwSfdataIntersectFree
(
  int num_inters,
  struct PWcvdata *xyzcvs1,
  struct PWcvdata *uvcvs1,
  struct PWcvdata *xyzcvs2,
  struct PWcvdata *uvcvs2
)
{
  int i;

  for (i=0; i<num_inters; i++)
  {
    if (xyzcvs1)
      pwFreeCvdataGeom (&xyzcvs1[i]);
    if (uvcvs1)
      pwFreeCvdataGeom (&uvcvs1[i]);
    if (xyzcvs1 != xyzcvs2)
      pwFreeCvdataGeom (&xyzcvs2[i]);
    if (uvcvs2)
      pwFreeCvdataGeom (&uvcvs2[i]);
  }

  if (xyzcvs1)
    free (xyzcvs1);
  if (uvcvs1)
    free (uvcvs1);
  if (xyzcvs2 && xyzcvs1 != xyzcvs2)
    free (xyzcvs2);
  if (uvcvs2)
    free (uvcvs2);

  return;
}
