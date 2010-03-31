/*
  OVERVIEW

  This file contains all the external APIs to transform the data from model
  space to the parametric space of the surface and vice-versa. These APIs 
  are viewed as extremely useful in "Geometric Translators", "Internal Cv
  Boolean" etc.

  NOTES

  All the memory for the output will be allocted by these APIs. It is the 
  callers responsibility to free the allocated memory.

  HISTORY

  Sanjay     09/10/95      Creation

*/

/* Includes */

#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <memory.h>         /* System */
#include <bsvalues.h> 
#include <malloc.h> 

#include "igrtypedef.h"
#include "igr.h"        
#include "bs.h"
#include "bsparameters.h"   /* BS math */
#include "bsgeom_cvsf.h"
#include "bsvalues.h"

#include "emsedgedef.h"
#include "EMSprop.h"        /* MODEL */

#include "PWminimum.h"
#include "PWgmdata.h"       /* Pathway */
#include "PWerror.h"

/* Prototypes */

#include "bschangepar.h"
#include "bschtptstcv.h"
#include "bsprptonsf.h"     
#include "bsprptonsf.h"
#include "bsprptsonsf.h"
#include "bslocalcord.h"
#include "bsptsoldtnw.h"
#include "bsptoldtnw.h"
#include "bscvtgeomcv.h"      /* BS math */
#include "bscv_copy.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bschtptstcv.h"
#include "bsprptsonsf.h"
#include "bsprptonsf.h"
#include "bssfeval.h"
#include "bsconstprcv.h"
#include "bspartofcv.h"
#include "bsnorkts.h"
#include "bssfptseval.h"
#include "bsalloccv.h"
#include "bscv_copy.h"

#include "PWapi/mapcvonsf.h"
#include "PWapi/cvgeom.h"
#include "PWapi/samepts.h"    
#include "PWapi/mdstptgm.h"
#include "PWapi/partol.h"
#include "PWapi/ptpargm.h"
#include "PWapi/edtype.h"
#include "PWapi/isopts.h"   /* Pathway */
#include "PWapi/mapisocv.h"
#include "PWapi/mapseamcv.h"
#include "PWapi/mapcvonpln.h"
#include "PWapi/refbdrypts.h"
#include "PWapi/gmdatamem.h"
#include "PWapi/strkuv.h"
#include "PWapi/revgm.h"
#include "PWapi/uvcvprops.h"

/* Static Functions */

static PWresult stroke_and_get_uvdata
(
  struct PWcvdata *p_xyzcv,
  struct IGRbsp_surface *p_sf,

  double xyztol,

  struct PWpoly2d *p_uvcv
);


/*
  ABSTRACT

  Maps a model space curve to the parametric space of the surface.

  DESCRIPTION

  Given a model space curve data, it returns the equivalent parametric space
  curve data, it's properties (defined in EMSprop.h), and the xyz curve types
  (defined in EMSedgedef.h). A single model space is curve can result in one
  more curves in the parametric space because of loss of continuity. This 
  happens typically if the surface is closed and the input curve is crossing
  the seams of the surface. This function rightly splits the input curve and
  maps the curve.
  
  ARGUMENTS

  p_xyzcv         - I : Model space curve data on the surface.
  p_sfdata        - I : Surface Data.
  xyztol          - I : Model space tolerance, required to stroke the curve.

  num_uvcv        - O : Number of Parametric space curves.
  p_uvcv          - O : Parametric Curves data.
  p_uvcv_props    - O : Parametric Curve properties.
  p_xyzcv_type    - O : Model space curve types.

  NOTES

  All the memory for the output will be allocated by this routine. It is the
  caller's responsibility to free the allocated memory. The way to free the
  output is : 

  int num_uvcv=0, *p_uvcv_props=NULL, *p_xyzcv_type=NULL; 
  struct PWcvdata *p_uvcv=NULL;

  for (knt=0; knt<num_uvcv; knt++)
    pwFreeCvdataGeom (&p_uvcv[knt]); 
  if (p_uvcv) free (p_uvcv);
  if (p_uvcv_props) free (p_uvcv_props);
  if (p_xyzcv_type) free (p_xyzcv_type);

  CAVEATS

  One should pass in the right curve data i.e. if it is a point it should be 
  PWcvdata_pt, line string - PWcvdata_py etc. as this routine assumes that 
  right curve data is being passed in.

  KEYWORDS

  External API

  HISTORY

  Sanjay    09/10/95     Creation

*/
 
PWresult pwMapXyzCvToUvOfSf
(
  struct PWcvdata *p_xyzcv,
  struct PWsfdata *p_sfdata,
  double xyztol, 

  int *num_uvcv,
  struct PWcvdata **p_uvcv,
  int **p_uvcv_props,
  int **p_xyzcv_type
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;

  double chttol=0, uvtol=0, lentol;
  int i=0, bscvtype=0;
  PWboolean reset_cht=FALSE, BSsts=TRUE;
  struct IGRbsp_surface *p_sf=NULL; 
  struct IGRbsp_curve *p_cv=NULL;
  enum PWsfdatatype sftype;
  enum PWcvdatatype cvtype;

  *num_uvcv = 0;
  *p_uvcv = NULL;
  *p_uvcv_props = NULL;
  *p_xyzcv_type = NULL;

  sftype = p_sfdata->datatype;
  cvtype = p_xyzcv->datatype;

  OnErrorState (sftype == PWsfdata_plane, PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);
  OnErrorState (cvtype != PWcvdata_pt && cvtype != PWcvdata_py && 
                cvtype != PWcvdata_bspcv && cvtype != PWcvdata_gmbspcv, PWsts,
                SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  p_sf = (sftype == PWsfdata_bspsf) ? p_sfdata->data.p_bspsf : 
                                      p_sfdata->data.p_gmbspsf->bspsf;

  BSEXTRACTPAR (&BSmsg, BSTOLCHRDHT, chttol);
  BSchangepar (&BSmsg, BSTOLCHRDHT, xyztol);   
  BSEXTRACTPAR (&BSmsg, BSTOLLENVEC, lentol);

  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath, PW_K_Internal),
                wrapup);
  reset_cht = TRUE;
  if (cvtype == PWcvdata_pt)
  {
    /*
     * Xyz point curve.
     */

    PWboolean onsurf=FALSE;
    double upar, vpar;

    BSsts = BSprptonsf (&BSmsg, p_sf, p_xyzcv->data.pt, &upar, &vpar, &onsurf);
    OnErrorState (!BSsts || BSERROR (BSmsg) || !onsurf, PWsts, 
                  SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

    *num_uvcv = 1;

    *p_uvcv = (struct PWcvdata *) malloc (sizeof (struct PWcvdata));
    OnErrorState (!*p_uvcv, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                  wrapup);

    (*p_uvcv)->datatype = PWcvdata_pt2d; 
    (*p_uvcv)->data.pt2d[U] = upar;
    (*p_uvcv)->data.pt2d[V] = vpar;

  }
  else if (p_sf->planar && pwIsLinearMapOkOnPlane (p_sf, lentol))
  {
    /*
     * Planar Surface.
     */

     		
    *num_uvcv = 1;
    *p_uvcv = (struct PWcvdata *) malloc (sizeof (struct PWcvdata));
    OnErrorState (!*p_uvcv, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                  wrapup);

    (*p_uvcv)->datatype = PWcvdata_null;
 
    if (cvtype == PWcvdata_gmbspcv)
    { 
      p_cv = p_xyzcv->data.p_gmbspcv->bspcv;

      (*p_uvcv)->data.p_gmbspcv = (struct BSgeom_bsp_curve *) 
                                  malloc (sizeof (struct BSgeom_bsp_curve)); 
      OnErrorState (!(*p_uvcv)->data.p_gmbspcv, PWsts, SetError
                    (PW_K_Pathway, PW_K_DynamicMemory), wrapup);

      BSalloccv (p_cv->order, p_cv->num_poles, p_cv->rational, 
                 p_cv->num_boundaries, &(*p_uvcv)->data.p_gmbspcv->bspcv, 
                 &BSmsg);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_DynamicMemory), wrapup);
    } 
    else if (cvtype == PWcvdata_bspcv)
    {
      p_cv = p_xyzcv->data.p_bspcv;
      BSalloccv (p_cv->order, p_cv->num_poles, p_cv->rational, 
                 p_cv->num_boundaries,  &(*p_uvcv)->data.p_bspcv, &BSmsg);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_DynamicMemory), wrapup);
    }
    else
    {
      (*p_uvcv)->data.py2d.p_pts = (PWpoint2d *) 
                 malloc (p_xyzcv->data.py.num_pts * sizeof (PWpoint2d)); 
    }

    PWsts = pwLinearMapXyzCvToUvOfPlane (p_xyzcv, p_sf, xyztol, *p_uvcv);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
  }
  else 
  {
    /*
     * Non-Planar surface.
     */
    int knt=0, spt=0, bufsize=10, num_allocated=0;

    int num_seamcvs=0, num_seam_splitcvs=0;
    PWpoint2d *p_seampts=NULL;
    struct PWcvdata *p_seam_splitcvs=NULL;

    int num_isocvs=0, num_non_isocvs=0;
    PWpoint2d isocvpts[6];
    struct PWcvdata non_isocvs[3];
 
    uvtol = pwGetParTolSf (p_sf, xyztol);

    /*
     * Split with seams.
     */
    if (p_sf->u_phy_closed || p_sf->v_phy_closed)
    {
      PWsts = pwSplitAndMapXyzCvSeamInUvOfSf (p_sf, p_xyzcv, xyztol, 
                &num_seamcvs, &p_seampts, &num_seam_splitcvs, 
                &p_seam_splitcvs);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    }

    if (!num_seamcvs && !num_seam_splitcvs)
    {
      num_seam_splitcvs = 1;
      p_seam_splitcvs = p_xyzcv;
    }

    *num_uvcv = 0;
    num_allocated = bufsize + num_seamcvs;
    (*p_uvcv) = (struct PWcvdata *) malloc (num_allocated * 
                                            sizeof (struct PWcvdata));
    OnErrorState (!(*p_uvcv), PWsts, SetError (PW_K_Pathway, 
                  PW_K_DynamicMemory), wrapup);

    for (knt=0; knt<num_seamcvs; knt++)
    {
      (*p_uvcv)[*num_uvcv].datatype = PWcvdata_py2d; 
      (*p_uvcv)[*num_uvcv].data.py2d.p_pts = (PWpoint2d *) malloc (2 * 
                                                           sizeof (PWpoint2d));
      (*p_uvcv)[*num_uvcv].data.py2d.num_pts = 2;
      memcpy ((*p_uvcv)[*num_uvcv].data.py2d.p_pts, &p_seampts[knt*2], 
              2 * sizeof (PWpoint2d)); 
      (*num_uvcv) ++;
    }

    if (p_seampts) free (p_seampts);
    p_seampts = NULL;

    /*
     * Map the Iso Curves.
     */

    for (spt=0; spt<num_seam_splitcvs; spt++)
    {
      num_isocvs = 0;
      num_non_isocvs = 0;

      PWsts = pwSplitAndMapXyzCvIsoInUvOfSf (p_sf, &p_seam_splitcvs[spt], 
                xyztol, &num_isocvs, isocvpts, &num_non_isocvs, non_isocvs);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

      if (!num_isocvs && !num_non_isocvs)
      {
        num_non_isocvs = 1;
        non_isocvs[0] = p_seam_splitcvs[spt];
      }

      if (((*num_uvcv) + num_isocvs + num_non_isocvs) >= num_allocated)
      {
        if (bufsize < ((*num_uvcv) + num_isocvs + num_non_isocvs))
          bufsize = ((*num_uvcv) + num_isocvs + num_non_isocvs);

        num_allocated += bufsize;

        (*p_uvcv) = (struct PWcvdata *) realloc ((*p_uvcv), num_allocated *
                                                sizeof (struct PWcvdata));
        OnErrorState (!(*p_uvcv), PWsts, SetError (PW_K_Pathway,
                      PW_K_DynamicMemory), wrapup);
      }

      for (knt=0; knt<num_isocvs; knt++)
      {
        (*p_uvcv)[*num_uvcv].datatype = PWcvdata_py2d;
        (*p_uvcv)[*num_uvcv].data.py2d.p_pts = (PWpoint2d *) malloc (2 *
                                                     sizeof (PWpoint2d));
        (*p_uvcv)[*num_uvcv].data.py2d.num_pts = 2;
        memcpy ((*p_uvcv)[*num_uvcv].data.py2d.p_pts, &isocvpts[knt*2],
                2 * sizeof (PWpoint2d));
        (*num_uvcv) ++;
      }

      /*
       * Map the non-iso curves.
       */

      for (knt=0; knt<num_non_isocvs; knt++)
      {
        (*p_uvcv)[*num_uvcv].datatype = PWcvdata_py2d;

        /*
         * Map the non-iso curve.
         */

        PWsts = stroke_and_get_uvdata (&non_isocvs[knt], p_sf, xyztol, 
                                       &(*p_uvcv)[*num_uvcv].data.py2d);
        OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

        /*
         * If needed, refine the points ending on the degenerate boundaries
         * (degenerate in XYZ and non-degenerate in UV) of the surface.
         */

        PWsts = pwRefineUvPtsOnDegenBdrysOfSf (p_sf, 
                  (*p_uvcv)[*num_uvcv].data.py2d.num_pts, 
                  (*p_uvcv)[*num_uvcv].data.py2d.p_pts, xyztol);
        OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

        /*
         * If needed, insert the points at the seams of the surface.
         */

        if ((p_sf->u_phy_closed || p_sf->v_phy_closed) &&
            (*p_uvcv)[*num_uvcv].data.py2d.num_pts > 2)
        {
          (*p_uvcv)[*num_uvcv].data.py2d.p_pts = 
             (PWpoint2d *)realloc ((*p_uvcv)[*num_uvcv].data.py2d.p_pts,
             ((*p_uvcv)[*num_uvcv].data.py2d.num_pts+8)* sizeof(PWpoint2d));

          PWsts = pwInsertUvPtsAtSeamsOfSf (p_sf, 
                    &(*p_uvcv)[*num_uvcv].data.py2d.num_pts, 
                    (*p_uvcv)[*num_uvcv].data.py2d.p_pts);
          OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
        }

        (*num_uvcv) ++;
      }
    }

    (*p_uvcv) = (struct PWcvdata *) realloc ((*p_uvcv), (*num_uvcv) *
                                             sizeof (struct PWcvdata));
    OnErrorState (!(*p_uvcv), PWsts, SetError (PW_K_Pathway, 
                  PW_K_DynamicMemory), wrapup);
  }

  /*
   * For each mapped curve, get the curve properties.
   */

  *p_uvcv_props = (int *) malloc (*num_uvcv * sizeof (int));
  OnErrorState (!(*p_uvcv_props), PWsts, SetError (PW_K_Pathway, 
                PW_K_DynamicMemory), wrapup);

  for (i=0; i<*num_uvcv; i++)
  {
    PWsts = pwGetUvCvdataProps (&(*p_uvcv)[i], p_sf, xyztol, uvtol, 
                                &(*p_uvcv_props)[i]);
    OnErrorCode (PWsts, wrapup);
  }

  /*
   * For each mapped curve, get it's xyz curve type.
   */

  *p_xyzcv_type = (int *) malloc (*num_uvcv * sizeof (int));
  OnErrorState (!(*p_xyzcv_type), PWsts, SetError (PW_K_Pathway, 
                PW_K_DynamicMemory), wrapup);

  if (cvtype == PWcvdata_pt)
    bscvtype = BSPOINT;
  else if (cvtype == PWcvdata_py)
    bscvtype = BS3DLINESTR;
  else if (cvtype == PWcvdata_gmbspcv)
    bscvtype = p_xyzcv->data.p_gmbspcv->type;
  else if (cvtype == PWcvdata_bspcv)
  {
    struct BSgeom_bsp_curve gmcv;

    gmcv.type = p_xyzcv->data.p_bspcv->order == 3 ? BSCIRC_ARC : BSGEN_BSP_CV;
    gmcv.bspcv = p_xyzcv->data.p_bspcv; 

    BScvtgeomcv (&gmcv, &gmcv, &BSmsg);
    bscvtype = gmcv.type;
  }

  if (*num_uvcv > 1)
  {
    if (bscvtype == BSCIRCLE)
      bscvtype = BSCIRC_ARC;
    else if (bscvtype == BSELLIPSE)
      bscvtype = BSELLIP_ARC;
  }

  for (i=0; i<*num_uvcv; i++)
  {
    if (bscvtype == BS3DLINESTR || bscvtype == BSLINE || 
        bscvtype == BS2DLINESTR)
    {
      if ((*p_uvcv)[i].datatype == PWcvdata_py2d)
      { 
        if ((*p_uvcv)[i].data.py2d.num_pts == 2)
          (*p_xyzcv_type)[i] = EMlinesegment;
        else
          (*p_xyzcv_type)[i] = EMlinestring;
      }
      else if ((*p_uvcv)[i].datatype == PWcvdata_bspcv)
      {
        if ((*p_uvcv)[i].data.p_bspcv->num_poles == 2)
          (*p_xyzcv_type)[i] = EMlinesegment;
        else
          (*p_xyzcv_type)[i] = EMlinestring;
      } 
      else if ((*p_uvcv)[i].datatype == PWcvdata_gmbspcv)
      {
        if ((*p_uvcv)[i].data.p_gmbspcv->bspcv->num_poles == 2)
          (*p_xyzcv_type)[i] = EMlinesegment;
        else
          (*p_xyzcv_type)[i] = EMlinestring;
      } 
      else
      {
        (*p_xyzcv_type)[i] = EMpoint;
      }
    }
    else
    {
      (*p_xyzcv_type)[i] = pwGetEdTypeFromBsType (bscvtype);
    }
  }
 
wrapup :

  if (IsError (PWsts) && *num_uvcv)
  {
    for (i=0; i<*num_uvcv; i++)
    {
      if (p_uvcv[i]->datatype == PWcvdata_py2d)
        free (p_uvcv[i]->data.py2d.p_pts);
      else if (p_uvcv[i]->datatype == PWcvdata_bspcv)
        BSfreecv (&BSmsg, p_uvcv[i]->data.p_bspcv);
    }

    free (*p_uvcv);
 
    *num_uvcv = 0;
  } 

  if (reset_cht)
    BSchangepar (&BSmsg, BSTOLCHRDHT, chttol);   

  PW_Wrapup (PWsts, "pwMapXyzCvToUvOfSf");
  return PWsts;
}

/*
  ABSTRACT

  Maps a Parametric space Curve to the Model space of the surface.

  DESCRIPTION

  Given the parametric space curve data, it returns the equivalent model space
  curve data. If it is an iso curve it returns the iso curve geometry rather 
  than the stroked geometry.
  
  ARGUMENTS

  p_uvcv      - I : Parametric space curve data.
  p_sfdata    - I : Surface data.
  xyztol      - I : Model space tolerance.
 
  p_xyzcv     - O : Model space curve data.

  NOTES

  All the memory for the output will be allocated by this routine. It is the
  caller's responsibility to free the allocated memory. One can free the 
  allocated memory by calling the function : pwFreeCvdataGeom (p_xyzcv).

  CAVEATS

  None.

  KEYWORDS

  External API

  HISTORY

  Sanjay    10/10/95     Creation

*/

PWresult pwMapUvCvToXyzOfSf
(
  struct PWcvdata *p_uvcv,
  struct PWsfdata *p_sfdata,
  double xyztol,
 
  struct PWcvdata *p_xyzcv
)
{
  PWresult PWsts=PW_K_Success;
  struct IGRbsp_surface *p_sf=NULL;
  BSrc BSmsg=BSSUCC;
  PWboolean is_linear_map=FALSE, BSsts=TRUE;
  enum PWcvdatatype cvtype;
  enum PWsfdatatype sftype;
  double uvtol=0, u_min=0, v_min=0, v_max=0, u_max=0;

  /*
   * Initialize the output.
   */
  memset (p_xyzcv, 0, sizeof (struct PWcvdata));
  p_xyzcv->datatype = PWcvdata_null;

  sftype = p_sfdata->datatype;
  cvtype = p_uvcv->datatype;

  p_sf = sftype == PWsfdata_bspsf ? p_sfdata->data.p_bspsf : 
                                    p_sfdata->data.p_gmbspsf->bspsf;

  u_min = p_sf->u_knots [p_sf->u_order-1];
  v_min = p_sf->v_knots [p_sf->v_order-1];
  u_max = p_sf->u_knots [p_sf->u_num_poles];
  v_max = p_sf->v_knots [p_sf->v_num_poles];

  is_linear_map = p_sf->planar && (pwIsLinearMapOkOnPlane (p_sf, xyztol));

  if (is_linear_map)
  {
    /*
     * Planar surface and is rectangular. A linear transformation will be 
     * suffice for exact mapping.
     */

    struct IGRbsp_curve *p_cv=NULL; 

    /* 
     * Allocate the memory for the output curve, which is same as the input 
     * curve.
     */
 
    switch (cvtype)
    {
      case PWcvdata_py2d :
        p_xyzcv->data.py.p_pts = (PWpoint *) malloc (p_uvcv->data.py2d.num_pts *
                                                     sizeof (PWpoint));
        break;
 
      case PWcvdata_bspcv : 
        p_cv = p_uvcv->data.p_bspcv;
        BSalloccv (p_cv->order, p_cv->num_poles, p_cv->rational, 
                   p_cv->num_boundaries, &p_xyzcv->data.p_bspcv, &BSmsg);
        OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                      PW_K_Memory), wrapup);
        break;
 
      case PWcvdata_gmbspcv : 
        p_xyzcv->data.p_gmbspcv = (struct BSgeom_bsp_curve *) malloc (
                                      sizeof (struct BSgeom_bsp_curve));
        OnErrorState (!p_xyzcv->data.p_gmbspcv, PWsts, SetError (PW_K_Pathway,
                      PW_K_Memory), wrapup);

        p_cv = p_uvcv->data.p_gmbspcv->bspcv;

        BSalloccv (p_cv->order, p_cv->num_poles, p_cv->rational, 
          p_cv->num_boundaries, &p_xyzcv->data.p_gmbspcv->bspcv, &BSmsg);
        OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                      PW_K_Memory), wrapup);
        break;
    }

    /*
     * Map the parametric curve to the model space curve by linear 
     * transformation.
     */

    PWsts = pwLinearMapUvCvToXyzOfPlane (p_uvcv, p_sf, xyztol, p_xyzcv);
    OnErrorCode (PWsts, wrapup);
  }
  else
  {
    /*
     * Non-Planar/Planar non-rectangular surface.
     */

    int num_pts=0, isodir=0;
    PWpoint2d *p_pts=NULL;

    uvtol = pwGetParTolSf (p_sf, xyztol);
    num_pts = p_uvcv->data.py2d.num_pts; 
    p_pts = p_uvcv->data.py2d.p_pts; 

    if (pwIsUvPtsIso (num_pts, p_pts, uvtol, &isodir))
    {
      /*
       * Input curve is an iso curve.
       */

      short opt=0;
      double par1=0, par2=0, par3=0, par=0;
      PWboolean tst_plan=TRUE, get_part=TRUE;
      struct IGRbsp_curve constcv, partcv, *p_cv=NULL;

      /*
       * Allocate the memory for the full iso curve geometry and extract the
       * iso curve.
       */

      if (isodir == U)
      {
        opt = 1; par = p_pts[0][U];
        par1 = p_pts[0][V];
        par3 = p_pts[num_pts-1][V];
        par2 = (par1 + par3) / 2;
        PWsts = PW_AllocBspCvStack (p_sf->v_num_poles, p_sf->v_order, 
                                    p_sf->rational, constcv);  
        if (fabs(fabs (par3 - par1) - (v_max - v_min)) < uvtol)
          get_part = FALSE;
      }
      else
      {
        opt = 2; par = p_pts[0][V];
        par1 = p_pts[0][U];
        par3 = p_pts[num_pts-1][U];
        par2 = (par1 + par3) / 2;
        PWsts = PW_AllocBspCvStack (p_sf->u_num_poles, p_sf->u_order,
                                    p_sf->rational, constcv);  
        if (fabs(fabs (par3 - par1) - (u_max - u_min)) < uvtol)
          get_part = FALSE;
      }

      BSsts = BSconstprcv (&BSmsg, p_sf, &opt, &par, &tst_plan, &constcv);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);

      if (get_part)
      {
        /*
         * Only a part of the iso curve is needed. Get the part of the iso 
         * curve.
         */

        PWsts = PW_AllocBspCvStack ((constcv.num_poles + constcv.order * 2 -1),
                            constcv.order, constcv.rational, partcv);
        OnErrorCode (PWsts, wrapup);

        BSsts = BSpartofcv (&BSmsg, &constcv, par1, par2, par3, &partcv);
        OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                      PW_K_Internal), wrapup);

        BSnorkts (&BSmsg, &partcv.order, &partcv.num_poles, partcv.knots);

        p_cv = &partcv;
      }
      else
        p_cv = &constcv;

      /*
       * Put the extracted geometry in the right curve data.
       */

      if (p_cv->order == 2 && !p_cv->rational)
      {
        p_xyzcv->datatype = PWcvdata_py;
        p_xyzcv->data.py.num_pts = p_cv->num_poles; 
        p_xyzcv->data.py.p_pts = (PWpoint *) malloc (p_cv->num_poles *                                                               sizeof (PWpoint));
        memcpy (p_xyzcv->data.py.p_pts, p_cv->poles, p_cv->num_poles *
                                                     sizeof (PWpoint));
      }
      else
      {
        p_xyzcv->datatype = PWcvdata_bspcv;

        BSalloccv (p_cv->order, p_cv->num_poles, p_cv->rational, 0, 
                   &p_xyzcv->data.p_bspcv, &BSmsg);
        BScv_copy (&BSmsg, p_cv, p_xyzcv->data.p_bspcv); 
      }

	  /* reverse the curve if extracted in opposite way */

	  if(par1 > par3)
	  {
	  	/* rev the output cvdata */
		pwRevCvdata(p_xyzcv);
	  }
    }
    else
    {
      /*
       * Non-Iso curve. Evaluate the points in the model space to get the 
       * xyz curve.
       */

      p_xyzcv->datatype = PWcvdata_py;
      p_xyzcv->data.py.num_pts = num_pts;
      p_xyzcv->data.py.p_pts = (PWpoint *) malloc (num_pts * sizeof (PWpoint));
     
      BSsfptseval (p_sf, num_pts, &p_pts[0][0], &p_xyzcv->data.py.p_pts[0][0], 
                   &BSmsg); 
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);
    }
  }

wrapup :

  if (IsError (PWsts) && p_xyzcv->datatype != PWcvdata_null)
  {
    pwFreeCvdataGeom (p_xyzcv);
  }

  PW_Wrapup (PWsts, "pwMapUvCvToXyzOfSf");
  return PWsts;
}


/* ---------------------------- Static Functions ---------------------------- */


/*
  ABSTRACT

  Given the model space curve it returns the stroked uv curve data.

  NOTES

  Assumption being, the curve is not crossing the seams of the surface. All 
  the memory for the output will be allocated by this routine.

*/

static PWresult stroke_and_get_uvdata
(
  struct PWcvdata *p_xyzcv,
  struct IGRbsp_surface *p_sf,

  double xyztol,

  struct PWpoly2d *p_uvcv
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;

  PWboolean stroked=FALSE, onsurf=FALSE; 
  struct IGRbsp_curve *p_cv=NULL;

  int num_pts=0, num_outpts=0;
  PWpoint *p_pts=NULL, *p_tmppts=NULL;
  PWpoint2d *p_tmpuvpts=NULL, *p_uvpts=NULL;

  if (p_xyzcv->datatype == PWcvdata_bspcv ||
      p_xyzcv->datatype == PWcvdata_gmbspcv)
  {
    double *p_tmppars=NULL;

    p_cv = p_xyzcv->datatype == PWcvdata_bspcv ? p_xyzcv->data.p_bspcv :
                                        p_xyzcv->data.p_gmbspcv->bspcv ;

    BSchtptstcv (p_cv, &num_pts, &p_pts, &p_tmppars, &BSmsg);
    if (p_tmppars) free (p_tmppars);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath,
                  PW_K_Internal), wrapup);

    stroked = TRUE;
  }
  else
  {
    num_pts = p_xyzcv->data.py.num_pts;
    p_pts = p_xyzcv->data.py.p_pts;
  }

  p_tmpuvpts = (PWpoint2d *) alloca (num_pts * sizeof (PWpoint2d));
  OnErrorState (!p_tmpuvpts, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                wrapup);

  BSprptsonsf (num_pts, p_pts, p_sf, p_tmpuvpts, &onsurf, &BSmsg);
  /*OnErrorState (!onsurf || BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);
*/
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  PWsts = pwStrokeUvdataIfNeeded (p_sf, num_pts, p_tmpuvpts, p_pts, xyztol, 
                                  &num_outpts, &p_uvpts, &p_tmppts);
  OnErrorCode (PWsts, wrapup);

  p_uvcv->num_pts = num_outpts;
  p_uvcv->p_pts = p_uvpts;

wrapup : 

  if (stroked && p_pts) free (p_pts);
  if (p_tmppts) free (p_tmppts);

  if (IsError (PWsts) && p_uvpts)
  {
    free (p_uvpts);
  }

  PW_Wrapup (PWsts, "stroke_and_get_uvdata");
  return PWsts;
}

